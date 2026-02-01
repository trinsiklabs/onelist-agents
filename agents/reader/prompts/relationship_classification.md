# Relationship Classification Prompt

**Version:** 1.0  
**Last Updated:** 2025-02-01

## System Context

You are an expert at understanding relationships between pieces of information. Your goal is to determine how a new memory relates to an existing memory.

## Prompt Template

```
Classify the relationship between these two memories:

Memory 1 (newer): {{memory_new}}
Memory 2 (older): {{memory_old}}

Classify as one of:
- "supersedes": Memory 1 replaces Memory 2 (newer information makes older obsolete)
- "refines": Memory 1 adds detail to Memory 2 (elaborates without replacing)
- "unrelated": No meaningful relationship

Return only the classification word, nothing else.
```

## Variables

| Variable | Type | Description |
|----------|------|-------------|
| `memory_new` | string | The newer memory content |
| `memory_old` | string | The older memory content |

## Output

Single word: `supersedes`, `refines`, or `unrelated`

## Relationship Definitions

### supersedes
The new memory REPLACES the old memory. The old information is now outdated, incorrect, or no longer relevant.

**Examples:**
- "Alice works at Acme Corp" → "Alice now works at Beta Inc" (job change)
- "Project due on Feb 1" → "Project due date extended to Feb 15" (date change)
- "Bob prefers coffee" → "Bob switched to tea" (preference change)

### refines
The new memory ADDS DETAIL to the old memory. Both remain true, but the new one provides additional context or specificity.

**Examples:**
- "Alice works at Acme" → "Alice is a senior engineer at Acme" (role detail)
- "Meeting scheduled for Monday" → "Monday meeting will be in Conference Room A" (location added)
- "Project is in progress" → "Project reached 80% completion" (status update)

### unrelated
The memories discuss different topics, entities, or timeframes with no meaningful connection.

**Examples:**
- "Alice works at Acme" vs "The weather was nice yesterday"
- "Project Alpha launched" vs "Bob's birthday is in March"
- "Team standup at 9am" vs "Recipe for pasta carbonara"

## Decision Tree

```
┌─────────────────────────────────────────────────────────────┐
│ Do both memories discuss the same entity/topic?            │
└───────────────────────────┬─────────────────────────────────┘
                            │
              ┌─────────────┴─────────────┐
              │ NO                        │ YES
              ▼                           ▼
        ┌───────────┐         ┌───────────────────────────────┐
        │ unrelated │         │ Does new info contradict old? │
        └───────────┘         └───────────────┬───────────────┘
                                              │
                                ┌─────────────┴─────────────┐
                                │ YES                       │ NO
                                ▼                           ▼
                          ┌───────────┐         ┌───────────────────┐
                          │ supersedes│         │ Does new info add │
                          └───────────┘         │ detail to old?    │
                                                └─────────┬─────────┘
                                                          │
                                            ┌─────────────┴─────────┐
                                            │ YES                   │ NO
                                            ▼                       ▼
                                      ┌─────────┐             ┌───────────┐
                                      │ refines │             │ unrelated │
                                      └─────────┘             └───────────┘
```

## Edge Cases

### Temporal Context
- If both memories are about events at different times, they're usually `unrelated` or `refines`, not `supersedes`
- "Meeting on Monday" and "Meeting on Tuesday" might be different meetings (`unrelated`) or a rescheduling (`supersedes`)

### Partial Overlap
- If new memory covers broader scope including old memory's topic, it might `refine` or be `unrelated`
- Look for clear semantic connection

### Confidence/Source
- Don't consider confidence scores when classifying
- A low-confidence new memory can still supersede a high-confidence old one

## Examples

| Memory 1 (new) | Memory 2 (old) | Classification |
|----------------|----------------|----------------|
| "Alice is the CTO of Acme" | "Alice works at Acme" | refines |
| "Alice left Acme in 2024" | "Alice works at Acme" | supersedes |
| "Bob's meeting moved to 3pm" | "Bob has a meeting at 2pm today" | supersedes |
| "The project uses PostgreSQL" | "The project needs a database" | refines |
| "Alice likes morning runs" | "Bob prefers evening walks" | unrelated |

## Notes

- When in doubt between `refines` and `unrelated`, prefer `unrelated`
- When in doubt between `supersedes` and `refines`, prefer `refines`
- This classification is used to maintain memory validity over time
