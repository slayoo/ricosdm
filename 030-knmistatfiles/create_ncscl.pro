pro create_ncscl, nc
  dim = ncdf_dimdef(nc, 'time', 1441) ; 24 hours * 60 minutes + 0
  ign = ncdf_vardef(nc, 'time', dim, /float)
  ign = ncdf_vardef(nc, 'zcb', dim, /float)
  ign = ncdf_vardef(nc, 'zct', dim, /float)
  ign = ncdf_vardef(nc, 'zmaxcfrac', dim, /float)
  ign = ncdf_vardef(nc, 'LWP', dim, /float)
  ign = ncdf_vardef(nc, 'RWP', dim, /float)
  ign = ncdf_vardef(nc, 'cc', dim, /float)
  ncdf_control, nc, /endef
end
