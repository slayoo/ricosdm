pro plotdata

  vars = ['cc [1]', 'LWP [g/m^2]', 'RWP [g/m^2] ', 'zct [m]'];, 'zcb [m]', 'zmaxcfrac [m]']
  clmn = [2,        3,             4,              6];,         5,         7]
  rmin = [0.,       0,             0,              500];,       0,         0]
  rmax = [.4,       80,            40,             3500];,      1000,      2500]
  frmt = ['%4.2f',  '%4.f',        '%4.f',         '%4.f']

  files = file_search('knmi*.tmp')
  files = [files, file_search('*Shima*.tmp')]
  openw, u, 'plotdata_auto.gpi', /get_lun
  for a = 0, n_elements(vars) - 1 do begin
    printf, u, 'set yrange [' + strtrim(rmin[a],2) + ':' + strtrim(rmax[a],2) + ']'
    printf, u, 'set label 1 " //" at 4.35,' + strtrim(rmin[a],2)
    printf, u, 'set label 2 " //" at 4.35,' + strtrim(rmax[a],2)
    printf, u, 'set ylabel "' + vars[a] + '"'
    printf, u, 'set xrange [0:4.2]'
    printf, u, 'set border 7'
    printf, u, 'set format y "' + frmt[a] + '"'
    printf, u, 'plot \'
    for i=0, n_elements(files) - 1 do begin
      if strmid(files[i],0,4) eq 'knmi' then stl = 'w lines lc rgbcolor "grey" lw 1 t ""' $
      else stl = 'w lines ' + style(strmid(files[i],0,8), title=a eq 0) 

      cl = strtrim(clmn[a],2)
      tmp = "  '" + files[i] + "' u ($1/3600):" $
        + "($" + cl + ">" + strtrim(string(2*rmax[a],format='(A)'), 2) + "?NaN:" $
        + "$" + cl + "<" + strtrim(string(rmin[a],format='(A)'), 2) + "?NaN:" $
        + "$" + cl + ") " + stl + ", \"
      printf, u, temporary(tmp)
    endfor
    printf, u, '  -1000 lc rgbcolor "grey" t "other LES"'
    printf, u, 'set xrange [19.8:24]'
    printf, u, 'set border 13'
    printf, u, 'unset label 1'
    printf, u, 'unset label 2'
    printf, u, 'unset ylabel'
    printf, u, 'set format y ""'
    printf, u, 'set nokey'
    printf, u, 'replot'
  endfor
  free_lun, u
end
