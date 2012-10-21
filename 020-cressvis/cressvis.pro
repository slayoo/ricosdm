pro cressvis, dir, stime=stime, etime=etime, mapx=mapx, $
  sidex=sidex, plotx=plotx, ploty=ploty, ct=ct, nosdm=nosdm

  if ~keyword_set(mapx) then mapx=640
  if ~keyword_set(plotx) then plotx=1200
  if ~keyword_set(ploty) then ploty=600
  if ~keyword_set(sidex) then sidex=640
  if ~keyword_set(ct) then ct=4
  sdm = ~keyword_set(nosdm)

  qrpercthrs = .1
  qrcolor=120
  qcmax = .005
  qrmax = .0005

  knmidata, ['u','v','ql','qr','qt','thetal'], knmi_min, knmi_max

  ; sanity checks for correcntess of arguments
;  if ~keyword_set(dir) || ~file_test(dir, /dir) || ~file_test(dir, /symlink) then $
;    message, 'wrong directory name. (first argument)'

  ; getting list of files
  files = file_search(dir + '/*.nc')
  dates = fix(strmid(files,21,8,/reverse),type=3)
 
  if keyword_set(stime) && keyword_set(etime) then begin
    wh = where(dates gt stime and dates lt etime, cnt) 
    if cnt eq 0 then message, 'wrong time range (stime/etime keyword)'
    dates = dates[wh]
    files = files[wh]
  endif

  ncdfs = lonarr(n_elements(files))
  ;for i=0, n_elements(files) - 1 do begin
  for i=0, 1 do begin
    ncdfs[i] = ncdf_open(files[i], /nowrite)
  endfor
  ncdf_varget, ncdfs[0], 'X', xx
  ncdf_varget, ncdfs[0], 'Y', yy
  ncdf_varget, ncdfs[0], 'Z', zz
  nx = n_elements(xx)
  ny = n_elements(yy)
  nz = n_elements(zz)

  ; assuring correct aspect ratio
  mapy = mapx * (yy[1]-yy[0]) / (xx[1]-xx[0])

  off = 20
  if nx gt 1 then begin
    sidey_x = sidex * (zz[n_elements(zz)-1]+zz[0]) / (xx[n_elements(xx)-1]+xx[0])
print, sidey_x
    window, 0, xsize=sidex, ysize=sidey_x, title='X plane ('+dir+')', xpos=0, ypos=0
    loadct, ct
  endif
  if ny gt 1 then begin
    sidey_y = sidex * (zz[n_elements(zz)-1]+zz[0]) / (yy[n_elements(yy)-1]+yy[0])
