pro getdata

  files = file_search('/data/slayoo/united/*/*scalars_micro.nc')
  tmp = file_search('/data/slayoo/knmidata/*scalars_micro.nc')
  files = [files, temporary(tmp)]

  vars = ['time', 'cc', 'LWP', 'RWP', 'zcb', 'zct', 'zmaxcfrac']
  row = fltarr(n_elements(vars), /nozero)

  for f = 0, n_elements(files) - 1 do begin
    message, 'processing: ' + files[f], /conti
    zanten = file_basename(files[f]) eq 'zanten_scalars_micro.nc'
    openw, u, file_basename(file_dirname(files[f])) + '-' + $
      file_basename(files[f], '_scalars_micro.nc') + '.tmp', /get_lun
    header = '#'
    for i=0, n_elements(vars) - 1 do header += vars[i] + string(9b)
    printf, u, header
    nc = ncdf_open(files[f], /nowrite)
    ncdf_diminq, nc, 0, dimname, dimlen
    for o=0, dimlen -1 do begin
      for i=0, n_elements(vars) - 1 do begin
        ncdf_varget, nc, vars[i], tmp, offset=o, count=1
        if i eq 0 and zanten then tmp *= 60.
        row[i] = temporary(tmp)
      endfor
      printf, u, strjoin(row, string(9b))
    endfor
    ncdf_close, nc
    free_lun, u
  endfor
  
end
