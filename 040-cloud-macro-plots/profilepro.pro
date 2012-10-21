function rnd, scl
  return, ceil(100*scl)/100.
end

function scl, prof, gmi, gma, a, kg2g=kg2g
  if keyword_set(kg2g) then prof *= 1000; TEMPORARY!!! kg/kg -> g/kg
  scale = rnd((gma[a] - gmi[a]) * 2)
  prof -= gma[a]/2
  prof /= scale 
  return, prof
end

pro profilepro, vars, min, max

  runs = ['10122302', '10122401', '10122402', '10122403', '10122404', '10122801', '10122802', '10122803', '11010502','12010417']

  globalmin = replicate(1e6, n_elements(vars))
  globalmax = fltarr(n_elements(vars))
  for i = 0, n_elements(min) - 1 do begin
    wh = where(*min[i] eq -99999, cnt)
    if cnt gt 0 then (*min[i])[wh] = !VALUES.F_NAN
  endfor
  for i = 0, n_elements(vars) - 1 do begin
    for h = 0, 24 - 1 do begin
      globalmin[i] <= min(*min[i,h], /nan)
      globalmax[i] >= max(*max[i,h], /nan)
    endfor
  endfor

  openw, u, 'profileplot_auto.gpi', /get_lun
  for a = 0, n_elements(vars) - 1 do for prd=0, 1 do begin
    printf, u, ~prd $
      ?('set title "                                 hourly averaged profiles of ' + vars[a] + '"')$
      :('set title "(1h on X axis corresponds to ' + strtrim(string(rnd((globalmax[a] - globalmin[a]) * 2), format='(F4.2)'), 2) + ' g/kg)                                              "')
    printf, u, 'set nokey'
    printf, u, 'set xrange ' + (prd?'[20.5:24.5]':'[0.5:4.5]')
    printf, u, 'set border ' + (prd?'13':'7')
    printf, u, (prd?'un':'') + 'set ylabel' + (prd?'':'"height [m]"')
    printf, u, 'set format y ' + (prd?'""':'"%2.1f"')
    if a eq n_elements(vars) - 1 and prd eq 1 then begin
      printf, u, 'set key at screen .5, .32 horizontal samplen .5 box'
    endif
    printf, u, 'plot \'
    for i=0, n_elements(runs) - 1 do begin
      for h = 0, 24 - 1 do begin
        printf, u, "  '-' using (abs($2)>100?NaN:$2+1+" + strtrim(h, 2) + "):($1/1000) with lines " + style(runs[i], title=(h eq 23)) + ",\"
        if i eq n_elements(runs) - 1 then begin
          printf, u, "  '-' using ($2+1+" + strtrim(h, 2) + "):($1/1000) with lines lw 4 lc rgbcolor ""white"" t """", \" 
          printf, u, "  '-' using ($2+1+" + strtrim(h, 2) + "):($1/1000) with lines lw 4 lc rgbcolor ""white"" t """", \"
          printf, u, "  '-' using ($2+1+" + strtrim(h, 2) + "):($1/1000) with lines lw 2 lc rgbcolor ""black"" t """", \" 
          printf, u, "  '-' using ($2+1+" + strtrim(h, 2) + "):($1/1000) with lines lw 2 lc rgbcolor ""black"" t """", \"
        endif
      endfor
    endfor
    printf, u, '  -1 lw 2 lc rgbcolor "black" t "other LES: min-max"'
    for i=0, n_elements(runs) - 1 do begin
      nc = ncdf_open('/data/slayoo/united/' + runs[i] + '/Shima_profiles_micro.nc')
      for h = 0, 24 - 1 do begin
        ncdf_varget, nc, vars[a], prof, offset=[0, h], count=[100, 1]
        prof = scl(prof, globalmin, globalmax, a, /kg2g)
        for j=0, 100 - 1 do printf, u, 20 + j * 40, prof[j]
        printf, u, 'e'
        if i eq n_elements(runs) - 1 then for dbl = 0, 1 do begin
          for j=0, 100 - 1 do printf, u, 20 + j * 40, scl((*min[a,h])[j], globalmin, globalmax, a)
          printf, u, 'e'
          for j=0, 100 - 1 do printf, u, 20 + j * 40, scl((*max[a,h])[j], globalmin, globalmax, a)
          printf, u, 'e'
        endfor
      endfor
      ncdf_close, nc
    endfor
  endfor
  free_lun, u
end
