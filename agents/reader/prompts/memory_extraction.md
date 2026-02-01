# Memory Extraction Prompt

**Version:** 1.0  
**Last Updated:** 2025-02-01

## System Context

You are an expert at extracting atomic memories from text. Your goal is to break content into discrete, self-contained facts that can be retrieved and reasoned about independently.

## Prompt Template

```
Extract atomic memories from the following text. Each memory should be a self-contained fact that could be retrieved later.

Reference date for temporal resolution: {{reference_date}}

For each memory, provide:
1. content: The complete, self-contained statement (resolve all pronouns to specific names/entities)
2. memory_type: One of "fact", "preference", "event", "observation", "decision"
3. confidence: How confident you are in this extraction (0.0-1.0)
4. entities: Object with keys "people", "places", "organizations" (arrays of strings)
5. temporal_expression: Original time reference if any (e.g., "yesterday", "next week")
6. resolved_time: ISO8601 datetime if you can resolve the temporal expression

Rules:
- Make each memory self-contained (no pronouns like "he", "she", "it", "they")
- Resolve relative times ("yesterday" → actual date based on reference date)
- Extract distinct, non-overlapping facts
- Prefer specific over vague statements
- Skip trivial or unimportant details

Return ONLY a JSON array of memory objects. If no meaningful memories can be extracted, return an empty array [].

Text to analyze:
{{content}}
```

## Variables

| Variable | Type | Description |
|----------|------|-------------|
| `reference_date` | ISO8601 date | The date to use for resolving relative time expressions |
| `content` | string | The text content to extract memories from |

## Output Schema

```json
[
  {
    "content": "Alice Smith works as a senior engineer at Acme Corporation",
    "memory_type": "fact",
    "confidence": 0.95,
    "entities": {
      "people": ["Alice Smith"],
      "places": [],
      "organizations": ["Acme Corporation"]
    },
    "temporal_expression": null,
    "resolved_time": null
  },
  {
    "content": "The team standup meeting is scheduled for 2025-02-03 at 9:00 AM",
    "memory_type": "event",
    "confidence": 0.9,
    "entities": {
      "people": [],
      "places": [],
      "organizations": []
    },
    "temporal_expression": "Monday morning",
    "resolved_time": "2025-02-03T09:00:00Z"
  }
]
```

## Memory Type Guidelines

### fact
- Verifiable pieces of information
- Statements about what IS, not opinions
- Examples: job titles, relationships, locations, capabilities

### preference
- User likes, dislikes, or preferences
- Should be attributable to a specific person
- Examples: "Bob prefers dark mode", "The team chose Slack over Teams"

### event
- Things that happened or will happen at specific times
- Should include temporal information when available
- Examples: meetings, deadlines, milestones, birthdays

### observation
- Insights, patterns noticed, or commentary
- Often subjective but valuable for context
- Examples: "The project seems behind schedule", "Performance has improved lately"

### decision
- Choices made by people or groups
- Should indicate who decided and what was chosen
- Examples: "We decided to use PostgreSQL", "Alice chose to work from home on Fridays"

## Confidence Guidelines

| Score | Meaning |
|-------|---------|
| 0.9-1.0 | Explicit statement, directly quoted or clearly stated |
| 0.7-0.9 | Strong inference from context |
| 0.5-0.7 | Reasonable inference, some uncertainty |
| 0.3-0.5 | Weak inference, significant uncertainty |
| 0.0-0.3 | Very uncertain, borderline extraction |

## Example Transformations

### Input
> "I met with John yesterday and he said the project is on track. His team should finish by next Friday."

### Output (reference_date: 2025-02-01)
```json
[
  {
    "content": "Meeting with John occurred on 2025-01-31",
    "memory_type": "event",
    "confidence": 0.95,
    "entities": {"people": ["John"], "places": [], "organizations": []},
    "temporal_expression": "yesterday",
    "resolved_time": "2025-01-31T00:00:00Z"
  },
  {
    "content": "John reported that the project is on track as of 2025-01-31",
    "memory_type": "observation",
    "confidence": 0.85,
    "entities": {"people": ["John"], "places": [], "organizations": []},
    "temporal_expression": null,
    "resolved_time": null
  },
  {
    "content": "John's team expects to finish the project by 2025-02-07",
    "memory_type": "event",
    "confidence": 0.80,
    "entities": {"people": ["John"], "places": [], "organizations": []},
    "temporal_expression": "next Friday",
    "resolved_time": "2025-02-07T00:00:00Z"
  }
]
```

## Notes

- When context is ambiguous, prefer extracting fewer, higher-confidence memories over many uncertain ones
- Entity extraction should focus on named entities, not generic terms
- Temporal resolution assumes the user's timezone if not specified (default UTC)
