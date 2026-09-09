# usage: gap.sh [delta]     
# example:  gap.sh 10
#           gap.sh -10

SCRIPT_DIR="$(dirname "$0")"

gap=$(hyprctl getoption general:gaps_in | awk 'NR==1{print $4}')

delta=${1:0}
new=$((gap + delta))

echo $cwd

$SCRIPT_DIR/set_gap.sh $new

exit 1