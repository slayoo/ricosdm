pro scale, oap
  oap_classes = (obj_new('oap2ds'))->getClasses() 
 
  oap = oap[0:60] ; skipping last class (as it covers "infinity")
  oap *= 1e3; cm-3 -> l-1
  oap /= (oap_classes[1:60] - oap_classes[0:59]) ; dividing by bin sizes
  wh = where(oap eq 0, cnt)
  if cnt gt 0 then oap[wh] = !VALUES.F_NAN
end

pro oapplots, simul

  qr_tres = .001e-3
  zz_min = 183-100
  zz_max = 183+100

  oap_classes = (obj_new('oap2ds'))->getClasses() 

  ; TEMP!!!
  sims = file_search('/data/slayoo/united/' + simul)
  for s=0, n_elements(sims) - 1 do begin
    files = file_search(sims[s] + '/*.united.bin.nc')
    ;oapmin = replicate(1e20, 61)
    oapavg = fltarr(61)
    ;oapmax = replicate(0., 61)
    oapcnt = 0l

; TODO: last four hours?
    first = n_elements(files) - 5*60l
print, first, n_elements(files)
    files = files[first:n_elements(files) - 1]
    scanned = bytarr(n_elements(files))

    for f=0, n_elements(files) - 1 do begin
      nc = ncdf_open(files[f], /nowrite)
      if f eq 0 then begin
        ncdf_varget, nc, 'Z', zz
        ncdf_varget, nc, 'qc', tmp
        zz = rebin(reform(zz,1,1,(size(tmp))[3]), (size(tmp))[1:3])
      endif
      if (ncdf_inquire(nc)).ndims eq 4 then begin
        scanned[f] = 1
        message, /conti, 'processing ' + files[f] + '...'
        ncdf_varget, nc, 'qr', qr
        ncdf_varget, nc, 'oap2ds', oap
        wh = where(qr gt qr_tres and zz lt zz_max and zz gt zz_min, cnt)
        if cnt gt 0 then begin
          ai = array_indices(qr, wh)
          if n_elements(ai) eq 3 then ai = reform(ai,3,1)
          for a=0, (size(ai))[2] - 1 do begin
            oapavg += oap[ai[0,a],ai[1,a],ai[2,a],*]
            ;oapmin <= oap[ai[0,a],ai[1,a],ai[2,a],*]
            ;oapmax >= oap[ai[0,a],ai[1,a],ai[2,a],*]
            oapcnt++
          endfor
        endif
      endif
      ncdf_close, nc
    endfor
    oapavg /= oapcnt ; averaging
    scale, oapavg
    ;scale, oapmax
    ;scale, oapmin

    x = oap_classes[0:59] + .5 * (oap_classes[1:60] - oap_classes[0:59])

    set_plot, 'ps'
    device, filename=file_basename(sims[s])+'.ps', /landscape
    plot, x, oapavg, /xlog, /ylog, $
      psym=10, xtitle='particle diameter [um]', xrange=[10,3e3], yrange=[.5e-6,2], ytitle='concentration [#/L/um]', $
      title='simulated OAP-2DS mean spectrum (last 4h, alt:200-300 m, qr>.001 g/kg)'
    ;oplot, x, oapmax, psym=10
    ;oplot, x, oapmin, thick=5
    device, /close
    openw, u, file_basename(sims[s])+'.txt', /get_lun
    printf, u, '# zz_min=' + strtrim(zz_min,2) + ' zz_max=' + strtrim(zz_max,2) + ' qr_tres=' + strtrim(qr_tres,2)
    printf, u, '# files: ' + files[where(scanned eq 1)]
    for i=0, n_elements(x) - 1 do printf, u, x[i], oapavg[i];, oapmin[i], oapmax[i]
    free_lun, u
  endfor 
end
