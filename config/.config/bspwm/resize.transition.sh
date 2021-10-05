#!/bin/bash

direction=$1
distance=$2

speed=15

iterations=$(($distance/$speed))
rest=$(($distance % $speed))

for ((i=1;i<=$iterations;i++)); do
    echo $i
     ~/.config/bspwm/resize $direction $speed
done
 ~/.config/bspwm/resize $direction $rest

echo All done
