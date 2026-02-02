# River Agent V2 Implementation Plan

## External Agent Coordination Integration

**Date**: 2026-02-02
**Status**: Planning
**Dependencies**: Multi-Agent Coordination Plan V2

---

## Overview

This plan describes the implementation work required in the onelist-agents repository to support the Multi-Agent Coordination V2 features. River becomes the orchestration hub for external agents (Claude Code, OpenClaw) while participating in the GTD-based task management system.

---

## 1. Current State Assessment

### 1.1 Existing Structure

```
onelist-agents/
├── agents/
│   ├── reader/
│   │   ├── config/reader.exs
│   │   └── prompts/
│   └── searcher/
│       ├── config/searcher.exs
│       └── prompts/
├── docs/
│   ├── river.md              # Basic spec
│   ├── reader.md
│   ├── searcher.md
│   └── asset-enrichment.md
└── README.md
```

### 1.2 What Exists

- River specification document (basic)
- Reader prompts for memory extraction
- Searcher prompts for query reformulation
- Configuration templates for Reader and Searcher

### 1.3 What's Missing

- River agent directory with full implementation artifacts
- External agent coordination prompts
- GTD-aware prompts and configurations
- Task assignment and relationship prompts
- Agent-to-agent coordination protocols

---

## 2. Target State

### 2.1 Proposed Structure

```
onelist-agents/
├── agents/
│   ├── reader/
│   │   ├── config/reader.exs
│   │   └── prompts/
│   ├── searcher/
│   │   ├── config/searcher.exs
│   │   └── prompts/
│   └── river/                              # NEW
│       ├── README.md
│       ├── config/
│       │   ├── river.exs                   # Core configuration
│       │   ├── gtd.exs                     # GTD settings
│       │   ├── external_agents.exs         # Agent coordination config
│       │   └── verification.exs            # Completion verification
│       ├── prompts/
│       │   ├── core/
│       │   │   ├── soul.md                 # River personality
│       │   │   ├── intent_classification.md
│       │   │   ├── entity_extraction.md
│       │   │   └── response_generation.md
│       │   ├── gtd/
│       │   │   ├── task_clarification.md
│       │   │   ├── bucket_suggestion.md
│       │   │   ├── context_suggestion.md
│       │   │   ├── project_discovery.md
│       │   │   └── review_guidance.md
│       │   ├── coordination/
│       │   │   ├── agent_status.md
│       │   │   ├── task_assignment.md
│       │   │   ├── workload_analysis.md
│       │   │   └── conflict_resolution.md
│       │   └── relationships/
│       │       ├── dependency_analysis.md
│       │       ├── blocking_chain.md
│       │       └── project_summary.md
│       └── schemas/
│           ├── intent.json                 # Intent classification schema
│           ├── entities.json               # Entity extraction schema
│           ├── task.json                   # GTD task schema
│           └── agent_registration.json     # Agent registration schema
├── docs/
│   ├── river.md                            # UPDATED
│   ├── river-external-agents.md            # NEW
│   ├── river-gtd.md                        # NEW
│   └── ...
└── README.md                               # UPDATED
```

---

## 3. Implementation Tasks

### Phase 1: Core River Structure (Week 1)

#### 3.1.1 Create River Agent Directory

```bash
mkdir -p agents/river/{config,prompts/{core,gtd,coordination,relationships},schemas}
```

#### 3.1.2 Create Core Prompts

**`prompts/core/soul.md`**

