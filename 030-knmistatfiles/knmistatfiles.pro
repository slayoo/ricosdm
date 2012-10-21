pro knmistatfiles, dir

  files = file_search(dir + '/*.united.bin.nc')
  if n_elements(files) ne 1441 then begin
    message, dir + ': skipping (number of nc files found ' + strmid(n_elements(files),2) + ' != 1441)', /conti
  endif else begin

    ; TODO: sort???

    nc_prf = ncdf_create(dir + '/Shima_profiles_micro.nc', /clobber)
    create_ncprf, nc_prf
    nc_scl = ncdf_create(dir + '/Shima_scalars_micro.nc', /clobber)
    create_ncscl, nc_scl

    nc = ncdf_open(files[0], /nowrite)
    stats_const, st_cns, nc
    ncdf_close, nc

    ; gathiering statistics
    for f = 0l, n_elements(files) - 1 do begin

      nc = ncdf_open(files[f], /nowrite)
      stats_alloc, f, st_prf, st_scl, st_cns
      stats_count, st_prf, st_scl, st_cns, nc
      ncdf_close, nc

      stats_sumup, f, st_prf, st_scl, st_cns
      stats_write, f, st_prf, st_scl, st_cns, nc_prf, nc_scl

    endfor

    ncdf_close, nc_prf
    ncdf_close, nc_scl

  endelse

end
