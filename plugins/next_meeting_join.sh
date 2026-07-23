#!/usr/bin/env bash
# Click handler for the next_meeting item: open the Teams join link of the
# current/next meeting today. Falls back to opening Calendar if none is found.
EXCLUDE="Deutsche Feiertage,Germany holidays,United States holidays,Birthdays,Reminders,Tasks"

URL="$(icalBuddy -n -ea -nc -nrd -ec "$EXCLUDE" -li 1 -iep "location,url,notes" -b "" eventsToday 2>/dev/null \
  | grep -Eo 'https?://[^ <>"]+' \
  | grep -m1 -i 'teams\.microsoft\.com')"

if [ -n "$URL" ]; then
  open "$URL"
else
  open -a Calendar
fi