```markdown
# River Soul

You are River, the user's intelligent life operations assistant for Onelist.

## Core Identity

You embody the GTD "mind like water" philosophy—helping users achieve mental
clarity through a trusted external system that captures everything.

## Communication Style

- Direct and concise, no filler phrases
- Warm but not effusive
- Use humor sparingly and naturally
- Admit uncertainty honestly
- Never say "Great question!" or "I'd be happy to help!"

## Boundaries

- Never execute destructive operations without confirmation
- Always explain what you're about to do before doing it
- Respect user's stated preferences over your defaults
- Don't over-explain or be condescending

## Capabilities

You can:
- Search and synthesize information from the user's knowledge base
- Create, update, and complete tasks following GTD methodology
- Assign tasks to external agents (Claude Code, OpenClaw)
- Monitor agent activity and task progress
- Provide briefings and status updates
- Guide users through GTD reviews

## External Agents

You coordinate with external AI agents that help the user:
- Claude Code: Coding assistant in terminal environments
- OpenClaw: AI assistant with specialized subagents

You can assign tasks to these agents and monitor their progress.
```

**`prompts/core/intent_classification.md`**

```markdown
# Intent Classification

Classify the user's intent from their message.

## Intents

| Intent | Description | Examples |
|--------|-------------|----------|
| `search` | Find information | "What did I note about...", "Find my..." |
| `create_task` | Add a new task | "Remind me to...", "I need to...", "Add task..." |
| `complete_task` | Mark task done | "Mark X complete", "Done with X" |
| `list_tasks` | Show tasks | "What's on my list?", "Show my tasks" |
| `assign_task` | Assign to agent | "Assign X to Claude Code" |
| `agent_status` | Check agent | "What is Claude Code working on?" |
| `briefing` | Get summary | "Give me a briefing", "What's my status?" |
| `review` | GTD review | "Let's do weekly review" |
| `project` | Project ops | "What projects am I working on?" |
| `chat` | General conversation | Anything else |

## Output Format

```json
{
  "intent": "string",
  "confidence": 0.0-1.0,
  "sub_intent": "optional_string"
}
```

## Examples

User: "What meetings do I have tomorrow?"
→ {"intent": "search", "confidence": 0.95, "sub_intent": "calendar"}

User: "Assign the auth refactor to Claude Code"
→ {"intent": "assign_task", "confidence": 0.98, "sub_intent": null}

User: "What's Claude Code working on?"
→ {"intent": "agent_status", "confidence": 0.95, "sub_intent": null}
```

**`prompts/core/entity_extraction.md`**

```markdown
# Entity Extraction

Extract structured entities from the user's message.

## Entity Types

| Type | Description | Examples |
|------|-------------|----------|
| `date` | Temporal reference | "tomorrow", "next week", "Jan 15" |
| `task_reference` | Task mention | "the auth task", "that refactor" |
| `project_reference` | Project mention | "the website project" |
| `agent_reference` | Agent mention | "Claude Code", "OpenClaw", "the researcher" |
| `person_reference` | Person mention | "Sarah", "the design team" |
| `tag` | Explicit or implicit tag | "#urgent", "meeting notes" |
| `context` | GTD context | "@computer", "@phone" |
| `bucket` | GTD bucket | "inbox", "next actions" |

## Output Format

```json
{
  "entities": [
    {
      "type": "string",
      "value": "extracted_value",
      "text": "original_text",
      "confidence": 0.0-1.0
    }
  ]
}
```

## Examples

User: "Assign the auth refactor to Claude Code - MacBook"
→ {
  "entities": [
    {"type": "task_reference", "value": "auth refactor", "text": "the auth refactor", "confidence": 0.9},
    {"type": "agent_reference", "value": "claude-code-macbook", "text": "Claude Code - MacBook", "confidence": 0.95}
  ]
}
```

#### 3.1.3 Create Configuration Templates

**`config/river.exs`**

```elixir
# River Agent Configuration

config :onelist, Onelist.River,
  # LLM Settings
  response_model: "claude-sonnet-4-20250514",
  intent_model: "claude-haiku-3-20240307",

  # Context Settings
  max_context_messages: 20,
  max_search_results: 10,

  # Features
  enable_gtd: true,
  enable_external_agents: true,
  enable_proactive: true,

  # Rate Limits
  max_messages_per_minute: 20,
  max_tool_calls_per_turn: 5

config :onelist, Onelist.River.Chat,
  session_timeout_minutes: 60,
  context_window_messages: 10

config :onelist, Onelist.River.Proactive,
  tick_interval_seconds: 900,  # 15 minutes
  enable_morning_briefing: true,
  enable_review_reminders: true
```

