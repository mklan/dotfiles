#./config/.config/bspwm/calc_rectangle.sh 1000 1200 -100 50
#output: 1000x1200+1460+50


DIMENSIONS=$(xdpyinfo | grep dimensions: | awk '{print $2}')
SCREEN_WIDTH=$(echo $DIMENSIONS | sed -r 's/x.*//')
SCREEN_HEIGHT=$(echo $DIMENSIONS | sed -r 's/.*x//')

x=$3
y=$4

if [ $x -lt 0 ] 
then
 x=$(($SCREEN_WIDTH+$3-$1))
fi

if [ $y -lt 0 ]
then
 y=$(($SCREEN_HEIGHT+$4-$2))
fi

echo $1x$2+$x+$y
