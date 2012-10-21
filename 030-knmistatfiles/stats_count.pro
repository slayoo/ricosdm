pro stats_count, st_prf, st_scl, st_cns, nc

  ncdf_varget, nc, 'qv', tmp_qv
  qv = total(total(tmp_qv, 1) / st_cns.nx, 1) / st_cns.ny

  ncdf_varget, nc, 'qc', tmp_qc
  qc = total(total(tmp_qc, 1) / st_cns.nx, 1) / st_cns.ny
  whr = where(tmp_qc gt .01e-3, cnt, complement=cmp) 

  ncdf_varget, nc, 'qr', tmp_qr
  qr = total(total(tmp_qr, 1) / st_cns.nx, 1) / st_cns.ny

  ; calculating air density for LWP and RWP
  ncdf_varget, nc, 'pbar', tmp_pbar
  ncdf_varget, nc, 'pp', tmp_pp
  pres = temporary(tmp_pbar) + temporary(tmp_pp)
  ncdf_varget, nc, 'ptbar', tmp_ptbar
  ncdf_varget, nc, 'ptp', tmp_ptp
  pt = temporary(tmp_ptbar) + temporary(tmp_ptp)
  temp  = pt * exp(st_cns.rddvcp*alog(pres/st_cns.p0)) ; potential temperature => temperature
  v_temp = temp * (1.0+st_cns.epsav*tmp_qv)/(1.0+tmp_qv) ; temperature => virtual temperature
  rhod = pres / (v_temp*st_cns.rd) / (1.0+tmp_qv) ; rhod = rho/(1.0+qv)

  if cnt gt 0 then begin ; if there is any cloud grid point in the domain
    st_scl.rwp += mean(total(rhod*tmp_qr*st_cns.dz, 3))
    tmp_ql = temporary(tmp_qr) + temporary(tmp_qc)
    st_scl.lwp += mean(total(rhod*tmp_ql*st_cns.dz, 3))

    ; marking non-cloudy grid cells with NANs (using the qc>.01e-3 threshold)
    ; any subsequent statistics consider "cloudy" grid points only!
    tmp_ql[cmp] = !VALUES.F_NAN 
    cc_wh = where(total(finite(tmp_ql), 3) gt 0, cc_cnt)
    st_scl.cc += float(cc_cnt) / st_cns.nx / st_cns.ny

    ; computing height-resolved and heigh-averaged statistics
    maxcfrac = 0.
    for z=0, st_cns.nz - 1 do begin
      cfrac_wh = where(finite(tmp_ql[*,*,z]), cfrac_cnt)
      cfrac = float(cfrac_cnt) / st_cns.nx / st_cns.ny
      if maxcfrac lt cfrac then begin
        maxcfrac = cfrac
        st_scl.zmaxcfrac = z
      endif
      st_prf.cfrac[z] += cfrac
      tmp = mean(tmp_ql[*,*,z], /nan)
      if finite(tmp) then begin
        st_prf._cld_cnt[z]++
        st_prf.ql_cld[z] += tmp
        st_scl.zcb <= z
        st_scl.zct >= z + 1 
      endif 
    endfor
    tmp_qt = temporary(tmp_ql) + temporary(tmp_qv) ; nan + anything = nan
    for z=0, st_cns.nz - 1 do begin
      tmp = mean(tmp_qt[*,*,z], /nan)
      if finite(tmp) then st_prf.qt_cld[z] += tmp
    endfor
  endif

  st_prf.qt += qr + qc + qv
  st_prf.ql += qr + qc
  st_prf.qr += qr


end