**`config/external_agents.exs`**

```elixir
# External Agent Coordination Configuration

config :onelist, Onelist.River.ExternalAgents,
  # Agent Types
  known_agent_types: [
    %{
      id: "claude-code",
      name: "Claude Code",
      capabilities: ["coding", "debugging", "refactoring", "documentation"],
      preferred_contexts: ["@computer"]
    },
    %{
      id: "openclaw",
      name: "OpenClaw",
      capabilities: ["research", "writing", "analysis"],
      preferred_contexts: ["@computer"],
      supports_subagents: true
    }
  ],

  # Person Entry Settings
  granularity: "full",  # type_only, instances, full
  instance_naming: "machine_name",
  subagent_naming: "role_parent",

  # Health Monitoring
  offline_threshold_minutes: 60,
  stalled_task_threshold_hours: 2,

  # Task Assignment
  auto_assign_enabled: false,
  auto_assign_confidence_threshold: 0.7

config :onelist, Onelist.River.TaskAssignment,
  # Claiming
  claim_lock_timeout_seconds: 30,

  # Verification
  default_verification_mode: "auto_with_evidence",
  require_confirmation_for: ["high_priority", "has_dependencies"],
  auto_confirm_contexts: ["@energy:low"]
```

### Phase 2: GTD Prompts (Week 2)

#### 3.2.1 GTD Prompts

**`prompts/gtd/task_clarification.md`**

```markdown
# Task Clarification

Help the user clarify vague inputs into concrete, actionable tasks.

## GTD Principles

1. Every task should start with a verb
2. Tasks should be specific and physical
3. "Think about X" is not a task—what's the actual next action?

## Clarification Questions

For vague input, ask:
- "What's the very next physical action?"
- "What does 'done' look like?"
- "Is this a single action or a project with multiple steps?"

## Transformation Examples

| User Input | Clarified Task |
|------------|----------------|
| "Mom's birthday" | "What's the next action? Buy gift? Plan party? Call her?" |
| "Website stuff" | "Can you be more specific? What exactly needs to happen?" |
| "Think about career" | "This seems like reflection. What concrete step could you take?" |
| "Call John about project" | ✓ Good! This is already actionable. |

## Output Format

```json
{
  "is_actionable": true/false,
  "clarification_needed": true/false,
  "clarification_question": "optional question",
  "suggested_task": {
    "title": "Verb + specific action",
    "context": "@suggested_context",
    "bucket": "suggested_bucket"
  }
}
```
```

**`prompts/gtd/project_discovery.md`**

```markdown
# Project Discovery

Help identify which project the user's work relates to.

## Context Available

- Current working directory: {{working_directory}}
- Git remote (if available): {{git_remote}}
- Recent session history: {{recent_sessions}}
- Active projects: {{active_projects}}

## Discovery Logic

1. Check for exact directory match in project bindings
2. Match git remote to known projects
3. Fuzzy match directory name to project names
4. Check recent activity in this directory

## Response Format

```json
{
  "suggested_project": {
    "id": "project-uuid",
    "name": "Project Name",
    "confidence": 0.0-1.0,
    "reason": "directory_match|git_remote|name_match|recent_activity"
  },
  "alternative_projects": [...],
  "suggest_new_project": true/false,
  "suggested_new_project_name": "optional"
}
```

## User Prompt

If confidence < 0.85, prompt user:
"What are you working on today?

Suggested: {{suggested_project.name}} ({{reason}})

Your active projects:
{{project_list}}

Or: Start a new project / No project"
```

#### 3.2.2 Review Guidance Prompts

**`prompts/gtd/review_guidance.md`**

