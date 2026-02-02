# Onelist Memory Sync Plugin

**Version:** 0.5.1 (Hardened Edition)  
**Last Updated:** 2026-02-01

## Overview

This plugin provides two features:
1. **Auto-inject Recovery** — Automatically injects recent conversation context on session start
2. **Onelist Sync** — Streams messages to Onelist for persistent memory extraction

## Defense Layers (v0.5.0+)

| Layer | Protection | Description |
|-------|-----------|-------------|
| 1 | Session Pre-check | Skip if session already has injection marker |
| 2 | Injection Count | Max 2 injections per session (persistent) |
| 3 | Rate Limiting | 60s cooldown between injections (file-based) |
| 4 | Size Check | Skip if session > 500KB or > 200 messages |
| 5 | Content Blocklist | Skip messages with recovery markers |

## Changelog

### v0.5.1 — Hardened Edition
- Persistent state file location
- State pruning (7-day, 100 sessions max)  
- Onelist circuit breaker
- Memory leak fixes
- Health logging

### v0.5.0 — Defense in Depth
- Five-layer protection
- Survives gateway restarts

### v0.4.0
- Depth marker
- Rate limiting (in-memory, insufficient)

### v0.3.0  
- Message-level blocklist
- Output circuit breaker

## Monitoring

```bash
/root/scripts/stream-health-check.sh
```

## Emergency: Disable Auto-inject

```bash
sed -i 's/"autoInjectEnabled": true/"autoInjectEnabled": false/' /root/.openclaw/openclaw.json
/root/bump-stream.sh
```
