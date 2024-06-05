#! /bin/sh

current=$(light)

if (($1 < 0 && $(echo "$current <= 1" |bc -l)));
then
    if (($(echo "$current == 0.5" |bc -l)));
    then
      light -S 0
    else
      echo "[$current <= 1] set to 0.5"
      light -S 0.5 #the smallest value before turning off
    fi
else
  (( delta = $1 < 0 ? $1 * -1 : $1 ))
  (($1 > 0)) && light -A "$delta" || light -U "$delta"
fi
