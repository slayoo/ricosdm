{
  if (index($0,"call outdmp3d")>0 || index($0,"call s_outdmp2d")>0 || index($0,"call s_outdmp3d")>0 || index($0,"call outdmp2d")>0)
  {
    for (i=0;i<index($0,"c")-1;i++) printf(" ")
    print "dims[out] = " (index($0,"outdmp3d")>0 ? "3" : "2")
    for (i=0;i<index($0,"c")-1;i++) printf(" ")
    print "filevars[out++] = strtrim(" substr($0, index($0,"'"), 8) ",2)"
  }
  else if (index($0,") then")>0)
  {
    gsub(/\.eq\./," eq ")
    gsub(/\.and\./," and ")
    gsub(/\.lt\./," lt ")
    gsub(/\.gt\./," gt ")
    gsub(/\.ge\./," ge ")
    gsub(/\.or\./," or ")
    gsub(/\.ne\./," ne ")
    $0 = gensub(/mod\((\w*),(\w*)\)/,"\\1 mod \\2","g")
    $0 = gensub(/(\w*)\((\w*):(\w*)\)/,"strmid(\\1,\\2-1,\\3-\\2+1)","g")
    gsub("then","then begin")
    gsub("else if","endif else if")
    gsub(/land\(i,j\)/,"1")
    print $0
  } 
  else if (index($0,"end if")>0)
  {
    for (i=0;i<index($0,"e")-1;i++) printf(" ")
    print "endif"
  }
  else if (index($0,"else")>0)
  {
    for (i=0;i<index($0,"e")-1;i++) printf(" ")
    print "endif else if 1 gt 0 then begin"
  }
}