print, sidey_y
    window, 1, xsize=sidex, ysize=sidey_y, title='Y plane ('+dir+')', xpos=0, ypos=sidey_y + 3 * off
    loadct, ct
  endif
  window, 2, xsize=mapx+2*off, ysize=mapy+2*off, title='max(XY) ('+dir+')', xpos=off + sidex, ypos=0
  loadct, ct
  window, 3, xsize=plotx, ysize=ploty, title='profiles vs. hourly-averaged profiles ('+dir+')', xpos=0, ypos=0
  if sdm then window, 4, xsize=plotx, ysize=ploty, title='SDM moments scatter-plot'

  sav = 0
  for i=0, n_elements(files) - 1 do begin

    ncdfs[i] = ncdf_open(files[i], /nowrite)

    x = n_elements(xx) / 2 * (mapx / n_elements(xx)) + off
    y = n_elements(yy) / 2 * (mapy / n_elements(yy)) + off
    ncdf_varget, ncdfs[i], 'qc', qc
    ncdf_varget, ncdfs[i], 'qr', qr

    !P.MULTI=[0,3,2]
    if sav then begin 
      set_plot, 'ps'
      message, /info, 'w3.ps'
      device, /color, filename='w3.ps'
    endif else begin
      wset, 3
    endelse
    vars = ['u','v','qc','qr','qv','ptp']
    mltp = [1,  1,  1e3, 1e3, 1e3, 1    ]
    rmin = [-10,-10,0,   0,   0,   295  ]
    rmax = [0,  0,  .05, .005,  20,  315  ]
    xlbl = ['u [m/s]', 'v [m/s]', 'qc [g/kg]', 'qr [g/kg]', 'qv + qc + qr [g/kg]', 'theta vs. theta_l [K]']
    for v = 0, n_elements(vars) - 1 do begin
      ncdf_varget, ncdfs[i], vars[v], tmp
      hour = dates[i]/60/60
      plot, [*knmi_min[v, hour], reverse(*knmi_max[v, hour])], [rebin(zz,n_elements(*knmi_min[v, hour])), reverse(rebin(zz,n_elements(*knmi_min[v, hour])))], $
        xtitle=xlbl[v], ytitle='z', xrange=[rmin[v], rmax[v]], charsize=(sav?1:3)
      if vars[v] eq 'qv' then tmp += qc + qr
      if vars[v] eq 'ptp' then begin
        ncdf_varget, ncdfs[i], 'ptbar', ptbar
        tmp += ptbar
      endif
      oplot, mltp[v] * total(total(tmp, 1) / nx, 1) / ny, zz, color=255
    endfor
    if sav then begin
      device, /close
      set_plot, 'x'
    endif
    !P.MULTI=[0,1,1]

    if sdm then begin
      !P.MULTI=[0,3,1]
      if sav then begin 
        set_plot, 'ps'
        message, /info, 'w4.ps'
        device, /color, filename='w4.ps'
      endif else begin
        wset, 4
      endelse
      ncdf_varget, ncdfs[i], 'sd_m0', sd_m0
      ncdf_varget, ncdfs[i], 'sd_m1', sd_m1
      ncdf_varget, ncdfs[i], 'sd_m2', sd_m2
      ncdf_varget, ncdfs[i], 'sd_m3', sd_m3
      ncdf_varget, ncdfs[i], 'nwsd', nwsd
      ; CDNC
      plot, [0], [0], /nodata, xrange=[0,200], yrange=[250,1750], xtitle='CDNC [cm-3]', ytitle='height [m]', charsize=(sav?1:3)
      for iz=0,nz-1 do begin
        wh = where(sd_m0[*,*,iz] gt 20., cnt)
        if cnt gt 0 then begin
          cdnc = ((sd_m0[*,*,iz])[wh])[*]
          srtd = sort(cdnc)
          oplot, [cdnc[srtd[cnt/20]],cdnc[srtd[19*cnt/20]]], replicate(zz[iz], 2)
          oplot, [cdnc[srtd[cnt/4]],cdnc[srtd[3*cnt/4]]], replicate(zz[iz], 2), color=255
          oplot, [mean(cdnc)], [zz[iz]], psym=3
        endif
      endfor
      ; effective radius
      plot, [0], [0], /nodata, xrange=[0,26], yrange=[250,1750], xtitle='effective radius [um]', ytitle='height [m]', charsize=(sav?1:3)
      for iz=0,nz-1 do begin
        wh = where(sd_m0[*,*,iz] gt 20., cnt)
        if cnt gt 0 then begin
          r_eff = ((sd_m3[*,*,iz])[wh] / (sd_m2[*,*,iz])[wh])[*]
          srtd = sort(r_eff)
          oplot, [r_eff[srtd[cnt/20]],r_eff[srtd[19*cnt/20]]], replicate(zz[iz], 2)
          oplot, [r_eff[srtd[cnt/4]],r_eff[srtd[3*cnt/4]]], replicate(zz[iz], 2), color=255
          oplot, [mean(r_eff)], [zz[iz]], psym=3
        endif
      endfor
      ; standard deviation
      plot, [0], [0], /nodata, xrange=[0,6], yrange=[250,1750], xtitle='standard deviation of r [um]', ytitle='height [m]', charsize=(sav?1:3)
      for iz=0,nz-1 do begin
        wh = where(sd_m0[*,*,iz] gt 20., cnt)
        if cnt gt 0 then begin
          stdev = (sqrt((sd_m2[*,*,iz])[wh]*(sd_m0[*,*,iz])[wh]-(sd_m1[*,*,iz])[wh]*(sd_m1[*,*,iz])[wh]) / (sd_m0[*,*,iz])[wh])[*]
          srtd = sort(stdev)
          oplot, [stdev[srtd[cnt/20]],stdev[srtd[19*cnt/20]]], replicate(zz[iz], 2)
          oplot, [stdev[srtd[cnt/4]],stdev[srtd[3*cnt/4]]], replicate(zz[iz], 2), color=255
          oplot, [mean(stdev,/nan)], [zz[iz]], psym=3
        endif
      endfor
