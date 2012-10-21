pro stats_alloc, f, st_prf, st_scl, st_cns

  st_scl = create_struct( $
    'zcb', !VALUES.F_NAN, $
    'zct', !VALUES.F_NAN, $
    'zmaxcfrac', !VALUES.F_NAN, $
    'LWP', 0., $
    'RWP', 0., $
    'cc', 0. $
  )

  if f mod 60 eq 1 or f eq 0 then begin
    st_prf = create_struct( $
      'u', replicate(0., st_cns.nz), $
      'v', replicate(0., st_cns.nz), $
      'qt', replicate(0., st_cns.nz), $
      'ql', replicate(0., st_cns.nz), $
      'qr', replicate(0., st_cns.nz), $
      'ql_cld', replicate(0., st_cns.nz), $
      'qt_cld', replicate(0., st_cns.nz), $
      'cfrac', replicate(0., st_cns.nz), $
      '_cld_cnt', replicate(0, st_cns.nz) $
    )
  endif
  
end
