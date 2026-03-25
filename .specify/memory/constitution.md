<!--
Sync Impact Report:
- Version change: 1.0.0 -> 1.1.0
- Modified principles: yes (aligned to DayTill core product values)
- Added sections: Core Principles refined for offline-first mobile, additional constraints tuned for local storage and lightweight notifications
- Removed sections: legacy generic placeholders replaced
- Templates requiring updates:
  - .specify/templates/plan-template.md (✅ reviewed, no structural change needed)
  - .specify/templates/spec-template.md (✅ reviewed)
  - .specify/templates/tasks-template.md (✅ reviewed)
  - .github/agents/speckit.constitution.agent.md (✅ reviewed)
- Follow-up TODOs: none
-->

# day-till Constitution

## Core Principles

### 1. Simplicity First
Design MUST prefer minimal viable implementations and avoid overengineering. Proof-of-concept quality is acceptable for early features; iterative hardening is accepted only after user validation.

Rationale: Simplicity enables rapid experimentation and keeps scope manageable for an offline-first mobile app.

### 2. Offline-First
The app MUST function without network connectivity. Core behavior and data access MUST work fully offline; any sync workflows are optional and degrade gracefully.

Rationale: The product promise is usable anytime, anywhere with unreliable networks.

### 3. Fast, Responsive UI
UI interactions MUST feel instantaneous and maintain 60fps responsiveness on target devices. Busy operations MUST run off the main thread and include progress signals.

Rationale: Performance is critical for user retention and perceived quality.

### 4. Clean, Minimal UX
User interfaces MUST be uncluttered, intuitive, and avoid unnecessary friction. Features should be discoverable through clear signposting and defaults.

Rationale: Low cognitive overhead is essential for daily planning tools.

### 5. Modular and Extensible Code
Codebase organization MUST use small, composable modules with explicit APIs. New functionality MUST be addable with minimal changes to existing modules.

Rationale: Modularity reduces maintenance cost and enables future enhancements.

### 6. Core Functionality First
Priority is assigned to a small set of core features; additional features are blocked until core scenarios are stable and verified.

Rationale: Focus avoids scope creep and improves release predictability.

### 7. Local Storage Persistence
Data MUST be persisted locally using device storage (e.g., SQLite, file, local database). Persistence flows MUST be deterministic and recoverable after app restart.

Rationale: No backend dependency is a key product constraint.

### 8. Reliable, Lightweight Notifications
Notifications MUST be dependable and low-overhead, using platform-appropriate local notification APIs. They MUST avoid expensive background work and preserve battery life.

Rationale: Timely alerts are part of the core UX; resource efficiency preserves device usability.

## Additional Constraints

- Architecture: Mobile-first and offline-first with no mandatory backend; implementation SHOULD use Flutter for cross-platform consistency.
- Storage: Local persistence in secure storage; no sensitive data sent outside device without explicit opt-in.
- Offline behavior: No feature can require connectivity for core flows; network-dependent enhancements are opt-in.
- Resource usage: Limit memory use and CPU spikes; keep app size reasonable for mobile environments.

## Development Workflow

- Branch policy: feature branches from main; short-lived with focused granular commits.
- Review policy: PRs must include rationale tied to the core principles and a brief risk assessment.
- CI gating: Automated tests, lint, and static checks must run; the main branch must remain green.
- Definitions of done: Core scenarios pass on device/emulator, offline mode verified, and UX reviewed for minimality.
- Release: Semantic tags, release notes include offline/responsiveness tests.

## Governance

- The constitution is authoritative for feature trade-offs. Any deviation requires a documented decision and peer approval.
- Amendment: Propose via issue, update this constitution file, and require one additional reviewer. Significant principle changes require team consensus.
- Versioning: MAJOR bump on backward-incompatible governance shifts; MINOR bump on new principle or major constraint addition; PATCH for phrasing/no-op clarifications.
- Compliance: Every plan/release must include a Constitution Check matching user stories to one or more principles.

**Version**: 1.1.0 | **Ratified**: 2026-03-26 | **Last Amended**: 2026-03-26