;      ; number of super-droplets
;      plot, [0], [0], /nodata, xrange=[-1,30], yrange=[0,2000], xtitle='nwsd', ytitle='height [m]', charsize=3
;      for iz=0,nz-1 do begin
;        ;oplot, (nwsd[*,*,iz])[*], replicate(zz[iz], nx*ny), psym=3
;        oplot, [mean((nwsd[*,*,iz])[*])], [zz[iz]], psym=6, color=255
;      endfor 
      if sav then begin
        device, /close
        set_plot, 'x'
      endif
      !P.MULTI=[0,1,1]
    endif

    ncdf_varget, ncdfs[i], 'u', u, count=[nx,ny,1], offset=[0,0,nz/2]
    ncdf_varget, ncdfs[i], 'v', v, count=[nx,ny,1], offset=[0,0,nz/2]

    while (x ge off && x - off lt mapx && y ge off && y - off lt mapy) do begin

      x = fix((x - off) / (mapx / n_elements(xx)))
      y = fix((y - off) / (mapy / n_elements(yy)))

      if nx gt 1 then begin
        if sav then begin
          set_plot, 'z'
          device, set_resolution=[sidex,sidey_x]
          loadct, ct
        endif else begin
          wset, 0
        endelse
        tv, bytscl(rebin(reform(qc[*,y,*]), sidex, sidey_x, /sample), max=qcmax) 
        if ~sav then begin
          plots, (sidex / n_elements(xx)) * [x,x], [0,sidey_x], /device
          wh = where(qr[*,y,*] gt qrpercthrs * qrmax, cnt)
          if cnt gt 0 then begin
            ai = array_indices(qr[*,y,*], wh)
            plots, $
              (sidex / n_elements(xx)) * (ai[0,*] + .5), $
              (sidey_x / n_elements(zz)) * (ai[2,*] + .5), psym=3, /device, color=qrcolor
          endif
        endif
        if sav then begin
          message, /info, 'w0.png'
          write_png, 'w0.png', tvrd(/true)
          set_plot, 'x'
        endif
      endif

      if ny gt 1 then begin
        wset, 1
        tv, bytscl(rebin(reform(qc[x,*,*]), sidex, sidey_y, /sample), max=qcmax)
        plots, (sidex / n_elements(yy)) * [y,y], [0,sidey_y], /device
        wh = where(qr[x,*,*] gt qrpercthrs * qrmax, cnt)
        if cnt gt 0 then begin
          ai = array_indices(qr[x,*,*], wh)
          plots, $
            (sidex / n_elements(yy)) * (ai[1,*] + .5), $
            (sidey_y / n_elements(zz)) * (ai[2,*] + .5), psym=3, /device, color=qrcolor
        endif
      endif

      wset, 2
      tv, bytscl(rebin(reform(max(qc,dim=3)), mapx, mapy, /sample), max=qcmax), off, off
      plots, off + [0,mapx], off + (mapy / n_elements(yy)) * [y, y], /device
      plots, off + (mapx / n_elements(xx)) * [x, x], off + [0, mapy], /device

dz = zz[1] - zz[0]
print, dates[i], 'max(qc)=', max(qc), 'max(qr)=', max(qr), 'LWP~', mean(total(qc*dz,3)), 'RWP~', mean(total(qr*dz,3))
    
      sav = 0 & x_old = x & y_old = y
      cursor, x, y
      if x lt off and y lt off then begin
        message, /info, 'saving...'
        sav = 1 
        x = temporary(x_old)
        y = temporary(y_old)
        i -= 1
        break
      endif
       
    endwhile
    ncdf_close, ncdfs[i]
  endfor

end
