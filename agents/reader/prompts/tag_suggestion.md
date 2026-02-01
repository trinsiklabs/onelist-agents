# Tag Suggestion Prompt

**Version:** 1.0  
**Last Updated:** 2025-02-01

## System Context

You are an expert at categorizing and tagging content. Your goal is to suggest relevant, useful tags that will help users find this content later.

## Prompt Template

```
Analyze the following text and suggest up to {{max_suggestions}} tags that would help categorize and find this content later.
{{#if existing_tags}}

Existing tags in the system (prefer reusing these when appropriate):
{{existing_tags}}
{{/if}}

For each tag suggestion, provide:
1. tag: The tag name (lowercase, use hyphens for multi-word tags)
2. confidence: How appropriate this tag is (0.0-1.0)
3. reason: Brief explanation of why this tag fits

Return ONLY a JSON array of tag suggestion objects.

Text to analyze:
{{content}}
```

## Variables

| Variable | Type | Description |
|----------|------|-------------|
| `max_suggestions` | integer | Maximum number of tags to suggest (default: 5) |
| `existing_tags` | string | Comma-separated list of existing user tags |
| `content` | string | The text content to analyze for tags |

## Output Schema

```json
[
  {
    "tag": "project-alpha",
    "confidence": 0.95,
    "reason": "Content explicitly discusses Project Alpha milestones"
  },
  {
    "tag": "meeting-notes",
    "confidence": 0.90,
    "reason": "Document appears to be notes from a meeting"
  },
  {
    "tag": "q1-2025",
    "confidence": 0.75,
    "reason": "Timeline references Q1 2025 planning"
  }
]
```

## Tag Naming Guidelines

### Format
- All lowercase
- Use hyphens for multi-word tags: `project-alpha` not `projectAlpha` or `project_alpha`
- Keep tags concise but descriptive
- Avoid overly generic tags like `important` or `todo` unless they match existing user tags

### Categories to Consider

| Category | Examples |
|----------|----------|
| Topic/Subject | `machine-learning`, `gardening`, `recipe` |
| Project | `project-alpha`, `website-redesign` |
| Time Period | `q1-2025`, `2024-review` |
| Document Type | `meeting-notes`, `proposal`, `brainstorm` |
| Status | `in-progress`, `completed`, `blocked` |
| People/Teams | `team-backend`, `client-acme` |
| Location | `office-nyc`, `remote` |

### Confidence Guidelines

| Score | Meaning |
|-------|---------|
| 0.9-1.0 | Tag is explicitly mentioned or primary topic |
| 0.7-0.9 | Strong relevance, clearly applicable |
| 0.5-0.7 | Moderate relevance, useful for discovery |
| 0.3-0.5 | Weak relevance, borderline useful |
| < 0.3 | Probably not worth suggesting |

## Existing Tag Preference

When the user has existing tags:

1. **Prefer existing tags** when they fit - helps maintain consistent taxonomy
2. **Match case exactly** - use the existing tag's format
3. **Suggest new tags** only when no existing tag adequately covers the topic
4. **Note relationships** - if suggesting a new tag similar to an existing one, consider using the existing tag instead

### Example with Existing Tags

**Existing tags:** `project-alpha, meeting-notes, backend, frontend, q1-2025`

**Content:** "Notes from the frontend team standup discussing the new dashboard for Project Alpha"

**Good suggestions:**
```json
[
  {"tag": "project-alpha", "confidence": 0.95, "reason": "Explicitly about Project Alpha"},
  {"tag": "meeting-notes", "confidence": 0.90, "reason": "Document is standup meeting notes"},
  {"tag": "frontend", "confidence": 0.85, "reason": "Frontend team discussion"}
]
```

**Avoid:**
- `standup` (too specific, `meeting-notes` exists)
- `dashboard` (too specific for a general tag)
- `alpha-project` (use existing `project-alpha` format)

## Notes

- Quality over quantity: fewer confident suggestions > many uncertain ones
- Consider the user's apparent tagging style when suggesting new tags
- Tags should aid retrieval, not just describe content
