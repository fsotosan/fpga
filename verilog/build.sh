#!/bin/bash

# Call to iCE40 flow indicated in http://www.clifford.at/icestorm/

if [ -z "$2" ]; then
   echo usage: $0 projectname source1.v source2.v ...
   exit
fi

PROJECT_NAME="$1"
SOURCE_FILES=""

for i in "${@:2}"; do
   SOURCE_FILES="$SOURCE_FILES $i"
done

echo yosys -p '"synth_ice40 -blif' ${PROJECT_NAME}'.blif"' $SOURCE_FILES
#arachne-pnr -d 1k -p $PROJECT_NAME.pcf $PROJECT_NAME.blif -o $PROJECT_NAME.asc
#icepack $PROJECT_NAME.asc $PROJECT_NAME.bin

