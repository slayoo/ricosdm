pro stats_const, st_cns, nc

 ncdf_diminq, nc, 0, name, nx
 if name ne 'X' then message, 'assert...'
 ncdf_diminq, nc, 1, name, ny
 if name ne 'Y' then message, 'assert...'
 ncdf_diminq, nc, 2, name, nz
 if name ne 'Z' then message, 'assert...'
 ;if nz ne 100 then message, 'nz = ' + strtrim(string(nz), 2) + ' != 100 - we need to implement some interpolation...' 

 ncdf_varget, nc, 'Z', z

 rd = 287.0
 cp = 1004.0
 st_cns = create_struct( $
   'nx', nx, $
   'ny', ny, $
   'nz', nz, $
   'dz', z[1] - z[0], $
   'rd', rd, $     ; Gas constant for dry air
   'epsav', 1.6077, $ ; Morecular weight ratio of air / vapor
   'cp', cp, $    ; Specific heat of dry air at constant pressure
   'p0', 1.e5, $      ; Reference pressure
   'rddvcp', rd / cp $
 )

end