```markdown
# GTD Review Guidance

Guide the user through GTD reviews.

## Weekly Review Phases

### Phase 1: GET CLEAR
- Process inbox to zero
- Capture anything still on your mind
- Review loose notes and voicemails

### Phase 2: GET CURRENT
- Review each active project
- Review Next Actions lists
- Review Waiting For items
- Review calendar (past and upcoming)

### Phase 3: GET CREATIVE
- Review Someday/Maybe
- Review goals
- Brainstorm new ideas

## Prompts by Phase

Phase 1:
"Let's start by clearing your inbox. You have {{inbox_count}} items.
Would you like to process them now, or skip to reviewing projects?"

Phase 2:
"Now let's review your active projects. You have {{project_count}} projects.
{{stale_projects}} haven't had activity in over 2 weeks.
Should we start with those?"

Phase 3:
"Finally, let's look at your Someday/Maybe list.
Any items ready to become active projects?
{{someday_count}} items to review."

## Completion

"Weekly review complete!
- Processed {{inbox_processed}} inbox items
- Reviewed {{projects_reviewed}} projects
- Updated {{tasks_updated}} tasks
- Created {{tasks_created}} new tasks

Great work maintaining your trusted system!"
```

### Phase 3: Coordination Prompts (Week 3)

#### 3.3.1 Agent Coordination Prompts

**`prompts/coordination/task_assignment.md`**

```markdown
# Task Assignment

Determine the best agent to assign a task to.

## Available Agents

{{#each agents}}
### {{name}} ({{status}})
- Level: {{level}} (type/instance/subagent)
- Capabilities: {{capabilities}}
- Current workload: {{active_tasks}} active, {{completed_today}} completed today
- Preferred contexts: {{preferred_contexts}}
{{/each}}

## Task Details

- Title: {{task.title}}
- Context: {{task.context}}
- Effort: {{task.effort}}
- Priority: {{task.priority}}
- Project: {{task.project}}

## Assignment Logic

1. Match task context to agent preferred contexts
2. Match inferred task type to agent capabilities
3. Consider current workload (prefer less loaded agents)
4. Consider agent availability (prefer active over idle)

## Output Format

```json
{
  "recommended_agent": {
    "id": "agent-person-id",
    "name": "Agent Name",
    "level": "type|instance|subagent",
    "confidence": 0.0-1.0,
    "reason": "capability_match|context_match|availability"
  },
  "alternative_agents": [...],
  "assignment_level": "type|instance",
  "explanation": "Human-readable explanation"
}
```

## Assignment Levels

- **Type level** ("Claude Code"): Any active instance can claim
- **Instance level** ("Claude Code - MacBook"): Specific machine only
- **Subagent level** ("Researcher (Home Server)"): Specific subagent only
```

**`prompts/coordination/agent_status.md`**

```markdown
# Agent Status Report

Generate a status report for external agents.

## Agent Information

{{#each agents}}
### {{name}}
- Status: {{health_status}} (active/idle/offline)
- Last seen: {{last_seen}}
- Active tasks: {{active_tasks}}
- Completed today: {{completed_today}}
{{#if instances}}
Instances:
{{#each instances}}
  - {{name}}: {{status}}, {{active_tasks}} active
{{/each}}
{{/if}}
{{/each}}

## Summary Generation

Create a natural language summary:
- Which agents are active
- What they're working on
- Any concerns (offline agents with tasks, stalled work)

## Example Output

"Claude Code is active on your MacBook Pro, working on 2 tasks including
'Refactor auth module'. OpenClaw's home server instance is idle—no active
tasks assigned. The VPS instance hasn't been seen in 3 hours but has no
pending work."
```

**`prompts/coordination/conflict_resolution.md`**

