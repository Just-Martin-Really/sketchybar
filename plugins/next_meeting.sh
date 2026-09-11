#!/usr/bin/env bash
# Next timed calendar event today. Hidden when nothing is left. Turns red
# when the meeting starts within 10 minutes. Requires icalBuddy (brew).
source "$HOME/.config/sketchybar/icons.sh"
# State colours come from the active theme, not hardcoded here.
source "$HOME/.config/sketchybar/themes/active.sh" >/dev/null 2>&1

# Calendars that are not meetings (holidays, birthdays, reminders, tasks).
EXCLUDE="Deutsche Feiertage,Germany holidays,United States holidays,Birthdays,Reminders,Tasks"

# icalBuddy prints "<start> - <end>@<title>" (datetime forced first via -po,
# @ separator via -ps). All-day events have an empty datetime -> line starts
# with @ and is skipped so holidays don't masquerade as meetings.
LINE=""
while IFS= read -r l; do
  tp="${l%%@*}"
  case "$tp" in
    [0-9][0-9]:[0-9][0-9]*) LINE="$l"; break ;;
  esac
done <<EOF
$(icalBuddy -n -ea -nc -nrd -b "" -po "datetime,title" -iep "datetime,title" -ps "|@|" -df "" -tf "%H:%M" -ec "$EXCLUDE" -li 5 eventsToday 2>/dev/null)
EOF

if [ -z "$LINE" ]; then
  # Muted dracula comment color so it stays quiet when nothing is left.
  sketchybar --set "$NAME" drawing=on icon="$ICON_CAL" \
    label="No more meetings today" \
    icon.color="$COLOR_MUTED" label.color="$COLOR_MUTED"
  exit 0
fi

TITLE="${LINE#*@}"           # everything after the first @
TIMEPART="${LINE%%@*}"       # "13:30 - 15:00"
TIME="${TIMEPART%% *}"       # start time "13:30"

# Minutes until the event starts.
NOW_MIN=$(( 10#$(date +%H) * 60 + 10#$(date +%M) ))
EV_MIN=$(( 10#${TIME%%:*} * 60 + 10#${TIME#*:} ))
DIFF=$(( EV_MIN - NOW_MIN ))

# Purple normally, red when imminent (matches the dracula accent).
COLOR="$COLOR_ACCENT"
if [ "$DIFF" -ge 0 ] && [ "$DIFF" -le 10 ]; then
  COLOR="$COLOR_URGENT"
fi

# Trim long titles.
MAX=24
if [ "${#TITLE}" -gt "$MAX" ]; then
  TITLE="$(printf '%.*s…' "$((MAX - 1))" "$TITLE")"
fi

sketchybar --set "$NAME" drawing=on icon="$ICON_CAL" \
  label="${TIME} ${TITLE}" icon.color="$COLOR" label.color="$COLOR"
