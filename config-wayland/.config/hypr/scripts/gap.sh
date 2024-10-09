# usage: gap.sh [delta]     
# example:  gap.sh 10
#           gap.sh -10

SCRIPT_DIR="$(dirname "$0")"

gap=$(hyprctl --instance 0 getoption general:gaps_in | awk '{print $3}')

delta=${1:0}
new=$((gap + delta))

echo $cwd

$SCRIPT_DIR/set_gap.sh $new

exit 1