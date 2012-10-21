pro create_ncprf, nc
  dimt = ncdf_dimdef(nc, 'time', 24) ; 24 hours 
  dimz = ncdf_dimdef(nc, 'zf', 100) 
  dim = [dimz, dimt]
  ign = ncdf_vardef(nc, 'zf', dimz, /float)
  ign = ncdf_vardef(nc, 'time', dimt, /float)
  ign = ncdf_vardef(nc, 'qt', dim, /float)
  ign = ncdf_vardef(nc, 'ql', dim, /float)
  ign = ncdf_vardef(nc, 'qr', dim, /float)
  ign = ncdf_vardef(nc, 'qt_cld', dim, /float)
  ign = ncdf_vardef(nc, 'ql_cld', dim, /float)
  ncdf_control, nc, /endef
  ;ncdf_varput, 'zf'...
  ;ncdf_varput, 'time'...
end
