function half, arr
  return, arr[*,*,0:(size(arr))[3]/2]
end
pro genframes, dir

  mapx=640
  sidex=640
  ; good ones: 1, 4, 11
  ct=1
  psy=6

  qrpercthrs = .1
  qrcolor=255
  qcmax = .0025
  qrmax = .0005
  sim = file_basename(dir)
  file_mkdir, sim

  ; sanity checks for correcntess of arguments
  if ~keyword_set(dir) || ~file_test(dir, /dir) then $
    message, 'wrong directory name. (first argument)'

  ; getting list of files
  files = file_search(dir + '/*united.bin.nc')
  dates = fix(strmid(files,21,8,/reverse),type=3)
 
  ncdfs = lonarr(n_elements(files))
  ncdfs[0] = ncdf_open(files[0], /nowrite)
  ncdf_varget, ncdfs[0], 'X', xx
  ncdf_varget, ncdfs[0], 'Y', yy
  ncdf_varget, ncdfs[0], 'Z', zz
  nx = n_elements(xx)
  ny = n_elements(yy)
  nz = n_elements(zz)

  x = 0
  y = 0

  ; assuring correct aspect ratio
  mapy = mapx * (yy[1]-yy[0]) / (xx[1]-xx[0])
  sidey_x = sidex * (zz[n_elements(zz)-1]+zz[0]) / (xx[n_elements(xx)-1]+xx[0])
  sidey_y = sidex * (zz[n_elements(zz)-1]+zz[0]) / (yy[n_elements(yy)-1]+yy[0])

  set_plot, 'z'
  device, decomposed=0, set_pixel_depth=24

  ;for i=0, n_elements(files) - 1 do begin
; TEMP!!!
  fn=0
  for i=20*60l, n_elements(files) - 1 do begin
    ncdfs[i] = ncdf_open(files[i], /nowrite)
    ncdf_varget, ncdfs[i], 'qc', qc
    ncdf_varget, ncdfs[i], 'qr', qr
    filenpfx = sim + '/' + string(fn, format='(I05)')

    device, set_resolution=[sidex,sidey_x], decomposed=0, set_pixel_depth=24
    loadct, ct, /silent
    tv, bytscl(rebin(reform(qc[*,y,*]), sidex, sidey_x, /sample), max=qcmax) 
    plots, (sidex / n_elements(xx)) * [x,x], [0,sidey_x], /device
    wh = where(qr[*,y,*] gt qrpercthrs * qrmax, cnt)
    if cnt gt 0 then begin
      ai = array_indices(qr[*,y,*], wh)
      ;loadct, 14, /silent
      plots, $
        (sidex / n_elements(xx)) * (ai[0,*] + .5), $
        (sidey_x / n_elements(zz)) * (ai[2,*] + .5), psym=psy, /device, color=qrcolor
    endif
    write_png, filenpfx + '-x.png', half(tvrd(true=1))

    device, set_resolution=[sidex,sidey_x], decomposed=0, set_pixel_depth=24
    loadct, ct, /silent
    tv, bytscl(rebin(reform(qc[x,*,*]), sidex, sidey_y, /sample), max=qcmax)
    plots, (sidex / n_elements(yy)) * [y,y], [0,sidey_y], /device
    wh = where(qr[x,*,*] gt qrpercthrs * qrmax, cnt)
    if cnt gt 0 then begin
      ai = array_indices(qr[x,*,*], wh)
      ;loadct, 14, /silent
      plots, $
        (sidex / n_elements(yy)) * (ai[1,*] + .5), $
        (sidey_y / n_elements(zz)) * (ai[2,*] + .5), psym=psy, /device, color=qrcolor
    endif
    write_png, filenpfx + '-y.png', reverse(half(tvrd(true=1)),2)

    device, set_resolution=[mapx,mapy]
    loadct, ct, /silent
    tv, bytscl(rebin(reform(max(qc,dim=3)), mapx, mapy, /sample), max=qcmax),0,0 
    maxqr = max(qr,dim=3)
    wh = where(maxqr gt qrpercthrs * qrmax, cnt)
    if cnt gt 0 then begin
      ai = array_indices(maxqr, wh)
      ;loadct, 14, /silent
      plots, $
        (mapx / n_elements(xx)) * (ai[0,*] + .5), $
        (mapy / n_elements(yy)) * (ai[1,*] + .5), psym=psy, /device, color=qrcolor
    endif
    plots, [0,mapx], (mapy / n_elements(yy)) * [y, y], /device
    plots, (mapx / n_elements(xx)) * [x, x], [0, mapy], /device
    write_png, filenpfx + '-z.png', tvrd(true=1)

    ncdf_close, ncdfs[i]
    fn++
  endfor
end
