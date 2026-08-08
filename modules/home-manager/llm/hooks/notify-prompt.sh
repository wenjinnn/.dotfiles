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
	# confirmation. Mirror the gate's rules (declared in llm/default.nix
	# plugins."pi-permission-system".permission.bash): split the chain on
	# shell operators, strip env-var prefixes, then anchor-match each
	# command segment — same semantics as the gate's ^pattern$ + " *" glob.
	bash)
		command="$(printf '%s' "$payload" | jq -r '.tool_args.command // ""')"
		matched=""
		while IFS= read -r seg; do
			# strip env-var prefixes ("A=1 B=2 cmd") then leading whitespace
			seg="$(printf '%s' "$seg" | sed -E 's/^([A-Za-z_][A-Za-z0-9_]*=[^[:space:]]*[[:space:]]+)*//; s/^[[:space:]]+//')"
			[ -z "$seg" ] && continue
			# "cmd *" rules match "cmd" or "cmd <args>"; "git clean -f*" matches "-f<anything>"
			if printf '%s' "$seg" | grep -qE '^(rm -rf|rm -fr|git reset --hard|git push|ssh|sudo|npm publish|shutdown|reboot|poweroff|dd)([[:space:]]|$)' ||
				printf '%s' "$seg" | grep -qE '^git clean -f'; then
				matched="1"
				break
			fi
		done < <(printf '%s\n' "$command" | tr ';&|\n' '\n')
		[ -n "$matched" ] || exit 0
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

# ── Terminal channel: resolve this pi instance's PTY ──
# pi spawns tool/hook processes detached (no controlling tty), so /dev/tty is
# unusable here. Walk the PPID chain up to the pi process and write OSC
# sequences (OSC 9 ghostty notification, OSC 2 title marker) directly to its
# /dev/pts/N — that is the ghostty tab running this exact pi instance.
pi_tty=""
pid="$$"
for _ in 1 2 3 4 5 6 7 8; do
	ppid="$(ps -o ppid= -p "$pid" 2>/dev/null | tr -d ' ')"
	[ -n "$ppid" ] || break
	comm="$(ps -o comm= -p "$ppid" 2>/dev/null | tr -d ' ')"
	if [ "$comm" = "pi" ]; then
		pi_tty="$(ps -o tty= -p "$ppid" 2>/dev/null | tr -d ' ')"
		break
	fi
	pid="$ppid"
done
pty=""
if [ -n "$pi_tty" ] && [ -e "/dev/$pi_tty" ]; then
	pty="/dev/$pi_tty"
elif { [ -e /dev/tty ] && [ -w /dev/tty ]; } 2>/dev/null; then
	pty="/dev/tty"
fi

# ── 1) Ghostty native notification (OSC 9) — opt-in ──
# OSC 9 is text-only (no action button) and on Linux/GTK ghostty renders it
# through the same XDG daemon (noctalia) as notify-send, so it duplicates the
# notification below. Disabled by default; enable with PI_HOOKS_GHOSTTY_OSC9=1.
if [ "${PI_HOOKS_GHOSTTY_OSC9:-0}" = "1" ] && [ -n "$pty" ]; then
	{ printf '\033]9;%s: %s\033\\' "$title" "$body" >"$pty"; } 2>/dev/null || true
fi

# ── 2) noctalia desktop notification + "Focus Pi" action ──
# The sender window is resolved precisely via a unique OSC-2 title marker
# written to our pi's PTY (two pi instances in the same dir share title and
# ghostty PID, so title matching alone is ambiguous): mark -> resolve window
# id in niri -> restore title. notify-send -A implies --wait (prints the chosen
# action name to stdout and blocks), so the whole flow runs in a backgrounded
# subshell; the action name and resolved window id travel via temp files
# because the hook's stdout is captured.
cwd_bn=""
cwd="$(printf '%s' "$payload" | jq -r '.cwd // ""')"
[ -n "$cwd" ] || cwd="${PI_PROJECT_DIR:-}"
[ -n "$cwd" ] && cwd_bn="$(basename "$cwd" 2>/dev/null)"

out="$(mktemp /tmp/pi-hooks-action.XXXXXX 2>/dev/null || echo /tmp/pi-hooks-action.$$)"
widfile="$(mktemp /tmp/pi-hooks-wid.XXXXXX 2>/dev/null || echo /tmp/pi-hooks-wid.$$)"
(
	# 1) resolve our own window id via a unique title marker on our PTY
	marker="pi-hooks-$$-$RANDOM"
	orig="$(niri msg windows 2>/dev/null | awk '
		/Title:/ { t = $0; sub(/^ *Title: "/, "", t); sub(/"$/, "", t); if (t ~ /^π/) { print t; exit } }
	')"
	[ -n "$orig" ] || orig="π - ${cwd_bn}"
	[ -n "$pty" ] && printf '\033]2;%s [%s]\007' "$orig" "$marker" >"$pty" 2>/dev/null || true
	wid=""
	for _ in 1 2 3 4 5; do
		sleep 0.1
		wid="$(niri msg windows 2>/dev/null | awk -v m="$marker" '
			/^Window ID/ { id = $3; gsub(/:/, "", id) }
			index($0, m) > 0 { print id; exit }
		')"
		[ -n "$wid" ] && break
	done
	[ -n "$pty" ] && printf '\033]2;%s\007' "$orig" >"$pty" 2>/dev/null || true
	printf '%s' "$wid" >"$widfile"

	# 2) wait for the user to click "Focus Pi", then focus the resolved window
	notify-send -u critical -a "pi-hooks" -A "focus=Focus Pi" "$title" "$body" >"$out" 2>/dev/null || true
	if [ "$(cat "$out" 2>/dev/null)" = "focus" ]; then
		target="$(cat "$widfile" 2>/dev/null)"
		if [ -z "$target" ]; then
			# marker resolution failed — best-effort fallback: prefer the
			# unfocused π window (the focus gate guarantees the sender is one)
			target="$(niri msg windows 2>/dev/null | awk -v bn="$cwd_bn" '
				/^Window ID/ { id = $3; gsub(/:/, "", id); title = ""; app = ""; focused = 0; if ($0 ~ /\(focused\)/) focused = 1; next }
				/Title:/ { title = $0; sub(/^ *Title: "/, "", title); sub(/"$/, "", title); next }
				/App ID:/ {
					app = $3; gsub(/"/, "", app)
					if (app == "com.mitchellh.ghostty" && title ~ /^π/ && (bn == "" || index(title, bn) > 0)) {
						if (any == "") any = id
						if (!focused && unfocused == "") unfocused = id
					}
					next
				}
				END { print (unfocused != "" ? unfocused : any) }
			')"
		fi
		[ -n "$target" ] && niri msg action focus-window --id "$target" >/dev/null 2>&1 || true
	fi
	rm -f "$out" "$widfile"
) >/dev/null 2>&1 &

exit 0
