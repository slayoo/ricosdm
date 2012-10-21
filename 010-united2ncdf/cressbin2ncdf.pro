pro cressbin2ncdf

  exprim = 'RICO'
  floatsize = 4

  ; acquireing xdim, ydim & zdim etc from the 'user.conf'
  vars = ['xdim','ydim','zdim','dx','dy','dz','dmpitv','dmpvar','cphopt','dmplev','tubopt','trkopt','movopt','umove','vmove']
  message, 'reading the following variables from user.conf:', /conti
;message, '    ' + string(vars,/print), /conti
  type = ['i'   , 'i'  ,'i'   ,'f' ,'f' ,'f' ,'i'     ,'s'     ,'i'     ,'i'     ,'i'     ,'i',     'i',     'f',    'f'    ]
  for v=0, n_elements(vars) - 1 do begin
    spawn, 'cut -d "!" -f 1 user.conf | fgrep ' + vars[v] + '| tr -s " " | fgrep " ' + vars[v] + ' " | cut -d= -f 2', tmp
    if n_elements(tmp) gt 1 then message, 'oops'
    tmp = tmp[0]
    tmp = execute(vars[v] + '=' + string(type[v] eq 'i' ? fix(tmp) : type[v] eq 'f' ? float(tmp) : tmp))
  endfor
  xdim -= 3 & ydim -= 3 & zdim -= 3

  ; acquireing the number of dumps in the current dir
  files = file_search(exprim + '*dmp*united*.bin.gz')
  tdim = n_elements(files)

  filevars = strarr(100)
  dims = intarr(100)

  ; magick! :)
  message, 'parsing the outdmp.f90 file...', /conti
  out = 0
  fdmp = 'act'
  fmon = 'act'
  fmois = 'moist'
  @outdmp.pro
  message, '    got the following list of variables (with their dimensions):', /conti
;message, '        ' + string(filevars, /print), /conti
  ;message, '        ' + string(dims, /print, format='(100I)'), /conti

  nvars = total(dims gt 0)
  filevars = filevars[0:nvars - 1]
  dims = dims[0:nvars-1]

  datasize = $
    total(dims eq 2) * xdim * ydim * floatsize + $
    total(dims eq 3) * xdim * ydim * zdim * floatsize
  fsize = (file_info(files[0])).size

;  not applicable in case of compressed files!
;  if datasize ne fsize then $
;    message, 'data size does not match file size! (' + string(datasize) + ' vs. ' + string(fsize) + ')'

  for t = 0, n_elements(files) - 1 do begin

    ncfile = strmid(files[t],0,strlen(files[t])-3) + '.nc'

    ; TEMPORARY 
;    if -1 eq strpos(ncfile, '0008') then continue

    ; already prepared files
    if (size(file_search(ncfile + '*')))[0] eq 1 then begin
      message, 'skipping: ' + files[t], /conti
      continue
    endif

    ; creating the netCDF file
    message, 'creating the netCDF file: ' + files[t] + '.nc', /conti
    nc = ncdf_create(ncfile, /clo)

    ; creating the dimensions
    nc_dx = ncdf_dimdef(nc, 'X', xdim)
    nc_dy = ncdf_dimdef(nc, 'Y', ydim)
    nc_dz = ncdf_dimdef(nc, 'Z', zdim)

    ; creating the 1D variables
    nc_vx = ncdf_vardef(nc, 'X', [nc_dx])
    nc_vy = ncdf_vardef(nc, 'Y', [nc_dy])
    nc_vz = ncdf_vardef(nc, 'Z', [nc_dz])

    ; creating the 2D/3D variables
    nc_v = lonarr(n_elements(filevars))
    for i=0, n_elements(filevars) - 1 do begin
      nc_v[i] = ncdf_vardef(nc, filevars[i], dims[i] eq 2 ? [nc_dx,nc_dy] : [nc_dx,nc_dy,nc_dz])
    endfor

    ; switching to data mode
    ncdf_control, nc, /endef
    message, 'writing the data...', /conti

    ; filling the time-independant variables
    ncdf_varput, nc, nc_vx, findgen(xdim) * dx + dx / 2.
    ncdf_varput, nc, nc_vy, findgen(ydim) * dy + dy / 2.
    ncdf_varput, nc, nc_vz, findgen(zdim) * dz + dz / 2.

    message, '    file: ' + files[t], /conti
    openr, u, files[t], /get_lun, /swap_endian, /compress
    for v = 0, n_elements(nc_v) - 1 do begin
      tmp = fltarr(dims[v] eq 2 ? [xdim,ydim] : [xdim,ydim,zdim],/nozero)
      readu, u, tmp
      ; TODO: us, usfrc, vs, vsfrc???
      if filevars[v] eq 'u' then tmp += umove
      if filevars[v] eq 'v' then tmp += vmove
      ncdf_varput, nc, nc_v[v], tmp, offset=(dims[v] eq 2 ? [0,0] : [0,0,0])
    endfor
    free_lun, u
    ncdf_close, nc
;    spawn, 'gzip -9 ' + ncfile
    message, 'done.', /conti

  endfor
end
