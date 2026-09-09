# usage: set_gap.sh [value]     
# example:  set_gap.sh 10
#

new=${1:0}

if [[ "$new" -lt 0 ]]; then
  exit 0
fi

hyprctl eval "hl.config({general={gaps_in=$new}})"
hyprctl eval "hl.config({general={gaps_out=$(($new * 2))}})"

exit 1