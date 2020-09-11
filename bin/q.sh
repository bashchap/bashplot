#!/bin/bash

declare -A b2b=([0,0]=1 [0,1]=2 [0,2]=4 [0,3]=64 [1,1]=8 [1,2]=16 [1,3]=32 [1,4]=128)
declare -i charsetOffset=0x2800

declare -i char=0
hex=0

  for ((char=0;char<256;char+=1))
  do
    printf -v hex %x $((char+charsetOffset))
    echo -e "${hex} \u${hex}"
  done
