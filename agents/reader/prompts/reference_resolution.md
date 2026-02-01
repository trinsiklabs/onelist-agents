# Reference Resolution Prompt

**Version:** 1.0  
**Last Updated:** 2025-02-01

## System Context

You are an expert at resolving references in text to make statements self-contained. Your goal is to replace pronouns, relative times, and demonstratives with their specific referents.

## Prompt Template

```
Resolve all references in the following text to make it self-contained.
{{#if context}}

Context from earlier in the document or related entries:
{{context}}
{{/if}}

Reference date: {{reference_date}}

Tasks:
1. Replace pronouns (he, she, it, they, etc.) with the specific names/entities they refer to
2. Resolve relative time expressions ("yesterday", "next week", "in 3 days") to specific dates
3. Resolve demonstratives ("this project", "that meeting") to specific names when possible
4. Keep the text natural and readable

Return ONLY a JSON object with:
- resolved_text: The text with all references resolved
- resolutions: Array of {original, resolved, type} objects showing what was changed

Text to resolve:
{{content}}
```

## Variables

| Variable | Type | Description |
|----------|------|-------------|
| `reference_date` | ISO8601 date | The date to use for resolving relative time expressions |
| `content` | string | The text content with references to resolve |
| `context` | JSON object | Optional context from earlier text or related entries |

## Output Schema

```json
{
  "resolved_text": "Alice Smith mentioned that Alice Smith would review the proposal by 2025-02-03. The quarterly review meeting will need the updated figures.",
  "resolutions": [
    {
      "original": "she",
      "resolved": "Alice Smith",
      "type": "pronoun"
    },
    {
      "original": "next Monday",
      "resolved": "2025-02-03",
      "type": "temporal"
    }
  ]
}
```

## Resolution Types

### pronoun
Personal pronouns: he, she, it, they, him, her, them, his, hers, their, its

### temporal
Time expressions: yesterday, tomorrow, next week, last month, in 3 days, this morning, next Friday

### demonstrative
Pointing words: this, that, these, those (when referring to specific entities)

### possessive
Ownership references: his, her, its, their (when the owner needs clarification)

## Resolution Guidelines

### Pronouns
- Only resolve when the referent is clear from context
- If multiple possible referents exist, prefer the most recently mentioned
- If truly ambiguous, leave unchanged and note in resolutions with `"resolved": null`

### Temporal Expressions

| Expression | Resolution Logic |
|------------|-----------------|
| today | reference_date |
| yesterday | reference_date - 1 day |
| tomorrow | reference_date + 1 day |
| this week | Week containing reference_date (Mon-Sun) |
| next week | Week after reference_date |
| last week | Week before reference_date |
| this Monday | Monday of current week (or next if past) |
| next Monday | Monday of next week |
| last Monday | Monday of previous week |
| in X days | reference_date + X days |
| X days ago | reference_date - X days |
| this morning | reference_date morning |
| tonight | reference_date evening |

### Demonstratives
- Resolve "this [noun]" to specific name when clear from context
- Leave generic demonstratives unchanged ("this is important")
- When resolution is uncertain, prefer leaving unchanged

## Example

### Input
**Content:** "I talked to John yesterday. He said the project is going well and they expect to finish by next Friday. His team has been working hard on this."

**Reference Date:** 2025-02-01

**Context:** `{"project": "Website Redesign"}`

### Output
```json
{
  "resolved_text": "I talked to John on 2025-01-31. John said the Website Redesign project is going well and John's team expects to finish by 2025-02-07. John's team has been working hard on the Website Redesign project.",
  "resolutions": [
    {"original": "yesterday", "resolved": "2025-01-31", "type": "temporal"},
    {"original": "He", "resolved": "John", "type": "pronoun"},
    {"original": "the project", "resolved": "the Website Redesign project", "type": "demonstrative"},
    {"original": "they", "resolved": "John's team", "type": "pronoun"},
    {"original": "next Friday", "resolved": "2025-02-07", "type": "temporal"},
    {"original": "His team", "resolved": "John's team", "type": "possessive"},
    {"original": "this", "resolved": "the Website Redesign project", "type": "demonstrative"}
  ]
}
```

## Notes

- Prioritize clarity over perfect grammar
- When unsure, err on the side of leaving text unchanged
- Context should guide resolution but not override clear textual evidence
- Record ALL resolutions, even trivial ones, for audit purposes
