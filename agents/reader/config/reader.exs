# Reader Agent Configuration
#
# This file documents the configuration options for the Reader Agent.
# In production, these are set via environment variables or config/runtime.exs

config :onelist, Onelist.Reader,
  # Primary LLM provider (:anthropic or :openai)
  primary_provider: :anthropic,
  
  # Primary model for extraction tasks
  # Options: "claude-3-5-haiku-20241022", "claude-sonnet-4-20250514"
  model: "claude-3-5-haiku-20241022",
  
  # Fallback provider when primary fails
  fallback_provider: :openai,
  
  # Fallback model
  fallback_model: "gpt-4o-mini",
  
  # Model for memory extraction specifically (can differ from main model)
  extraction_model: "gpt-4o-mini",
  
  # Maximum tokens for LLM responses
  max_tokens: 4096,
  
  # Temperature for LLM calls (lower = more deterministic)
  temperature: 0.3,
  
  # Automatically process entries when created
  auto_process_on_create: true,
  
  # Automatically process entries when updated
  auto_process_on_update: true,
  
  # Maximum tag suggestions per entry
  max_tag_suggestions: 5,
  
  # Default confidence threshold for memory acceptance
  min_confidence: 0.5,
  
  # Worker queue configuration
  oban_queue: :reader,
  
  # Maximum concurrent processing jobs
  max_concurrent_jobs: 5,
  
  # Rate limiting (requests per minute)
  rate_limit_rpm: 60

# Provider-specific configuration
config :onelist, :anthropic,
  api_url: "https://api.anthropic.com/v1/messages",
  api_version: "2023-06-01",
  timeout_ms: 60_000

config :onelist, :openai,
  api_url: "https://api.openai.com/v1/chat/completions",
  timeout_ms: 60_000

# Environment variables required:
# - ANTHROPIC_API_KEY: API key for Anthropic Claude
# - OPENAI_API_KEY: API key for OpenAI (fallback)
