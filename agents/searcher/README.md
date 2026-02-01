# Searcher Agent

**Status:** ✅ Active  
**Type:** Semantic Search & Retrieval  
**Embedding Provider:** Voyage AI  
**Reranking Provider:** Cohere

## Overview

The Searcher Agent enables users to find relevant information using natural language queries. It combines vector similarity search with intelligent reranking for high-quality results across entries and memories.

## Capabilities

### 1. Semantic Search
- Vector similarity search using embeddings
- Query reformulation for better recall
- Multiple search modes: semantic, keyword, hybrid, atomic

### 2. Two-Layer Search
- **Layer 1 (Atomic):** Search extracted memories for high-precision fact retrieval
- **Layer 2 (Context):** Inject source chunks to provide surrounding context

### 3. Hybrid Search
- Combines semantic (vector) and keyword (BM25) search
- Configurable weights for each approach
- Best of both worlds: precision + recall

### 4. Reranking
- Uses Cohere's rerank API for result refinement
- Filters low-confidence matches
- Improves result ordering significantly

### 5. Query Reformulation
- Expands ambiguous queries
- Generates search variations
- Handles typos and synonyms

## Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                       Searcher Agent                             │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  ┌──────────────┐    ┌──────────────┐    ┌──────────────┐       │
│  │Query         │    │ Two-Layer    │    │  Hybrid      │       │
│  │Reformulator  │───▶│ Search       │───▶│  Search      │       │
│  └──────────────┘    └──────────────┘    └──────────────┘       │
│         │                   │                   │                │
│         ▼                   ▼                   ▼                │
│  ┌──────────────┐    ┌──────────────┐    ┌──────────────┐       │
│  │  Embedding   │    │   Atomic     │    │   Keyword    │       │
│  │  Provider    │    │   Memory     │    │   (BM25)     │       │
│  │  (Voyage)    │    │   Search     │    │   Search     │       │
│  └──────────────┘    └──────────────┘    └──────────────┘       │
│         │                   │                   │                │
│         └───────────────────┼───────────────────┘                │
│                             ▼                                    │
│                      ┌──────────────┐                            │
│                      │   Reranker   │                            │
│                      │   (Cohere)   │                            │
│                      └──────────────┘                            │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

## Search Modes

| Mode | Description | Use Case |
|------|-------------|----------|
| `semantic` | Vector similarity only | Best for conceptual/meaning-based queries |
| `keyword` | Full-text search (BM25) | Best for exact phrase matching |
| `hybrid` | Semantic + keyword fusion | Default, balanced approach |
| `atomic` | Search memories table only | High precision fact retrieval |
| `memory_hybrid` | Memories + chunks combined | Rich context with atomic precision |

## Configuration

See [config/searcher.exs](config/searcher.exs) for full configuration options.

```elixir
config :onelist, Onelist.Searcher,
  # Embedding configuration
  embedding_model: "voyage-3-lite",
  embedding_dimensions: 1024,
  embedding_provider: :voyage,
  
  # Reranking
  rerank_model: "rerank-v3.5",
  rerank_provider: :cohere,
  
  # Chunking
  max_chunks_per_entry: 50,
  chunk_size: 512,
  chunk_overlap: 50,
  
  # Search defaults
  default_limit: 20,
  default_threshold: 0.7,
  
  # Auto-embedding
  auto_embed_on_create: true,
  auto_embed_on_update: true
```

## Prompts

- [`prompts/query_reformulation.md`](prompts/query_reformulation.md) - Query expansion and refinement

## API

### Elixir Module

```elixir
# Basic search (hybrid mode)
{:ok, results} = Onelist.Searcher.search(user_id, "meeting notes from last week")

# Semantic-only search
{:ok, results} = Onelist.Searcher.search(user_id, query, search_type: :semantic)

# Atomic memory search
{:ok, results} = Onelist.Searcher.memory_search(user_id, "coffee preferences")

# Search with options
{:ok, results} = Onelist.Searcher.search(user_id, query,
  limit: 10,
  search_type: :hybrid,
  semantic_weight: 0.7,
  keyword_weight: 0.3,
  filters: %{
    entry_types: ["note", "document"],
    tags: ["project-alpha"],
    date_range: {~D[2025-01-01], ~D[2025-02-01]}
  }
)

# Find similar entries
{:ok, similar} = Onelist.Searcher.similar_entries(entry_id, limit: 5)

# Embedding operations
:ok = Onelist.Searcher.enqueue_embedding(entry_id, priority: 1)
embeddings = Onelist.Searcher.get_embeddings(entry_id)
is_embedded = Onelist.Searcher.embedded?(entry_id)
```

### HTTP API (via Phoenix)

