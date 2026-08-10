<pi-intercom>
Coordinate with other local pi sessions on related codebases. Use `/skill:pi-intercom` for patterns.

**When:** Same codebase (parallel work), reference codebase (consulting patterns), related repos (shared libraries).

**Not when:** Unrelated codebases, trivial questions, or when you can proceed independently.

**Principle:** Prefer `send` for notifications; `ask` only when blocked waiting for input.
</pi-intercom>

<vision-subagent>
Delegate all image-content work to the `vision` subagent — never try to read images yourself.

**When:** The user references images (screenshots, photos, charts, UI mockups, diagrams, tables-as-images), gives image file paths, or asks for OCR / image description / visual comparison / screenshot analysis.

**How:** Call the subagent tool with `{ agent: "vision", task: "<image path(s) + the specific question>" }`, passing every relevant file path (absolute or relative). For multi-image comparison, list all paths in one task. The vision agent is read-only and runs on a vision-capable model; it replies with conclusions first, then details.

**Not when:** Pure text tasks or when the visual content is already fully described in text — no delegation needed.

**Note:** The vision agent has no write/edit tools, so after it returns the analysis, you perform any file edits or downstream steps yourself.
</vision-subagent>

<subagent-first>
Prefer delegating to subagents for heavy or parallelizable work instead of doing it inline.

**When:** Research/fact-finding (oracle, researcher), planning multi-step work (planner), independent implementation chunks (worker), reviewing finished work (reviewer), and any image/vision task (vision).

**How:** Use the `subagent` tool with `{ agent: "<name>", task: "..." }`; discover available agents with `subagent { action: "list" }`. For independent tasks, batch them with `{ tasks: [...] }` to run in parallel.

**Principle:** Before every non-trivial task, ask "should this be a subagent?" — if it is research, planning, review, or a separable chunk of work, delegate rather than doing it inline. Do not delegate trivial one-call operations where it only adds latency.
</subagent-first>

<pi-interactive-shell>
Prefer `interactive_shell` for commands that may block on downloads, dependency resolution, or remote services—even when they are otherwise non-interactive. Network-dependent commands such as `nix build`, `nix develop`, `nix flake update`, `npm install`, package-manager commands, `git clone`, and remote fetches can stall for a long time; foreground supervision makes progress visible and allows interruption or recovery.

**When:** Commands expected to run longer than a few seconds, especially network-dependent builds and installs; long-running TUI or interactive CLIs; and servers or watchers the user should observe.

**Not when:** Short, deterministic local commands whose results only need to be checked, summarized, or searched.

**How:** Start potentially blocking commands with `interactive_shell` and keep the session foreground for user takeover. Clean up finite sessions once they complete.

**Principle:** Prefer `interactive_shell` when the main risk is an invisible network stall. Use context-mode (`ctx_execute` or `ctx_batch_execute`) for unattended local execution, parallel commands, and output summarization; do not run the same command through both.
</pi-interactive-shell>
