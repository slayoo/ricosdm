pro plot_helper, xr=xr, yr=yr, xt=xt, yt=yt, nz=nz, data=data, zz=zz, file=file
  ; plotting

  max = 0
  for iz=0,nz-1 do begin
    max >= n_elements(*data[iz])
  endfor
  min_el = .05 * max ; TODO arbitrary value!

  if keyword_set(file) then openw, u, file, /get_lun

  plot, [0], [0], /nodata, xrange=xr, yrange=yr, xtitle=xt, ytitle='', xmargin=[3,1], ys=4, ymargin=[4,0]
  if xr[0] ne 0 then oplot, [0.,0], yr
  if xt eq 'RH [1]' then oplot, [1.,1], yr
  for iz=0,nz-1 do begin
    if n_elements(*data[iz]) lt min_el then continue
    srtd = sort(*data[iz])
    cnt = n_elements(srtd)
    oplot, [(*data[iz])[srtd[0]],      (*data[iz])[srtd[cnt-1]]    ], replicate(zz[iz], 2)/1000, thick=1
    oplot, [(*data[iz])[srtd[cnt/20]], (*data[iz])[srtd[19*cnt/20]]], replicate(zz[iz], 2)/1000, thick=7
    oplot, [(*data[iz])[srtd[cnt/4]],  (*data[iz])[srtd[3*cnt/4]]  ], replicate(zz[iz], 2)/1000, color=255, thick=4
    oplot, [(*data[iz])[srtd[cnt/2]]], [zz[iz]]/1000, psym=3, thick=5
    if keyword_set(file) then printf, u, zz[iz], interpol((*data[iz])[srtd], 21), format='(22F)'
  endfor

  if keyword_set(file) then free_lun, u

end

function supsat, p=p, th=th, qv=qv
  t = th * exp(287./1004.*alog(p/1e5))
  a = 1. / (t - 35.86)
  b = a * (t - 273.16)
  es = 610.78 * exp(17.269*b)
  qvs = .622 * es / (p - es)
  return, qv / qvs
end

pro nic, var
end

pro allocptrs, arr, nz
  arr = ptrarr(nz) & for iz=0, nz-1 do arr[iz] = ptr_new([!VALUES.F_NAN])
end

pro addpoints, arr, iz, data
  tmp = *(arr[iz])
  ptr_free, arr[iz]
  arr[iz] = ptr_new([temporary(tmp), data[*]])
end

pro trimarr, arr, iz
  if n_elements(*arr[iz])  gt 1 then begin
    tmp =  *arr[iz] & ptr_free,  arr[iz] &  arr[iz] = ptr_new((temporary(tmp))[1:*])
  endif
end

