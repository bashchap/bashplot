#!/bin/bash


source /home/tara/dev/bashplot/bin/plot.sh
# turns off cursor
#tput civis 

# tput cvvis turns on cursor
# Setup caculator co-process for maximum efficiency
coproc bc -l
calcOut=${COPROC[0]} calcIn=${COPROC[1]}

# Associated calculater functions for consistency
send2Calc() {
 echo "$*" >&${calcIn}
}

Calc() {
 echo "$*" >&${calcIn}
 read junk <&${calcOut}
 echo ${junk}
}

# Setup calculator environment with intenal variables and functions
send2Calc "
  scale = 20
  pir = a(1)*4/180
  define int(x) { auto os;os=scale;scale=0;x/=1;scale=os;return(x) }
"

# This source line MUST be the first line of any bash code the functions are used in, otherwise the $_
# parameter will notr be set accordingly and relative paths will not be set either

clear

declare -i h=0 w=0 
declare -i xPos=0
declare -i x=0 y=0
declare -i xOff=2 yOff=40

declare -i xSteps=1 ySteps=1
declare -i xSpace=2 ySpace=2
declare -i r=0 g=128 b=255 rD=-1 gD=1 bD=1
declare -i oR=r oG=g oB=b
declare -i rS=1 gS=1 bS=1
declare -A xPos yPos

  while :
  do
    r=$oR g=$oG b=$oB
      [ $((r+(rD*rS))) -lt 0 -o $((r+(rD*rS))) -gt 255 ] && rD=-rD
      [ $((g+(gD*gS))) -lt 0 -o $((g+(gD*gS))) -gt 255 ] && gD=-gD
      [ $((b+(bD*bS))) -lt 0 -o $((b+(bD*bS))) -gt 255 ] && bD=-bD
    r+=$((rD*rS)) g+=$((gD*gS)) b+=$((bD*bS))
    oR=$r oB=$b oG=$g
_PLOT_pLog $r $g $b
    echo -ne "\033[38;2;$r;$g;${b}m█"
#sleep .01
  done
