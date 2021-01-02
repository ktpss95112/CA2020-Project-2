#!/usr/bin/env bash

TARGET=GodKaienLinAndHisWorshippers_project2
TMPFOLDER=/tmp/$RANDOM/$TARGET

if [[ -f ${TARGET}.zip ]]; then
    rm -f ${TARGET}.zip
fi

mkdir -p $TMPFOLDER/codes

cp codes/*.v $TMPFOLDER/codes
cp report.pdf $TMPFOLDER/${TARGET}.pdf

rm $TMPFOLDER/codes/Instruction_Memory.v
rm $TMPFOLDER/codes/PC.v
rm $TMPFOLDER/codes/Registers.v

OLDFOLDER=`pwd`

cd $TMPFOLDER/..
zip -r out.zip $TARGET

cd $OLDFOLDER
cp $TMPFOLDER/../out.zip ${TARGET}.zip

rm -rf $TMPFOLDER
