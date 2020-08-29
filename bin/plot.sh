#!/bin/bash
#
# Written by Tara Ram August 2020 while suffering from Bronchitus :(
# Very basic graphics primitives library functions created.  (foundation for something >)

# How to use this:
# First source this code which gives you access to functions below:
# _PLOT_gPlot artifactName x y [noShow] # graphics bloxel plot, x & y are virtual coordinates
# _PLOT_tPlot artifactName x y [noShow] # text plot, x & y are physical screen resolution co-or
# _PLOT_createBox artifactName x y w h [noShow] # box plot, x & y are physical screen resolution co-or
# _PLOT_displayArtifact artifactName 

#trap _PLOT_cleanupDuties EXIT

_PLOT_dirBin=${_%/*}
# These arrays HAVE to be globally available hence are defined here
declare -A _PLOT_logicPlain _PLOT_displayPlain _PLOT_artifactRegister _PLOT_artifactKeys _PLOT_artifactRender

#_PLOT_dirBin=$(readlink -f $0)
_PLOT_dirHome=${_PLOT_dirBin}/..
_PLOT_dirCfg=${_PLOT_dirHome}/cfg
_PLOT_dirData=${_PLOT_dirHome}/data
_PLOT_dirDataSystem=${_PLOT_dirData}/system
_PLOT_dirDataSystemState=${_PLOT_dirDataSystem}/state
_PLOT_dirLogs=${_PLOT_dirHome}/logs
_PLOT_logFile=${_PLOT_dirLogs}/processLog
_PLOT_logicPlainStateFile=${_PLOT_dirDataSystemState}/logicPlain.state
_PLOT_displayPlainStateFile=${_PLOT_dirDataSystemState}/displayPlain.state
_PLOT_artifactRegisterStateFile=${_PLOT_dirDataSystemState}/artifactRegister.state
_PLOT_artifactRenderStateFile=${_PLOT_dirDataSystemState}/artifactRender.state
_PLOT_artifactKeysStateFile=${_PLOT_dirDataSystemState}/artifactKeys.state

# Character mapping
source ${_PLOT_dirCfg}/characterMap.cfg
source ${_PLOT_dirCfg}/transformationMap.cfg

_PLOT_pLog() {
 echo -e "$*" >>${_PLOT_logFile} 
}

_PLOT_tPlot() {
 local tP_artifactName=$1 tP_charShortCode=$2 tP_dcx=${3} tP_dcy=${4}
 local tP_w="${5:-1}" tP_h="${6:-1}"
 local tP_xyKey="$tP_dcx,$tP_dcy" tP_bitMapCode="" tP_xyKeyChar=""
# Override provided CSC if coordinates will create a straight line (this needs to be rechecked)
   [ ${tP_h} -eq 1 -a ${tP_w} -gt 1 ] && tP_charShortCode=HCL
   [ ${tP_w} -eq 1 -a ${tP_h} -gt 1 ] && tP_charShortCode=VCL
# Setup xref variable bitmap code of CSC
 tP_bitMapCode=_PLOT_bm${tP_charShortCode} 

 _PLOT_logicPlain["${tP_xyKey}"]=$((${_PLOT_logicPlain["${tP_xyKey}"]:-0}|${!tP_bitMapCode}))

 tP_xyKeyChar="_PLOT_u${_PLOT_bitMap[${_PLOT_logicPlain[${tP_xyKey}]}]#_PLOT_bm}"
# At this stage have generated the morphed character and set it
 _PLOT_displayPlain[${tP_xyKey}]="\u${!tP_xyKeyChar}"
# _PLOT_addArtifactKeys ${tP_artifactName} ${tP_xyKey}
   [ "${_PLOT_artifactKeys["${tP_artifactName}"]}" = "${_PLOT_artifactKeys["${tP_artifactName}"]##* ${tP_xyKey} }" ] && \
     _PLOT_artifactKeys["${tP_artifactName}"]="${_PLOT_artifactKeys[${tP_artifactName}]} ${tP_xyKey} " 
}

# Provide: $1=Artifact name, $2=Artifact Key
_PLOT_addArtifactKeys() {
   [ "${_PLOT_artifactKeys["$1"]}" = "${_PLOT_artifactKeys["$1"]##*$2}" ] && _PLOT_artifactKeys["${1}"]="${_PLOT_artifactKeys[$1]} $2 " 
}

# Provide: $1=Artifact Name
_PLOT_displayArtifact() {
 local dA_artifactName=$1
 local dA_thisArtifact="" dA_xykey="" dA_x="" dA_y=""
   for dA_xyKey in ${_PLOT_artifactKeys["${dA_artifactName}"]} 
   do
     dA_x=${dA_xyKey%,*} dA_y=${dA_xyKey#*,}     
     dA_thisArtifact="${dA_thisArtifact}\033[$(($dA_y+1));$(($dA_x+1))H${_PLOT_displayPlain[${dA_xyKey}]:-" "}"
   done
 _PLOT_artifactRender["${dA_artifactName}"]="${dA_thisArtifact}"
 echo -ne "${dA_thisArtifact}"
}

# Routine not used but provided for reference: Provide: X Y coordinates
_PLOT_printChar() {
# This sequence represents tput cup y x - esc[y+1;x+1H
 echo -en "\033[$(($2+1));$(($1+1))H$3"
}

# Provide: Artifact Name, x y, w, h
_PLOT_registerArtifact() {
 _PLOT_artifactRegister[$1]="$2,$3,$4,$5"
}

# Provide: Name X Y [show]
# Is show as $4 is supplied it will call _PLOT_displayArtifact immediately after
_PLOT_gPlot() {
 local gP_artifactName=$1 gP_x=$2 gP_y=$3 gP_display="${4}"
 local gP_wiwBloxel="${_PLOT_bitMap[$(((2-(gP_x%2))*(((gP_y%2)+1)**2)))]#_PLOT_bm}"
 _PLOT_registerArtifact ${gP_artifactName} $((gP_x/2)) $((gP_y/2)) 1 1
 _PLOT_tPlot ${gP_artifactName} ${gP_wiwBloxel} $((gP_x/2)) $((gP_y/2))
   [ -z "${gP_display}" ] && _PLOT_displayArtifact ${gP_artifactName}
}

# Provide: Name X Y [W H]
_PLOT_createBox() {
 local cB_artifactName=$1
 local cB_artifactName=$1 cB_dcx=${2} cB_dcy=${3}
 local cB_w=${4:-1} cB_h=${5:-1}

# If an artifact already exists with that name so need to do anything else
   if [ "${_PLOT_artifactRegister[${cB_artifactName}]}" != "" ]
   then
     return
   fi

 _PLOT_registerArtifact ${cB_artifactName} ${cB_dcx} ${cB_dcy} ${cB_w} ${cB_h}
# Calculate box vertices
 local -i cB_x=$2 cB_y=$3 cB_w=$4 cB_h=$5 cB_xAw=cB_x+cB_w-1 cB_yAh=cB_y+cB_h-1
 local -i cB_xTLC=cB_x cB_yTLC=cB_y cB_xTRC=cB_xAw cB_yTRC=cB_y cB_xBLC=cB_x cB_yBLC=cB_yAh cB_xBRC=cB_xAw cB_yBRC=cB_yAh 
# Draw corners
 _PLOT_tPlot ${cB_artifactName} TLC $cB_xTLC $cB_yTLC
 _PLOT_tPlot ${cB_artifactName} TRC $cB_xTRC $cB_yTRC
 _PLOT_tPlot ${cB_artifactName} BLC $cB_xBLC $cB_yBLC
 _PLOT_tPlot ${cB_artifactName} BRC $cB_xBRC $cB_yBRC

# Draw Top and bottom horizontal lines
local -i cB_cX=cB_xTLC+1
   while [ ${cB_cX} -le $((cB_xTRC-1)) ]
   do
#     _PLOT_tPlot ${cB_artifactName} HCL $cB_cX $cB_yTLC
     _PLOT_tPlot ${cB_artifactName} UHB $cB_cX $cB_yTLC
#     _PLOT_tPlot ${cB_artifactName} HCL $cB_cX $cB_yBLC
     _PLOT_tPlot ${cB_artifactName} LoHB $cB_cX $cB_yBLC
     cB_cX+=1 
   done
# Draw Left and right vertical lines
 local -i cB_cY=cB_yTLC+1
   while [ ${cB_cY} -le $((cB_yBLC-1)) ]
   do
#     _PLOT_tPlot ${cB_artifactName} VCL $cB_xTLC $cB_cY
     _PLOT_tPlot ${cB_artifactName} LHB $cB_xTLC $cB_cY
#     _PLOT_tPlot ${cB_artifactName} VCL $cB_xTRC $cB_cY
     _PLOT_tPlot ${cB_artifactName} RHB $cB_xTRC $cB_cY
     cB_cY+=1 
   done
}

_PLOT_dumpLogicPlain() {
{
 local allKeys
  echo -ne "#!/bin/bash

_PLOT_logicPlain=("
    for allKeys in ${!_PLOT_logicPlain[*]}
    do
      echo -ne "[${allKeys}]=\"${_PLOT_logicPlain[${allKeys}]}\" "
    done
  echo ")"
} >${_PLOT_logicPlainStateFile}
}

_PLOT_dumpDisplayPlain() {
{
 local allKeys
  echo -ne "#!/bin/bash

_PLOT_displayPlain=("
    for allKeys in ${!_PLOT_displayPlain[*]}
    do
      echo -ne "[${allKeys}]=\"${_PLOT_displayPlain[${allKeys}]}\" "
    done
  echo ")"
} >${_PLOT_displayPlainStateFile}
}

_PLOT_dumpArtifactRegister() {
{
 local allKeys
  echo -ne "#!/bin/bash

_PLOT_artifactRegister=("
    for allKeys in ${!_PLOT_artifactRegister[*]}
    do
      echo -ne "[${allKeys}]=\"${_PLOT_artifactRegister[${allKeys}]}\" "
    done
  echo ")"
} >${_PLOT_artifactRegisterStateFile}
}

_PLOT_dumpArtifactRender() {
{
 local allKeys
  echo -ne "#!/bin/bash

_PLOT_artifactRender=("
    for allKeys in ${!_PLOT_artifactRender[*]}
    do
      echo -ne "[${allKeys}]=\"${_PLOT_artifactRender[${allKeys}]}\" "
    done
  echo ")"
} >${_PLOT_artifactRenderStateFile}
}

_PLOT_dumpArtifactKeys() {
{
 local allKeys
  echo -ne "#!/bin/bash

_PLOT_artifactKeys=("
    for allKeys in ${!_PLOT_artifactKeys[*]}
    do
      echo -ne "[${allKeys}]=\"${_PLOT_artifactKeys[${allKeys}]}\" "
    done
  echo ")"
} >${_PLOT_artifactKeysStateFile}
}

_PLOT_cleanupDuties() {
 _PLOT_pLog "xV=$xV yV=$yV dX=$dX dY=$dY"
return 0
}

# The purpose of this function is just to clear the databases (stored and in-memory).  This turned out to be a lot more awkward
# that I ever ancitipated.  Reason is, if I unset all the elements of an associative array, the next time there's an assignment to it,
# bash re-declares it as an indexed array (no matter what the index is, i.e. not numeric).  I explicitly re-declare the arrays as
# associative within the function, as they become local to the function and don't retain their assignments out of it.
# So the dirty way I have worked out, it to assign one element as a dummy (non-numeric) index and clear out the rest.
# There has to be another way.  This is not very elegant and I must be missing something.  Is this a bug?
_PLOT_clearDB() {
 _PLOT_logicPlain[_]=junk ; for k in ${!_PLOT_logicPlain[*]} ; do [ $k != _ ] && unset _PLOT_logicPlain[$k] ; done
   [ -f ${_PLOT_logicPlainStateFile} ]	&&	rm -f ${_PLOT_logicPlainStateFile}
 _PLOT_displayPlain[_]=junk ; for k in ${!_PLOT_displayPlain[*]} ; do [ $k != _ ] && unset _PLOT_displayPlain[$k] ; done
   [ -f ${_PLOT_displayPlainStateFile} ]	&&	rm -f ${_PLOT_displayPlainStateFile}
 _PLOT_artifactRegister[_]=junk ; for k in ${!_PLOT_artifactRegister[*]} ; do [ $k != _ ] && unset _artifactRegister[$k] ; done
   [ -f ${_PLOT_artifactRegisterStateFile} ] &&	rm -f ${_PLOT_artifactRegisterStateFile}
 _PLOT_artifactKeys[_]=junk ; for k in ${!_PLOT_artifactKeys[*]} ; do [ $k != _ ] && unset _artifactKeys[$k] ; done
   [ -f ${_PLOT_artifactKeysStateFile} ]	&&	rm -f ${_PLOT_artifactKeysStateFile}
 _PLOT_artifactRender[_]=junk ; for k in ${!_PLOT_artifactRender[*]} ; do [ $k != _ ] && unset _artifactRender[$k] ; done
   [ -f ${_PLOT_artifactRenderStateFile} ]	&&	rm -f ${_PLOT_artifactRenderStateFile}
}

_PLOT_loadDB() {
   [ -f ${_PLOT_logicPlainStateFile} ]		&& source ${_PLOT_logicPlainStateFile}
   [ -f ${_PLOT_displayPlainStateFile} ] 	&& source ${_PLOT_displayPlainStateFile}
   [ -f ${_PLOT_artifactRegisterStateFile} ]	&& source ${_PLOT_artifactRegisterStateFile}
   [ -f ${_PLOT_artifactKeysStateFile} ]	&& source ${_PLOT_artifactKeysStateFile}
   [ -f ${_PLOT_artifactRenderStateFile} ]	&& source ${_PLOT_artifactRenderStateFile}
}

_PLOT_writeDB() {
 _PLOT_dumpLogicPlain
 _PLOT_dumpDisplayPlain
 _PLOT_dumpArtifactRegister
 _PLOT_dumpArtifactKeys
 _PLOT_dumpArtifactRender
}

#####################################################
#############################
##
#	START HERE



# Global variables set for useful reference in calling scripts
# *VScale = Virtual scale compared to *PSR (Physical Screen Resolution (max columns and rows))
# *VSR = Virtual Screen Resolution 
declare -i _PLOT_xVScale=2 _PLOT_yVScale=2
declare -i _PLOT_xPSR=$(($(tput cols))) _PLOT_yPSR=$(($(tput lines)))
#declare -i _PLOT_xVSR=$((_PLOT_xPSR*_PLOT_xVScale-1)) _PLOT_yVSR=$((_PLOT_yPSR*_PLOT_yVScale-1))
declare -i _PLOT_xVSR=$((_PLOT_xPSR*_PLOT_xVScale)) _PLOT_yVSR=$((_PLOT_yPSR*_PLOT_yVScale))


