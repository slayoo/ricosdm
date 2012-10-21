pro knmidata, vars, min, max
  ;vars = ['u','v','ql','qr']

  files = file_search('/data/slayoo/knmidata/*profiles_micro.nc')

  min = ptrarr(n_elements(vars),24)
  max = ptrarr(n_elements(vars),24)

  for v=0, n_elements(vars) - 1 do begin
    for i=0, n_elements(files) - 1 do begin

      nc = ncdf_open(files[i], /nowrite)
      ncdf_varget, nc, vars[v], vals

      if (size(vals))[1] ne 100 then continue
      wh = where(vals eq -999, cnt)
      if cnt gt 0 then continue

      for h=0, 24 - 1 do begin
        if ~ptr_valid(min[v,h]) then begin
          min[v,h] = ptr_new(vals[*,h]) 
          max[v,h] = ptr_new(vals[*,h]) 
        endif else begin
          *min[v,h] <= vals[*,h]
          *max[v,h] >= vals[*,h]
        endelse
      endfor

      ncdf_close, nc
    endfor
  endfor

;  for h=0, 24 - 1 do begin
;    plot, *min[2,h], findgen(100)
;    oplot, *max[2,h], findgen(100)
;    wait, 1
;  endfor
;  stop

end
