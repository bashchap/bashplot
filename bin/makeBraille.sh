#!/bin/bash

#_PLOT_dirBin=${_%/*}
_PLOT_dirBin=/home/tara/dev/bashplot/bin
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

tMap1="" tMap2="" cMap=""

cMap="# Character Unicode	bitMap	cMap	char\n"
declare -A b2B=([1]=1 [2]=2 [3]=4 [4]=64 [5]=8 [6]=16 [7]=32 [8]=128)
declare -i char bitIndex=0 byteValue=0
  for ((char=0;char<256;char+=1))
  do
    byteValue=0
      for ((bitIndex=1;bitIndex<=8;bitIndex+=1))
      do
        (((2**(bitIndex-1))&char)) && byteValue+=${b2B[${bitIndex}]}
      done
    printf -v unicode %x $((10240+${byteValue}))
#    echo -e "${char} 	${byteValue}	\u${unicode}	${unicode}"
    tMap1="${tMap1}_PLOT_bm${char}=${char}\n"
    tMap2="${tMap2}_PLOT_bitmap[${char}]=\"_PLOT_bm${char}\"\n"
    cMap="${cMap}_PLOT_ubm${char}=${unicode}  	# ${char}	${byteValue}	\u${unicode}\n"
  done

echo -e "${tMap1}" >${_PLOT_dirCfg}/transformationMap-bixels.cfg
echo -e "${tMap2}" >>${_PLOT_dirCfg}/transformationMap-bixels.cfg
echo -e "${cMap}" >${_PLOT_dirCfg}/characterMap-bixels.cfg
