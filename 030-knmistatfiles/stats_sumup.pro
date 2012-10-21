pro stats_sumup, f, st_prf, st_scl, st_cns

  if f gt 0 and f mod 60 eq 0 then begin
    st_prf.qt /= 60. ; time averaging
    st_prf.ql /= 60. ; time averaging
    st_prf.qr /= 60. ; time averaging
    st_prf.cfrac /= 60. ; time averaging

    st_prf.qt_cld /= st_prf._cld_cnt ;
    st_prf.ql_cld /= st_prf._cld_cnt ;
  endif

  st_scl.zcb *= st_cns.dz ; level number -> height
  st_scl.zct *= st_cns.dz ; level number -> height
  st_scl.zmaxcfrac *= st_cns.dz ; level number -> height
  
  st_scl.LWP *= 1000. ; kg/m2 -> g/m2
  st_scl.RWP *= 1000. ; kg/m2 -> g/m2

  ; TODO; g/kg! dla prf

;  print, st_scl.zcb, st_scl.zct, st_scl.LWP, st_scl.RWP, st_scl.cc
;  plot, st_prf.qt, indgen(100)
;  oplot, st_prf.qt_cld, indgen(100)
end
