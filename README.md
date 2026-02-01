# Onelist Agents

AI agents powering Onelist's intelligent features.

## Overview

Onelist uses a multi-agent architecture where specialized AI agents collaborate to provide intelligent note management, semantic search, and conversational interfaces.

## Agents

| Agent | Status | Description | Docs |
|-------|--------|-------------|------|
| [Reader](agents/reader/) | ✅ Active | Content processing, memory extraction, tag suggestions | [Full Docs](agents/reader/README.md) |
| [Searcher](agents/searcher/) | ✅ Active | Semantic search with embeddings and reranking | [Full Docs](agents/searcher/README.md) |
| [River](docs/river.md) | ✅ Active | Conversational interface with intent classification | [Spec](docs/river.md) |
| [Asset Enrichment](docs/asset-enrichment.md) | 📋 Planned | Automatic metadata enhancement for files and media | [Spec](docs/asset-enrichment.md) |

## Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                          User Interface                          │
└─────────────────────────────┬───────────────────────────────────┘
                              │
┌─────────────────────────────▼───────────────────────────────────┐
│                         River Agent                              │
│  (Intent Classification → Entity Extraction → Response Gen)      │
└──────────────┬──────────────────────────────────┬───────────────┘
               │                                  │
┌──────────────▼──────────────┐    ┌──────────────▼──────────────┐
│       Searcher Agent        │    │        Reader Agent         │
│  • Embedding Generation     │    │  • Content Processing       │
│  • Two-Layer Search         │    │  • Memory Extraction        │
│  • Reranking (Cohere)       │    │  • Tag Suggestion           │
│  • Query Reformulation      │    │  • LLM Provider Abstraction │
└──────────────┬──────────────┘    └──────────────┬──────────────┘
               │                                  │
┌──────────────▼──────────────────────────────────▼───────────────┐
│                    PostgreSQL + pgvector                         │
│                (Embeddings, Memories, Entries)                   │
└─────────────────────────────────────────────────────────────────┘
```

## Repository Structure

```
onelist-agents/
├── README.md                 # This file
├── LICENSE                   # MIT License
├── agents/                   # Agent implementations
│   ├── reader/               # Reader Agent
│   │   ├── README.md         # Full documentation
│   │   ├── config/           # Configuration templates
│   │   │   └── reader.exs
│   │   └── prompts/          # LLM prompt templates
│   │       ├── memory_extraction.md
│   │       ├── tag_suggestion.md
│   │       ├── reference_resolution.md
│   │       └── relationship_classification.md
│   └── searcher/             # Searcher Agent
│       ├── README.md         # Full documentation
│       ├── config/           # Configuration templates
│       │   └── searcher.exs
│       └── prompts/          # LLM prompt templates
│           └── query_reformulation.md
└── docs/                     # Additional documentation
    ├── reader.md             # Reader overview
    ├── searcher.md           # Searcher overview
    ├── river.md              # River specification
    └── asset-enrichment.md   # Asset enrichment planning
```

## Quick Start

Agents are built into the Onelist Phoenix application. See individual agent docs for configuration.

### Environment Variables

```bash
# Reader Agent
ANTHROPIC_API_KEY=           # Claude for content processing
OPENAI_API_KEY=              # GPT fallback

# Searcher Agent
VOYAGE_API_KEY=              # Voyage AI for embeddings
COHERE_API_KEY=              # Cohere for reranking

# River Agent (uses Reader's LLM configuration)
```

## Agent Responsibilities

### Reader Agent
- **Memory Extraction:** Transforms unstructured content into atomic, searchable memories
- **Reference Resolution:** Resolves pronouns and temporal expressions
- **Tag Suggestion:** Recommends relevant tags based on content analysis
- **Summary Generation:** Creates concise content summaries

### Searcher Agent
- **Embedding Generation:** Creates vector embeddings for semantic search
- **Two-Layer Search:** Combines atomic memory search with chunk-based retrieval
- **Hybrid Search:** Fuses semantic and keyword search for best results
- **Reranking:** Uses Cohere to improve result ordering

### River Agent
- **Intent Classification:** Understands what users want to do
- **Entity Extraction:** Identifies relevant entities in queries
- **Response Generation:** Produces helpful, contextual responses
- **Action Coordination:** Orchestrates Reader and Searcher as needed

## Development

The agent implementations live in the [onelist-local](https://github.com/trinsiklabs/onelist-local) package:

```
lib/onelist/
├── searcher/           # Semantic search agent
│   ├── chunker.ex
│   ├── embedding.ex
│   ├── embedding_job.ex
│   ├── hybrid_search.ex
│   ├── model_router.ex
│   ├── query_reformulator.ex
│   ├── rate_limiter.ex
│   ├── reranker.ex
│   ├── search.ex
│   ├── search_config.ex
│   ├── two_layer_search.ex
│   ├── verifier.ex
│   ├── providers/
│   └── workers/
├── reader/             # Content processing agent
│   ├── memory.ex
│   ├── behaviours/
│   ├── extractors/
│   ├── generators/
│   ├── providers/
│   └── workers/
└── river/              # Conversational agent
    ├── chat/
    │   ├── intent_classifier.ex
    │   ├── entity_extractor.ex
    │   └── response_generator.ex
    ├── entries.ex
    ├── gtd.ex
    └── message.ex
```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request

For agent implementation changes, please also update the corresponding onelist-local repository.

## License

MIT License - see [LICENSE](LICENSE) for details.

---

*Part of the [Onelist](https://onelist.my) project by Trinsik Labs*
