i=$1
#for i in ; do
  for j in $i/*-z.png; do
    f=`basename $j -z.png`
    echo "processing " $f "..."
    ./3Dbox.sh bgcolor=white pan=55 tilt=-25 pef=1 filter=point $i/$f-x.png $i/$f-y.png $i/$f-z.png $i/$f-box.png 2>/dev/null
    convert $i/$f-box.png boxlegend.png -gravity center -composite $i/$f-box.png
  done
  echo "composing animation..."
  #convert $i/*-box.png $i/anim.gif
  #ffmpeg -sameq -i %05d-box.png anim.mp4
#done
