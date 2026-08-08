#!/usr/bin/env bash
# pi-yaml-hooks notify script: desktop alerts for interactive interruptions
# (rpiv ask_user_question / permission asks / goal-loop drafts / subagent
# checkpoints) and turn completion (session.idle).
#
# Two delivery channels:
#   1) Ghostty native notification (OSC 9, written to /dev/tty) — pi-yaml-hooks
#      captures the hook's stdout/stderr (stdio: ignore/pipe/ignore), so the
#      escape sequence must go through /dev/tty to reach the ghostty PTY.
#   2) noctalia desktop notification (notify-send -> org.freedesktop.Notifications)
#
# Focus gate (niri): only notify when the pi window is NOT focused, so sitting
# at the terminal never spams. Fail-open: if niri or parsing fails, notify anyway.
set -uo pipefail

payload="$(cat)"

# ── Focus gate: skip when the pi window has focus ──
if [ "${PI_HOOKS_FOCUS_CHECK:-1}" != "0" ]; then
	focus="$(niri msg windows 2>/dev/null | awk '
    /\(focused\)/ { f = 1; next }
    f && /App ID:/ { app = $3; gsub(/"/, "", app) }
    f && /Title:/ { t = $0; sub(/^ *Title: "/, "", t); sub(/"$/, "", t) }
    f && app != "" && t != "" { print app "|" t; exit }
  ')"

	if [ -n "$focus" ]; then
		fapp="${focus%%|*}"
		ftitle="${focus#*|}"
		want_app="${PI_HOOKS_FOCUS_APP_ID:-com.mitchellh.ghostty}"
		want_prefix="${PI_HOOKS_FOCUS_TITLE_PREFIX:-π}"
		if [ "$fapp" = "$want_app" ] && [ "${ftitle#"$want_prefix"}" != "$ftitle" ]; then
			exit 0 # pi window focused — user is at the terminal
		fi
	fi
fi

event="$(printf '%s' "$payload" | jq -r '.event // ""')"

title=""
body=""
case "$event" in
# ── Turn/conversation complete (session.idle): cooldown prevents spam ──
session.idle)
	cooldown="${PI_HOOKS_IDLE_COOLDOWN_S:-120}"
	stamp="${XDG_CACHE_HOME:-$HOME/.cache}/pi-hooks-idle.ts"
	now="$(date +%s)"
	if [ -f "$stamp" ]; then
		last="$(cat "$stamp" 2>/dev/null || echo 0)"
		if [ "$((now - last))" -lt "$cooldown" ]; then
			exit 0
		fi
	fi
	mkdir -p "$(dirname "$stamp")"
	printf '%s' "$now" >"$stamp"
	files="$(printf '%s' "$payload" | jq -r '[.files[]?] | join(", ")')"
	title="✅ Pi turn complete"
	if [ -n "$files" ]; then
		body="Changed: $files"
	else
		body="No files changed"
	fi
	;;

# ── Everything else dispatches by tool name ──
*)
	tool_name="$(printf '%s' "$payload" | jq -r '.tool_name // ""')"
	case "$tool_name" in
	# rpiv-ask-user-question: TUI questionnaire
	ask_user_question)
		title="❓ Pi is waiting for your answer"
		body="$(printf '%s' "$payload" | jq -r '[.tool_args.questions[]?.question] | join("  |  ")')"
		;;

	# pi-permission-system: only alert for commands that trigger an ask
	# confirmation (keep in sync with the ask rules)
	bash)
		command="$(printf '%s' "$payload" | jq -r '.tool_args.command // ""')"
		if ! printf '%s' "$command" | grep -qE '(^|[;&|]|\s)(sudo|rm[[:space:]]+-rf|git[[:space:]]+push)([[:space:]]|$)'; then
			exit 0
		fi
		title="🔐 Pi needs your confirmation"
		body="$command"
		;;

	# pi-goal-list-loop-audit / pi core: draft confirmation dialogs
	propose_goal_draft | propose_loop_draft | propose_task_list | propose_loop_refine)
		title="🎯 Draft needs confirmation"
		body="$(printf '%s' "$payload" | jq -r '.tool_args.objective // .tool_args.target // .tool_args.rationale // ""')"
		;;

	# pi-subagents: checkpoint approval / clarify preview
	subagent)
		action="$(printf '%s' "$payload" | jq -r '.tool_args.action // ""')"
		clarify="$(printf '%s' "$payload" | jq -r '.tool_args.clarify // false')"
		if [ "$action" = "approve-checkpoint" ] || [ "$action" = "reject-checkpoint" ]; then
			title="🤖 Subagent checkpoint needs approval"
			body="$(printf '%s' "$payload" | jq -r '.tool_args.id // ""')"
		elif [ "$clarify" = "true" ]; then
			title="🤖 Subagent awaiting your confirmation"
			body="$(printf '%s' "$payload" | jq -r '.tool_args.agent // ""')"
		else
			exit 0
		fi
		;;

	*) exit 0 ;;
	esac
	;;
esac

[ -n "$body" ] || body="Check the terminal"
# Notifications don't suit multi-line/long text: single-line + truncate
body="$(printf '%s' "$body" | tr '\n\r' '  ' | cut -c1-180)"

# ── 1) Ghostty native notification (OSC 9) ──
if { [ -e /dev/tty ] && [ -w /dev/tty ]; } 2>/dev/null; then
	{ printf '\033]9;%s: %s\033\\' "$title" "$body" >/dev/tty; } 2>/dev/null || true
fi

# ── 2) noctalia desktop notification ──
notify-send -u critical -a "pi-hooks" "$title" "$body" >/dev/null 2>&1 || true

exit 0
