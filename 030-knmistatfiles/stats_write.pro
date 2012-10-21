pro stats_write, f, st_prf, st_scl, st_cns, nc_prf, nc_scl

  ; scalars
  ncdf_varput, nc_scl, 'time', f*60, offset=f
  ncdf_varput, nc_scl, 'LWP', st_scl.LWP, offset=f
  ncdf_varput, nc_scl, 'RWP', st_scl.RWP, offset=f
  ncdf_varput, nc_scl, 'zcb', st_scl.zcb, offset=f
  ncdf_varput, nc_scl, 'zct', st_scl.zct, offset=f
  ncdf_varput, nc_scl, 'zmaxcfrac', st_scl.zmaxcfrac, offset=f
  ncdf_varput, nc_scl, 'cc',  st_scl.cc,  offset=f
  if f mod 60 eq 0 then begin
    message, 'syncing at t=' + strtrim(f * 60, 2), /conti
    ncdf_control, nc_scl, /sync
  endif

  ; profiles
  if f mod 60 eq 0 and f ne 0 then begin
    message, 'writing profiles at t=' + strtrim(f * 60, 2), /conti
    off = [0, f/60-1]
    cnt = [100, 1]
    ncdf_varput, nc_prf, 'qt', rebin(st_prf.qt, 100), offset=off, count=cnt
    ncdf_varput, nc_prf, 'ql', rebin(st_prf.ql, 100), offset=off, count=cnt
    ncdf_varput, nc_prf, 'qr', rebin(st_prf.qr, 100), offset=off, count=cnt
    ncdf_varput, nc_prf, 'qt_cld', rebin(st_prf.qt_cld, 100), offset=off, count=cnt
    ncdf_varput, nc_prf, 'ql_cld', rebin(st_prf.ql_cld, 100), offset=off, count=cnt
    ncdf_control, nc_prf, /sync
  endif
  
end