```markdown
# Task Conflict Resolution

Handle situations where multiple agents attempt conflicting operations.

## Conflict Types

1. **Claim conflict**: Multiple instances trying to claim same task
2. **Edit conflict**: Agents modifying same entry simultaneously
3. **Dependency conflict**: Agent trying to complete blocked task

## Resolution Strategies

### Claim Conflict
- First successful lock wins
- Notify other agents of claim
- Suggest alternative tasks

### Edit Conflict
- Last-write-wins with merge attempt
- Flag for user review if content differs significantly
- Create conflict entry for manual resolution

### Dependency Conflict
- Block completion
- Show blocking chain
- Suggest working on blockers first

## User Communication

"I noticed a conflict: both Claude Code instances tried to claim 'Update API docs'.
The MacBook instance got there first. I've suggested 'Write test cases' to the
Work Laptop instance instead."
```

### Phase 4: Relationship Prompts (Week 4)

#### 3.4.1 Dependency Analysis

**`prompts/relationships/dependency_analysis.md`**

```markdown
# Dependency Analysis

Analyze task dependencies and blocking chains.

## Task Information

- Task: {{task.title}}
- Status: {{task.status}}
- Project: {{task.project}}

## Direct Dependencies

{{#each dependencies}}
- {{title}} ({{status}}) - {{relationship_type}}
{{/each}}

## Analysis Questions

1. Is this task blocked? (any incomplete depends_on)
2. What's the critical path to completion?
3. Are there circular dependencies?
4. What tasks will be unblocked when this completes?

## Output Format

```json
{
  "is_blocked": true/false,
  "blockers": [
    {"id": "...", "title": "...", "status": "...", "depth": 1}
  ],
  "critical_path": ["task-id-1", "task-id-2", "..."],
  "will_unblock": ["task-id-a", "task-id-b"],
  "circular_dependency": false,
  "summary": "Human-readable summary"
}
```

## Example Summary

"This task is blocked by 'Design API schema' which is waiting on Sarah.
Once that's done, this task and 2 others can proceed. Completing this
will unblock 'Write integration tests'."
```

**`prompts/relationships/project_summary.md`**

```markdown
# Project Summary

Generate a comprehensive project status summary.

## Project Information

- Name: {{project.name}}
- Status: {{project.status}}
- Domain: {{project.domain}}

## Tasks

- Total: {{tasks.total}}
- Completed: {{tasks.completed}}
- In Progress: {{tasks.in_progress}}
- Blocked: {{tasks.blocked}}
- Pending: {{tasks.pending}}

## Agent Involvement

{{#each agents}}
- {{name}}: {{completed}} completed, {{active}} active
{{/each}}

## Recent Activity

{{#each recent_activity}}
- {{timestamp}}: {{description}}
{{/each}}

## Summary Generation

Create a briefing that includes:
1. Overall progress percentage
2. Current blockers and who can resolve them
3. Agent contributions
4. Estimated completion (if effort estimates available)
5. Risks or concerns

## Example Output

"Website Redesign is 65% complete (13/20 tasks).

Current blockers:
- 'Brand guidelines' waiting on Sarah (3 days overdue)
- This blocks 2 other tasks

Agent activity:
- Claude Code completed 5 tasks this week
- No tasks currently assigned to external agents

Risk: Timeline may slip if brand guidelines aren't received by Friday."
```

### Phase 5: Schemas and Validation (Week 5)

#### 3.5.1 JSON Schemas

**`schemas/intent.json`**

```json
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "title": "Intent Classification",
  "type": "object",
  "required": ["intent", "confidence"],
  "properties": {
    "intent": {
      "type": "string",
      "enum": [
        "search", "create_task", "complete_task", "list_tasks",
        "assign_task", "agent_status", "briefing", "review",
        "project", "chat"
      ]
    },
    "confidence": {
      "type": "number",
      "minimum": 0,
      "maximum": 1
    },
    "sub_intent": {
      "type": "string"
    }
  }
}
```

**`schemas/agent_registration.json`**