pro ffsspplots_sdm_all, dir
  nmin = 1 ; minimum number of samples TODO!! to jest per level, per plik
  cdncmin = 20 ; cm-3
  
  ncdfs = file_search(dir + '/*.united.bin.nc')

  cdnc = ptrarr(1)
  r_eff = ptrarr(1)
  stdev = ptrarr(1)
  vertv = ptrarr(1)
  ssat = ptrarr(1)
  lwc = ptrarr(1)
  mvr = ptrarr(1)
  kcf = ptrarr(1)

  for i=0l, n_elements(ncdfs) - 1 do begin

    ; skipping Kessler runs
    if strpos(ncdfs[i], '101223') gt 0 then continue

    ; skipping files without SDM data
    nc = ncdf_open(ncdfs[i], /nowrite)
    if (ncdf_inquire(nc)).ndims ne 4 then begin
      ncdf_close, nc
      ;message, 'skipping ' + ncdfs[i], /conti
      continue
    endif

    ; only the last four hours
    time = long(strmid(file_basename(ncdfs[i], '.united.bin.nc'), 8))
    if time lt 72000l then begin
      message, 'skipping ' + ncdfs[i], /conti
      continue
    endif

    message, 'processing ' + ncdfs[i], /conti

    ; mem alloc (happens only once)
    if n_elements(cdnc) eq 1 then begin
      ncdf_varget, nc, 'Z', zz
      nz = n_elements(zz)
      allocptrs, cdnc, nz
      allocptrs, r_eff, nz
      allocptrs, stdev, nz
      allocptrs, vertv, nz
      allocptrs, ssat, nz
      allocptrs, lwc, nz
      allocptrs, mvr, nz
      allocptrs, kcf, nz
    endif

    ncdf_varget, nc, 'sd_m0', sd_m0
    ncdf_varget, nc, 'sd_m1', sd_m1
    ncdf_varget, nc, 'sd_m2', sd_m2
    ncdf_varget, nc, 'sd_m3', sd_m3
    ncdf_varget, nc, 'w', w

    ncdf_varget, nc, 'pbar', pbr
    ncdf_varget, nc, 'ptbar', ptbr
    ncdf_varget, nc, 'ptp', ptp
    ncdf_varget, nc, 'pp', pp
    ncdf_varget, nc, 'qv', qv

    for iz = 0, nz - 1 do begin

      wh = where(sd_m0[*,*,iz] gt cdncmin, cnt)
      if cnt gt nmin then begin

        ; CDNC
        addpoints, cdnc, iz, (sd_m0[*,*,iz])[wh]

        ; r_eff
        addpoints, r_eff, iz, (sd_m3[*,*,iz])[wh] / (sd_m2[*,*,iz])[wh]

        ; stdev
        tmp2 = (sqrt((sd_m2[*,*,iz])[wh] * (sd_m0[*,*,iz])[wh] - (sd_m1[*,*,iz])[wh] * (sd_m1[*,*,iz])[wh]) / (sd_m0[*,*,iz])[wh])[*] 
        tmp3 = where(finite(tmp2), cnt)
        if cnt gt 0 then addpoints, stdev, iz, tmp2[tmp3]
        nic, temporary(tmp3)
        nic, temporary(tmp2)

        ; vertv
        addpoints, vertv, iz, (w[*,*,iz])[wh]

        ; ssat
        addpoints, ssat, iz, supsat($
          p=(pbr[*,*,iz])[wh] + (pp[*,*,iz])[wh], $
          th=(ptbr[*,*,iz])[wh] + (ptp[*,*,iz])[wh], $
          qv=(qv[*,*,iz])[wh] $
        )

        ; lwc [g/m3]
        rho_h2o = 1e-6 
        addpoints, lwc, iz, (sd_m3[*,*,iz])[wh] * rho_h2o * 4./3. * !PI

        ; mvr [um]
        addpoints, mvr, iz, ((sd_m3[*,*,iz])[wh] / (sd_m0[*,*,iz])[wh])^(1./3)

        ; kcf [1]
        addpoints, kcf, iz, ((sd_m2[*,*,iz])[wh])^3 / (sd_m0[*,*,iz])[wh] / ((sd_m3[*,*,iz])[wh])^2

      endif

    endfor

    nic, temporary(sd_m0)
    nic, temporary(sd_m1)
    nic, temporary(sd_m2)
    nic, temporary(sd_m3)
    nic, temporary(w)
    nic, temporary(pbr)
    nic, temporary(ptbr)
    nic, temporary(ptp)
    nic, temporary(pp)
    nic, temporary(qv)

    ncdf_close, nc
  endfor

  for iz=0, nz-1 do begin
    trimarr, cdnc, iz
    trimarr, r_eff, iz
    trimarr, stdev, iz
    trimarr, vertv, iz
    trimarr, ssat, iz
    trimarr, lwc, iz
    trimarr, mvr, iz
    trimarr, kcf, iz
  endfor

  yr = [.25,1.75]
  !P.MULTI=[17,6,3]
  set_plot, 'ps'
  device, filename=file_basename(dir) + '.ps', /color, /landscape
  loadct, 4
  plot_helper, xr=[-1.5,3.5], yr=yr, xt='vertical velocity', yt='height [m]', nz=nz, data=vertv, zz=zz, file=file_basename(dir) + '_w'
  !P.MULTI=[0,1,1]
  axis, yaxis=0, ytitle='height [km]', charsize=.5
  !P.MULTI=[16,6,3]
  plot_helper, xr=[0.975,1.025], yr=yr, xt='RH [1]', yt='height [m]', nz=nz, data=ssat, zz=zz, file=file_basename(dir) + '_RH'
  plot_helper, xr=[0,200], yr=yr, xt='CDNC [cm-3]', yt='height [m]', nz=nz, data=cdnc, zz=zz, file=file_basename(dir) + '_CDNC'
  plot_helper, xr=[0,26], yr=yr, xt='effective radius [um]', yt='height [m]', nz=nz, data=r_eff, zz=zz, file=file_basename(dir) + '_reff'
  plot_helper, xr=[0,8], yr=yr, xt='standard dev. of r [um]', yt='height [m]', nz=nz, data=stdev, zz=zz, file=file_basename(dir) + '_stdev'
  plot_helper, xr=[0,.06], yr=yr, xt='LWC [g/m3]', yt='height [m]', nz=nz, data=lwc, zz=zz, file=file_basename(dir) + '_lwc'
  plot_helper, xr=[0,8], yr=yr, xt='MVR [um]', yt='height [m]', nz=nz, data=mvr, zz=zz, file=file_basename(dir) + '_mvr'
  plot_helper, xr=[0,1], yr=yr, xt='k [1]', yt='height [m]', nz=nz, data=kcf, zz=zz, file=file_basename(dir) + '_kcf'
  device, /close

end

