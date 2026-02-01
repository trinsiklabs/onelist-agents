# Searcher Agent Configuration
#
# This file documents the configuration options for the Searcher Agent.
# In production, these are set via environment variables or config/runtime.exs

config :onelist, Onelist.Searcher,
  # Embedding provider (:voyage, :openai)
  embedding_provider: :voyage,
  
  # Embedding model
  # Voyage: "voyage-3-lite", "voyage-3", "voyage-code-3"
  # OpenAI: "text-embedding-3-small", "text-embedding-3-large"
  embedding_model: "voyage-3-lite",
  
  # Embedding dimensions (must match model)
  embedding_dimensions: 1024,
  
  # Reranking provider (:cohere, nil to disable)
  rerank_provider: :cohere,
  
  # Reranking model
  rerank_model: "rerank-v3.5",
  
  # Automatically embed entries when created
  auto_embed_on_create: true,
  
  # Automatically re-embed entries when updated
  auto_embed_on_update: true,
  
  # Default search limit
  default_limit: 20,
  
  # Default similarity threshold (0.0 - 1.0)
  default_threshold: 0.7,
  
  # Chunking configuration
  chunk_size: 512,           # Target tokens per chunk
  chunk_overlap: 50,         # Token overlap between chunks
  max_chunks_per_entry: 50,  # Maximum chunks per entry
  
  # Hybrid search weights
  semantic_weight: 0.7,
  keyword_weight: 0.3,
  
  # Two-layer search weights
  memory_weight: 0.6,
  chunk_weight: 0.4,
  
  # Query reformulation
  enable_query_reformulation: true,
  max_reformulated_queries: 5,
  
  # Worker queue configuration
  oban_queue: :embeddings,
  batch_queue: :embeddings_batch,
  
  # Maximum concurrent embedding jobs
  max_concurrent_jobs: 10,
  
  # Rate limiting
  rate_limit_rpm: 100

# Provider-specific configuration
config :onelist, :voyage,
  api_url: "https://api.voyageai.com/v1/embeddings",
  timeout_ms: 30_000

config :onelist, :cohere,
  api_url: "https://api.cohere.ai/v1/rerank",
  timeout_ms: 30_000

config :onelist, :openai_embeddings,
  api_url: "https://api.openai.com/v1/embeddings",
  timeout_ms: 30_000

# Environment variables required:
# - VOYAGE_API_KEY: API key for Voyage AI embeddings
# - COHERE_API_KEY: API key for Cohere reranking
# - OPENAI_API_KEY: API key for OpenAI (fallback embeddings)
