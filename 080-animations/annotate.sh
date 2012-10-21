if [ x$1 = x ]; then 
  echo "argument required!"
  exit 1
fi
for i in $1/*-box.png; do
  min=`basename $i -box.png`
  min=`expr $min + 0`
  convert $i -pointsize 20 -annotate +20+50 "20h + $min min" $i
done
