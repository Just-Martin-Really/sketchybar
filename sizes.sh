# shellcheck shell=bash  # sourced, never executed, so it carries no shebang
# Bar and item sizes in points, and how they scale across displays.
#
# Sourced by sketchybarrc for the initial layout and by plugins/bar_scale.sh
# when the active display changes, so the two cannot drift apart.
#
# shellcheck disable=SC2034  # every value here is read by the files that source this

ICON_FONT_FACE="JetBrainsMono Nerd Font:Bold"
LABEL_FONT_FACE="JetBrainsMono Nerd Font:Semibold"

# Tuned on a 150 points-per-inch panel. A display at that density gets these
# numbers unchanged.
BASE_HEIGHT=36
BASE_ICON=15.0
BASE_LABEL=13.0
BASE_BACKGROUND=22
REFERENCE_PPI=150

# A point is physically larger on a less dense display, so sizes shrink there.
# Correcting by the full density ratio overshoots badly, because the eye sees
# angles rather than millimetres and a monitor sits further away than a laptop
# screen. At roughly 50cm and 70cm, a 94 ppi monitor beside a 150 ppi laptop is
# 1.59x larger physically but only 1.13x larger angularly, so most of the
# difference never needed correcting.
#
# This exponent is the one number worth adjusting by eye. Against that pair,
# 0.3 gives angular parity, 0.4 lands just under it, 1.0 would overshoot to
# 0.72x and read as too small.
SCALE_EXPONENT=0.4

# A display reporting an implausible physical size would otherwise yield an
# unreadable or screen-filling bar.
SCALE_MIN=0.6
SCALE_MAX=1.25
