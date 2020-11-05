#!/bin/bash

# This source line MUST be the first line of any bash code the functions are used in, otherwise the $_
# parameter will notr be set accordingly and relative paths will not be set either
source /home/tara/dev/bashplot/bin/plot.sh

clear

declare -i h=0 w=0 
declare -i xPos=0 yPos=0
declare -i xV=$((${_PLOT_xVSR}/2)) yV=$((${_PLOT_yVSR}/2))
declare -i dX= dY=0 dN=0 dNC=0 dNMax=400
declare -i maxLength=40
declare -i minLength=20
declare -i xVM yVM

#  _PLOT_xVSR=$((_PLOT_xPSR*_PLOT_xVScale)) _PLOT_yVSR

#_PLOT_createBox Outline 0 0 $((${_PLOT_xPSR})) $((${_PLOT_yPSR}))
#_PLOT_displayArtifact Outline 

SECONDS=0
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
        dNC+=1
         if [ ${SECONDS} -gt 10 ]
         then
           SECONDS=0
           maxLength=$((($RANDOM%100)+1))
           minLength=$((($RANDOM%10)+1))
           _PLOT_clearDB 
           clear
         fi
      fi

# This is the plotting activity
# xV and yV are coordinates in the virual space and are used to calculate
# the bloxel required...

#wiwBloxel="${bitMap[$(((2-(xV%2))*(((yV%2)+1)**2)))]#bm}"
# ...and also used to map to physical coordinates

    let xVM=${_PLOT_xVSR}-${xV}
    let yVM=${_PLOT_yVSR}-${yV}
    _PLOT_bPlot "Dot,$xV,$yV" $xV $yV
    _PLOT_bPlot "Dot,$xVM,$yV" $xVM $yV
    _PLOT_bPlot "Dot,$xV,$yVM" $xV $yVM
    _PLOT_bPlot "Dot,$xVM,$yVM" $xVM $yVM
    
    dN=$(($dN-1))
#sleep 0.01
  done

