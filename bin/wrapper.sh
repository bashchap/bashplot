#!/bin/bash

source ./plot.sh

declare -i h=0 w=0 
declare -i xPos=0 yPos=0
declare -i xV=$((${_PLOT_xVSR}/2)) yV=$((${_PLOT_yVSR}/2))
declare -i dX= dY=0 dN=0
declare -i maxLength=100
declare -i minLength=10

clear
#_PLOT_createBox Outline 0 0 $maxCols $maxRows
#_PLOT_createBox Outline 0 0 $((${_PLOT_xPSR})) $((${_PLOT_yPSR}))
#_PLOT_displayArtifact Outline 

  while :
  do
      [ $((${xV}+${dX})) -lt 0 -o $((${xV}+${dX})) -eq $((${_PLOT_xVSR})) ] && dX=$((-${dX}))
      [ $((${yV}+${dY})) -lt 0 -o $((${yV}+${dY})) -eq $((${_PLOT_yVSR})) ] && dY=$((-${dY}))
    xV+=dX yV+=dY
# pLog After dN=$dN xV=$xV dX=$dX yV=$yV dY=$dY
      if [ ${dN} -lt 1 ]
      then
        dX=$((1-($RANDOM%3)))
        dY=$((1-($RANDOM%3)))
          [ ${dX} -eq 0 -a ${dY} -eq 0 ] && continue
        dN=$((($RANDOM%${maxLength})+(${minLength}+1)))
      fi

# This is the plotting activity
# xV and yV are coordinates in the virual space and are used to calculate
# the bloxel required...

#wiwBloxel="${bitMap[$(((2-(xV%2))*(((yV%2)+1)**2)))]#bm}"
# ...and also used to map to physical coordinates

_PLOT_gPlot "Dot,$xV,$yV" $xV $yV
    dN=$(($dN-1))
#sleep 0.01
  done

