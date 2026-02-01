# Query Reformulation Prompt

**Version:** 1.0  
**Last Updated:** 2025-02-01

## System Context

You are an expert at reformulating search queries for better retrieval. Your goal is to expand and refine user queries to improve search recall while maintaining precision.

## Prompt Template

```
Reformulate the following search query to improve retrieval. Generate 3-5 alternative queries that:
1. Expand abbreviations and acronyms
2. Add synonyms for key terms
3. Rephrase the question in different ways
4. Include related concepts that might appear in relevant documents

Original query: {{query}}
{{#if context}}
User context: {{context}}
{{/if}}

Return a JSON object with:
- queries: Array of reformulated queries (including the original)
- expansion_terms: Key terms that were expanded or added
- intent: Brief description of what the user is likely looking for

Original query should be first in the queries array.
```

## Variables

| Variable | Type | Description |
|----------|------|-------------|
| `query` | string | The original search query from the user |
| `context` | string | Optional context about the user or their content |

## Output Schema

```json
{
  "queries": [
    "meeting notes from last week",
    "meeting minutes recent",
    "standup notes past 7 days",
    "team sync notes January",
    "weekly meeting summary"
  ],
  "expansion_terms": [
    "meeting → standup, sync, call",
    "notes → minutes, summary",
    "last week → past 7 days, recent, January 2025"
  ],
  "intent": "User wants to find notes or summaries from team meetings that occurred in the past week"
}
```

## Reformulation Strategies

### 1. Synonym Expansion
Replace key terms with synonyms that might appear in documents:

| Original | Expansions |
|----------|------------|
| meeting | standup, sync, call, discussion, conference |
| notes | minutes, summary, recap, notes, documentation |
| project | initiative, effort, work, task |
| deadline | due date, target date, milestone |
| issue | problem, bug, concern, blocker |

### 2. Acronym Expansion
Expand common acronyms and also keep the acronym:

| Acronym | Expansion |
|---------|-----------|
| API | Application Programming Interface |
| PR | Pull Request |
| CI/CD | Continuous Integration, Continuous Deployment |
| MVP | Minimum Viable Product |
| KPI | Key Performance Indicator |

### 3. Temporal Normalization
Convert relative times to multiple phrasings:

| Original | Expansions |
|----------|------------|
| last week | past 7 days, recent, [specific dates] |
| yesterday | [specific date], recent |
| next month | upcoming, February 2025, Q1 |
| Q4 | October November December, fourth quarter |

### 4. Intent-Based Expansion
Add terms based on likely user intent:

| Query Type | Additional Terms |
|------------|------------------|
| Finding documents | title, document, file, attachment |
| Finding people | name, contact, email, mentioned |
| Finding dates | scheduled, planned, deadline, calendar |
| Finding decisions | decided, approved, rejected, agreed |

## Examples

### Example 1: Simple Query

**Input:**
```
Original query: "python async"
```

**Output:**
```json
{
  "queries": [
    "python async",
    "python asynchronous programming",
    "python asyncio tutorial",
    "async await python",
    "python concurrent programming"
  ],
  "expansion_terms": [
    "async → asynchronous, asyncio, async/await",
    "added: programming, tutorial, concurrent"
  ],
  "intent": "User wants to learn about or find information on asynchronous programming in Python"
}
```

### Example 2: Complex Query

**Input:**
```
Original query: "Q3 OKRs status update"
User context: Works at tech startup, engineering team
```

**Output:**
```json
{
  "queries": [
    "Q3 OKRs status update",
    "third quarter objectives key results progress",
    "Q3 goals tracking engineering",
    "OKR review July August September",
    "quarterly objectives status report"
  ],
  "expansion_terms": [
    "Q3 → third quarter, July August September",
    "OKRs → objectives key results, goals",
    "status update → progress, tracking, review, report"
  ],
  "intent": "User wants to find status updates or progress reports on third quarter OKRs, likely for their engineering team"
}
```

### Example 3: Vague Query

**Input:**
```
Original query: "that thing bob mentioned"
User context: Recent meetings with Bob about database migration
```

**Output:**
```json
{
  "queries": [
    "that thing bob mentioned",
    "bob database migration",
    "bob mentioned recent meeting",
    "bob discussion notes",
    "bob suggestion recommendation"
  ],
  "expansion_terms": [
    "thing → topic, item, idea, suggestion",
    "mentioned → said, discussed, brought up, recommended",
    "added context: database, migration"
  ],
  "intent": "User is trying to recall something Bob said, likely related to database migration based on context"
}
```

## Quality Guidelines

### Good Reformulations
- Maintain the core intent of the original query
- Add plausible variations that might appear in documents
- Consider how users typically write/title their notes
- Balance precision (too broad = noise) and recall (too narrow = misses)

### Avoid
- Queries that change the original meaning
- Too many expansions (aim for 3-5 total queries)
- Overly generic terms that add noise
- Invented acronyms or terminology

## Notes

- Original query should always be first in the results
- Context is optional but highly valuable when available
- The intent field helps for debugging and logging
- Expansion terms document the reasoning for transparency