```bash
# Search entries
GET /api/v1/search?q=meeting+notes&limit=20
Authorization: Bearer <token>

# Search with filters
GET /api/v1/search?q=project+update&type=semantic&tags[]=alpha

# Find similar entries
GET /api/v1/entries/:id/similar

# Get embedding status
GET /api/v1/entries/:id/embedding-status

# Trigger re-embedding
POST /api/v1/entries/:id/embed
```

## Providers

| Provider | Purpose | Model | Status |
|----------|---------|-------|--------|
| Voyage AI | Embeddings | voyage-3-lite | ✅ Active |
| Cohere | Reranking | rerank-v3.5 | ✅ Active |
| OpenAI | Embeddings (fallback) | text-embedding-3-small | 🔄 Planned |

## Chunking Strategy

The Chunker splits long content into searchable chunks:

```elixir
# Chunking configuration
chunk_size: 512,        # Target tokens per chunk
chunk_overlap: 50,      # Token overlap between chunks
max_chunks: 50,         # Maximum chunks per entry
```

### Content Type Handling

| Type | Strategy |
|------|----------|
| Markdown | Split on headers, preserve structure |
| Plain text | Split on paragraphs, then sentences |
| Code | Split on function/class boundaries |
| HTML | Convert to markdown first |

## Database Schema

```sql
-- Entry embeddings (chunk-based)
CREATE TABLE embeddings (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  entry_id UUID NOT NULL REFERENCES entries(id) ON DELETE CASCADE,
  content TEXT NOT NULL,
  chunk_index INTEGER NOT NULL DEFAULT 0,
  model_name VARCHAR(100) NOT NULL,
  vector vector(1024),
  metadata JSONB DEFAULT '{}',
  inserted_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE(entry_id, chunk_index, model_name)
);

CREATE INDEX embeddings_entry_id_idx ON embeddings(entry_id);
CREATE INDEX embeddings_vector_idx ON embeddings USING ivfflat (vector vector_cosine_ops);

-- Search configuration per user
CREATE TABLE search_configs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) UNIQUE,
  auto_embed_on_create BOOLEAN DEFAULT true,
  auto_embed_on_update BOOLEAN DEFAULT true,
  daily_enrichment_budget_cents INTEGER,
  spent_enrichment_today_cents INTEGER DEFAULT 0,
  reader_settings JSONB DEFAULT '{}',
  inserted_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Embedding job tracking
CREATE TABLE embedding_jobs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  entry_id UUID NOT NULL REFERENCES entries(id) ON DELETE CASCADE,
  status VARCHAR(50) NOT NULL DEFAULT 'pending',
  chunks_processed INTEGER DEFAULT 0,
  total_chunks INTEGER,
  error_message TEXT,
  started_at TIMESTAMPTZ,
  completed_at TIMESTAMPTZ,
  inserted_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
```

## Two-Layer Search Details

### Layer 1: Atomic Memory Search

Searches the `memories` table for extracted facts/preferences/events:

```elixir
# High-precision fact retrieval
{:ok, results} = TwoLayerSearch.search(user_id, query,
  search_mode: :atomic,
  current_only: true,      # Only non-superseded memories
  include_source_chunks: true  # Inject original context
)
```

### Layer 2: Context Injection

After finding relevant memories, injects source context:

1. Collect unique entry IDs from memory results
2. Load entries with their representations
3. Attach `source_entry`, `source_representation`, `source_chunk` to each result

## Hybrid Search Scoring

```
final_score = (memory_score × memory_weight) + (chunk_score × chunk_weight)
```

Default weights:
- `memory_weight`: 0.6
- `chunk_weight`: 0.4

Results are deduplicated by entry to prevent showing multiple memories from the same entry.

## Performance Considerations

- **IVFFlat Index:** Uses approximate nearest neighbor for fast vector search
- **Batch Embeddings:** Groups embedding requests to reduce API calls
- **Rate Limiting:** Configurable per-minute limits for embedding providers
- **Caching:** Query result caching planned for frequent searches

### Estimated Costs (per 1000 entries)

| Provider | Model | Cost |
|----------|-------|------|
| Voyage AI | voyage-3-lite | ~$0.02 |
| Cohere | rerank-v3.5 | ~$0.10 (per 1000 reranks) |
| OpenAI | text-embedding-3-small | ~$0.02 |

## Integration with Reader

Searcher relies on Reader-extracted memories for two-layer search:

1. Reader extracts atomic memories from entries
2. Searcher embeds both entries (chunks) and memories
3. Search queries can target either or both layers
4. Results include source context for full understanding

See [Reader Agent](../reader/README.md) for memory extraction details.

## Related

- [Reader Agent](../reader/README.md) - Content processing and memory extraction
- [River Agent](../../docs/river.md) - Conversational interface using Searcher for retrieval
