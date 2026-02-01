# Reader Agent

**Status:** ✅ Active  
**Type:** Content Processing & Memory Extraction  
**Primary Provider:** Anthropic (Claude)  
**Fallback Provider:** OpenAI (GPT-4)

## Overview

The Reader Agent transforms unstructured content into structured, searchable knowledge. It's the intelligence layer that understands what users save, extracts atomic memories, and suggests relevant tags.

## Capabilities

### 1. Memory Extraction
- Extracts atomic memories (discrete facts) from content
- Classifies memories by type: `fact`, `preference`, `event`, `observation`, `decision`
- Resolves pronouns and references to make memories self-contained
- Assigns confidence scores based on extraction quality

### 2. Reference Resolution
- Resolves pronouns ("he", "she", "they") to specific entities
- Converts temporal expressions ("yesterday", "next week") to absolute dates
- Resolves demonstratives ("this project") when context is available

### 3. Tag Suggestion
- Analyzes content for relevant tags
- Prefers reusing existing user tags when appropriate
- Suggests new tags with confidence scores
- Respects user's tagging style and vocabulary

### 4. Summary Generation
- Creates concise summaries of content
- Preserves key information and main points
- Configurable length limits

### 5. Memory Relationship Detection
- Identifies when new memories supersede older ones
- Detects refinement relationships between memories
- Helps maintain memory graph coherence

## Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                        Reader Agent                              │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  ┌─────────────┐    ┌─────────────┐    ┌─────────────┐          │
│  │  Extractors │    │  Generators │    │   Workers   │          │
│  ├─────────────┤    ├─────────────┤    ├─────────────┤          │
│  │ Memory      │    │ Tag         │    │ ProcessEntry│          │
│  │ Reference   │    │ Summary     │    │ EmbedMemory │          │
│  └──────┬──────┘    └──────┬──────┘    └──────┬──────┘          │
│         │                  │                  │                  │
│         └──────────────────┼──────────────────┘                  │
│                            │                                     │
│                   ┌────────▼────────┐                            │
│                   │   LLM Provider  │                            │
│                   │   (Anthropic/   │                            │
│                   │    OpenAI)      │                            │
│                   └─────────────────┘                            │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

## Memory Types

| Type | Description | Example |
|------|-------------|---------|
| `fact` | Verifiable piece of information | "Alice works at Acme Corp" |
| `preference` | User preference or opinion | "Bob prefers dark mode in all apps" |
| `event` | Something that happened at a specific time | "Team meeting scheduled for 2024-02-15 at 10am" |
| `observation` | An insight or observation | "The garden project is falling behind schedule" |
| `decision` | A choice or decision made | "We decided to use PostgreSQL for the database" |

## Configuration

See [config/reader.exs](config/reader.exs) for full configuration options.

```elixir
config :onelist, Onelist.Reader,
  primary_provider: :anthropic,
  model: "claude-3-5-haiku-20241022",
  fallback_provider: :openai,
  fallback_model: "gpt-4o-mini",
  extraction_model: "gpt-4o-mini",
  auto_process_on_create: true,
  auto_process_on_update: true
```

## Prompts

All prompts are templated and version-controlled:

- [`prompts/memory_extraction.md`](prompts/memory_extraction.md) - Atomic memory extraction
- [`prompts/tag_suggestion.md`](prompts/tag_suggestion.md) - Tag recommendation
- [`prompts/reference_resolution.md`](prompts/reference_resolution.md) - Pronoun/temporal resolution
- [`prompts/relationship_classification.md`](prompts/relationship_classification.md) - Memory relationship detection

## API

### Elixir Module

```elixir
# Process an entry (async via Oban)
Onelist.Reader.enqueue_processing(entry_id, priority: 1)

# Process synchronously
{:ok, result} = Onelist.Reader.process_entry(entry_id)

# Get memories for an entry
memories = Onelist.Reader.get_memories_for_entry(entry_id, 
  memory_type: "fact", 
  min_confidence: 0.8
)

# Get current (non-superseded) memories for a user
current = Onelist.Reader.get_current_memories(user_id, limit: 100)

# Search memories by vector similarity
results = Onelist.Reader.search_memories(user_id, query_vector, 
  limit: 10, 
  min_similarity: 0.7
)

# Tag operations
{:ok, suggestions} = Onelist.Reader.get_tag_suggestions(entry_id)
:ok = Onelist.Reader.accept_tag_suggestion(entry_id, "project-alpha")
:ok = Onelist.Reader.reject_tag_suggestion(entry_id, "irrelevant-tag")
```

### HTTP API (via Phoenix)

```bash
# Process an entry
POST /api/v1/entries/:id/process
Content-Type: application/json
Authorization: Bearer <token>

# Get memories for entry
GET /api/v1/entries/:id/memories

# Get tag suggestions
GET /api/v1/entries/:id/tag-suggestions

# Accept/reject tag suggestion
POST /api/v1/entries/:id/tags/:tag_name/accept
POST /api/v1/entries/:id/tags/:tag_name/reject
```

## Cost Tracking

Reader tracks LLM costs per operation and enforces daily budgets:

```elixir
# Check remaining budget
Onelist.Reader.has_budget?(user_id)

# Track cost (in cents)
Onelist.Reader.track_cost(user_id, 5)
```

### Estimated Costs (per 1000 entries)

| Model | Input | Output | Total |
|-------|-------|--------|-------|
| Claude 3.5 Haiku | ~$0.25 | ~$1.25 | ~$1.50 |
| Claude 3.5 Sonnet | ~$3.00 | ~$15.00 | ~$18.00 |
| GPT-4o-mini | ~$0.15 | ~$0.60 | ~$0.75 |

## Trusted Memory Mode

For AI users (like Stream), a special mode allows:
- Direct memory creation without source entries
- Higher confidence scores by default
- Privileged access patterns

```elixir
# Check if user has trusted memory mode
Onelist.Accounts.User.trusted_memory_mode?(user)
```

## Database Schema

```sql
CREATE TABLE memories (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id),
  entry_id UUID REFERENCES entries(id),
  content TEXT NOT NULL,
  memory_type VARCHAR(50) NOT NULL,
  confidence DECIMAL(3,2) DEFAULT 1.0,
  embedding vector(1024),
  valid_from TIMESTAMPTZ,
  valid_until TIMESTAMPTZ,
  temporal_expression TEXT,
  resolved_time TIMESTAMPTZ,
  source_text TEXT,
  chunk_index INTEGER,
  entities JSONB DEFAULT '{}',
  metadata JSONB DEFAULT '{}',
  supersedes_id UUID REFERENCES memories(id),
  refines_id UUID REFERENCES memories(id),
  inserted_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX memories_user_id_idx ON memories(user_id);
CREATE INDEX memories_entry_id_idx ON memories(entry_id);
CREATE INDEX memories_valid_until_idx ON memories(valid_until) WHERE valid_until IS NULL;
CREATE INDEX memories_embedding_idx ON memories USING ivfflat (embedding vector_cosine_ops);
```

## Integration with Searcher

Reader-extracted memories are indexed by the Searcher agent for two-layer search:

1. **Layer 1 (Atomic):** Search memories directly for high-precision fact retrieval
2. **Layer 2 (Context):** Inject source chunks to provide surrounding context

See [Searcher Agent](../searcher/README.md) for details.

## Related

- [Searcher Agent](../searcher/README.md) - Semantic search and retrieval
- [River Agent](../../docs/river.md) - Conversational interface
