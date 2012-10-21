#!/bin/sh
OPWD=`pwd`
cd $1
gawk -f $OPWD/outdmpparse.awk $OPWD/outpbl.f90  $OPWD/outdmp.f90  > outdmp.pro && \
#gawk -f $OPWD/outdmpparse.awk $OPWD/outdmp.f90  > outdmp.pro && \
GDL_PATH=$OPWD /usr/src/gdl/src/gdl -quiet -e cressbin2ncdf
rm outdmp.pro
cd #OPWD
