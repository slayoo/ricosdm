pro ffssp, dir
  
  files = file_search(dir + '/*C130_N130AR*.nc')
  dz = 75
  thickm = 2.
  nmin = 10 ; minimum number of samples per level
  cdncmin = 20 ; minimum concentration (for a sample to be considered, cm-3)

  set_plot, 'ps'
  !P.MULTI=[0,3,1]
  loadct, 4

  for i=0, n_elements(files) - 1 do begin
    flight = strmid(file_basename(files[i]), 26, 4)
    ;device, /color, filename=files[i]+'.ps'
    device, /color, filename=flight + '.ps', /landscape

    buflen = 100
    message, 'opening ' + files[i], /info
    nnc = ncdf_open(files[i])
    file = file_search(dir + '/' + flight + '*0R0001.nc')
    message, 'opening ' + file, /info
    fnc = ncdf_open(file)

    ncdf_diminq, fnc, ncdf_dimid(fnc, 'Time'), tmp, n_t

    lookup = replicate(-1b, n_t)
    levels = dz/2. + findgen(254) * dz

    for j=0l, n_t - 1, buflen do begin
      cnt = buflen < (n_t - j)
      ncdf_varget, fnc, 'FSTFSSP_CTOT', cdnc, count=[cnt], offset=[j]
      ncdf_varget, nnc, 'GGALTC', alt, count=[25, cnt], offset=[0,j]
      alt = total(alt,1) / 25.
      if strmid(file,0,4) eq 'RF07' then begin
        wh = where(cdnc gt cdncmin and cdnc lt 1e4 and alt lt 1400, cn)
      endif else begin
        wh = where(cdnc gt cdncmin and cdnc lt 1e4, cn)
      endelse
      if cn gt 0 then begin
        tmp = replicate(-1b, cn)
        for k=0, cn - 1 do begin 
          tmp[k] = (where(alt[wh[k]] ge levels-dz/2. and alt[wh[k]] lt levels+dz/2.))[0]
        endfor
        lookup[j + wh] = tmp
      endif
    endfor

    clevels = lookup[where(lookup lt 255)]
    clevels = clevels[sort(clevels)]
    clevels = clevels[uniq(clevels)]
    
    plot, [0], [0], /nodata, xrange=[0,200], yrange=[250,1750], xtitle='CDNC [cm-3]', ytitle='height [m]'
    for j=0, n_elements(clevels) - 1 do begin
      wh = where(lookup eq clevels[j], cnt)
      cdnc = fltarr(cnt)
      for k=0, cnt - 1 do begin
        ncdf_varget, fnc, 'FSTFSSP_CTOT', tmp, offset=[wh[k]], count=[1]
        cdnc[k] = tmp[0]
      endfor
      if cnt gt nmin then begin
        srtd = sort(cdnc)
        oplot, [cdnc[srtd[0]],cdnc[srtd[cnt-1]]], replicate(levels[clevels[j]], 2), thick=5*thickm
        oplot, [cdnc[srtd[cnt/20]],cdnc[srtd[19*cnt/20]]], replicate(levels[clevels[j]], 2), thick=20*thickm
        oplot, [cdnc[srtd[cnt/4]],cdnc[srtd[3*cnt/4]]], replicate(levels[clevels[j]], 2), color=255, thick=15*thickm
        oplot, [cdnc[srtd[cnt/2]]], [levels[clevels[j]]], psym=3, thick=10*thickm
      endif
    endfor 

    plot, [0], [0], /nodata, xrange=[0,26], yrange=[250,1750], xtitle='effective radius [um]', ytitle='height [m]'
    for j=0, n_elements(clevels) - 1 do begin
      wh = where(lookup eq clevels[j], cnt)
      reff = fltarr(cnt)
      for k=0, cnt - 1 do begin
        ncdf_varget, fnc, 'FSTFSSP_REFF', tmp, offset=[wh[k]], count=[1]
        reff[k] = tmp[0]
      endfor
      if cnt gt nmin then begin
        srtd = sort(reff)
        oplot, [reff[srtd[0]],reff[srtd[cnt-1]]], replicate(levels[clevels[j]], 2), thick=5*thickm
        oplot, [reff[srtd[cnt/20]],reff[srtd[19*cnt/20]]], replicate(levels[clevels[j]], 2), thick=20*thickm
        oplot, [reff[srtd[cnt/4]],reff[srtd[3*cnt/4]]], replicate(levels[clevels[j]], 2), color=255, thick=15*thickm
        oplot, [reff[srtd[cnt/2]]], [levels[clevels[j]]], psym=3, thick=10*thickm
      endif
    endfor

    plot, [0], [0], /nodata, xrange=[0,6], yrange=[250,1750], xtitle='standard deviation of r [um]', ytitle='height [m]'
    for j=0, n_elements(clevels) - 1 do begin
      wh = where(lookup eq clevels[j], cnt)
      stdv = fltarr(cnt)
      for k=0, cnt - 1 do begin
        ncdf_varget, fnc, 'FSTFSSP_DVOL', tmp_mvd, offset=[wh[k]], count=[1]
        ncdf_varget, fnc, 'FSTFSSP_REFF', tmp_reff, offset=[wh[k]], count=[1]
        ncdf_varget, fnc, 'FSTFSSP_DAVG', tmp_davg, offset=[wh[k]], count=[1]
        stdv[k] = sqrt((tmp_mvd/2.)^3/tmp_reff - (tmp_davg/2.)^2)
      endfor
      if cnt gt nmin then begin
        srtd = sort(stdv)
        oplot, [stdv[srtd[0]],stdv[srtd[cnt-1]]], replicate(levels[clevels[j]], 2), thick=5*thickm
        oplot, [stdv[srtd[cnt/20]],stdv[srtd[19*cnt/20]]], replicate(levels[clevels[j]], 2), thick=20*thickm
        oplot, [stdv[srtd[cnt/4]],stdv[srtd[3*cnt/4]]], replicate(levels[clevels[j]], 2), color=255, thick=15*thickm
        oplot, [stdv[srtd[cnt/2]]], [levels[clevels[j]]], psym=3, thick=10*thickm
      endif
    endfor
   
    ncdf_close, fnc
    ncdf_close, nnc
  endfor 

  device, /close

end