```json
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "title": "Agent Registration",
  "type": "object",
  "required": ["agent_id", "instance_id"],
  "properties": {
    "agent_id": {
      "type": "string",
      "description": "Agent type identifier (e.g., 'claude-code')"
    },
    "instance_id": {
      "type": "string",
      "description": "Unique instance identifier"
    },
    "instance_name": {
      "type": "string",
      "description": "Human-readable instance name"
    },
    "machine_identifier": {
      "type": "string",
      "description": "Machine hostname or identifier"
    },
    "capabilities": {
      "type": "array",
      "items": {"type": "string"}
    },
    "working_directories": {
      "type": "array",
      "items": {"type": "string"}
    },
    "subagent_name": {
      "type": "string",
      "description": "For subagents, the role name"
    },
    "parent_instance_id": {
      "type": "string",
      "description": "For subagents, the parent clawbot instance"
    }
  }
}
```

**`schemas/task.json`**

```json
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "title": "GTD Task",
  "type": "object",
  "required": ["title"],
  "properties": {
    "title": {
      "type": "string",
      "minLength": 1,
      "maxLength": 255
    },
    "description": {
      "type": "string"
    },
    "bucket": {
      "type": "string",
      "enum": ["inbox", "next_actions", "waiting_for", "someday_maybe"],
      "default": "inbox"
    },
    "context": {
      "type": "string",
      "pattern": "^@[a-z_:]+$"
    },
    "status": {
      "type": "string",
      "enum": ["open", "in_progress", "completed", "cancelled"],
      "default": "open"
    },
    "due_date": {
      "type": "string",
      "format": "date"
    },
    "effort_estimate": {
      "type": "string",
      "enum": ["xs", "s", "m", "l", "xl"]
    },
    "priority": {
      "type": "string",
      "enum": ["low", "normal", "high", "urgent"],
      "default": "normal"
    },
    "project_id": {
      "type": "string",
      "format": "uuid"
    },
    "assigned_to_agent_id": {
      "type": "string",
      "format": "uuid"
    }
  }
}
```

---

## 4. Documentation Updates

### 4.1 Update docs/river.md

Add sections:
- External Agent Coordination
- GTD Integration
- Task Assignment
- Agent Health Monitoring

### 4.2 New Documentation Files

**`docs/river-external-agents.md`**

Complete guide to River's external agent coordination:
- Agent registration process
- Task assignment flow
- Claiming mechanism
- Health monitoring
- Conflict resolution

**`docs/river-gtd.md`**

GTD integration documentation:
- Bucket management
- Context usage
- Review workflows
- Project binding

---

## 5. Implementation Schedule

| Week | Phase | Deliverables |
|------|-------|--------------|
| 1 | Core Structure | Directory structure, core prompts, base config |
| 2 | GTD Prompts | Task clarification, project discovery, review guidance |
| 3 | Coordination | Agent status, task assignment, conflict resolution |
| 4 | Relationships | Dependency analysis, blocking chains, project summaries |
| 5 | Schemas | JSON schemas, validation, documentation |
| 6 | Testing | Prompt testing, integration verification |

---

## 6. Testing Plan

### 6.1 Prompt Testing

Each prompt should be tested with:
- Happy path examples
- Edge cases
- Ambiguous inputs
- Multi-intent messages

### 6.2 Integration Testing

Test with:
- Multiple simultaneous Claude Code instances
- OpenClaw with subagents
- Mixed agent task assignment
- Conflict scenarios

### 6.3 Regression Testing

Ensure existing functionality unchanged:
- Basic chat
- Search queries
- Task creation
- Reader integration
- Searcher integration

---

## 7. Success Criteria

- [ ] All prompts produce valid, parseable output
- [ ] Agent registration creates correct person entries
- [ ] Task assignment works at all granularity levels
- [ ] Claiming prevents race conditions
- [ ] GTD workflows function correctly
- [ ] Documentation complete and accurate

---

## Related Documents

- [River Agent Plan (Section 39)](../../onelist.com/roadmap/river_agent_plan.md)
- [Multi-Agent Coordination Plan V2](../../onelist-local/docs/MULTI_AGENT_COORDINATION_PLAN_V2.md)
- [Multi-Agent Memory Analysis](../../onelist-local/docs/MULTI_AGENT_MEMORY_ANALYSIS.md)
