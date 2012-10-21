pro sdmbin2ncdf, dir, time=time, noupdate=noupdate

  n_moments = 4 ; (including zero-th moement)
  if ~keyword_set(time) then time = ''

  oap_classes = (obj_new('oap2ds'))->getClasses() * 1e-6 ; um -> m

  ; acquireing the number of dumps in the current dir
  files = file_search('/data/slayoo/united/' + dir + '/*dm*' + time + '*.bin.nc', count=cnt)
  if cnt eq 0 then begin
    message, 'no netCDF files found.'
  endif 

  for f=0, n_elements(files) - 1 do begin

    message, 'opening ' + file_basename(files[f]) + '...', /info
    nc = ncdf_open(files[f], /write)

    update = (ncdf_inquire(nc)).ndims eq 4
    if keyword_set(noupdate) and update then begin
      message, /conti, 'skipping update...'
      continue
    endif

    ncdf_varget, nc, 'X', x
    ncdf_varget, nc, 'Y', y
    ncdf_varget, nc, 'Z', z
    dx = x[1] - y[0]
    dy = y[1] - y[0]
    dz = z[1] - z[0]
    mom_ffssp  = fltarr(n_elements(x),n_elements(y),n_elements(z),n_moments)
    psd_oap2ds = fltarr(n_elements(x),n_elements(y),n_elements(z),61)

    sd_files = file_search('/shin-ichiro-*/*/' + dir + '*/*/sdbin_*' + strmid(files[f],21,8,/rev) + '_*.bin', count=cnt)
    if cnt gt 0 then begin
      for sf=0, n_elements(sd_files) - 1 do begin

        ; sdbin: opening, skipping some fortran junk and reading the array sizes
        message, 'opening ' + sd_files[sf] + '...', /info
        openr, ub, sd_files[sf], /get_lun, /swap_endian
        junk = 4 & point_lun, ub, junk
        sd_num = 0l     & readu, ub, sd_num
        sd_numasl = 0l  & readu, ub, sd_numasl 
       
        ; sdbin: sanity check
        expected = 2*junk + 2*4 + 8 * sd_num * (sd_numasl + 6)
        if (file_info(sd_files[sf])).size ne expected then begin
          message, 'bad file size! (' + string((file_info(sd_files[sf])).size ) $
            + ' vs. ' + string(expected) + ')'
        endif

        message, 'processing ' + file_basename(sd_files[sf]) + '...', /info 
        buflen = 1024*1024l*6l ; 10-megabyte buffer
        i = 0l
        while i lt sd_num do begin ;                             .-- 2*4 (sd_num + sd_numasl)
          buflen = buflen < (sd_num - i) ;                       |
          s_x=dblarr(buflen,/noz)  & point_lun, ub, junk + 8l * (1 +  0*sd_num + i) & readu, ub, s_x
          s_y=dblarr(buflen,/noz)  & point_lun, ub, junk + 8l * (1 +  1*sd_num + i) & readu, ub, s_y
          s_z=dblarr(buflen,/noz)  & point_lun, ub, junk + 8l * (1 +  2*sd_num + i) & readu, ub, s_z
          ; v_z                                                       3
          s_r=dblarr(buflen,/noz)  & point_lun, ub, junk + 8l * (1 +  4*sd_num + i) & readu, ub, s_r
          ; sd_asl                                                   ...
          s_n=lon64arr(buflen,/noz) & point_lun, ub, junk + 8l * (1 + (5+sd_numasl)*sd_num + i) & readu, ub, s_n
          
          xi = floor(s_x / dx)
          yi = floor(s_y / dy)
          ki = floor(s_z / dz)

          for b=0l, buflen - 1 do begin
            for m=0l, n_moments - 1 do begin
              ; Fast-FSSP range (particles smaller than 1 um in radius are not listed)
              if s_r[b] lt 24e-6 then mom_ffssp[xi[b], yi[b], ki[b], m] += s_n[b] * (1e6 * s_r[b])^m
              wh = max(where(s_r[b] ge oap_classes/2)) ; OAP classes use diameter! hence "/2"
              if wh ne -1 then psd_oap2ds[xi[b], yi[b], ki[b], wh] += s_n[b]
            endfor
          endfor

          i += buflen
        endwhile

        free_lun, ub

      endfor

      message, 'normalizing...', /info
      mom_ffssp /= (dx * dy * dz * 1e6) ; per cm3!
      psd_oap2ds /= (dx * dy * dz * 1e6) ; per cm3!

      if ~update then ncdf_control, nc, /redef
      sdms = lonarr(n_moments)
      for m=0, n_moments - 1 do begin
        varname = 'sd_m' + string(m, format='(I1)')
        sdms[m] = update $
          ? ncdf_varid(nc, varname) $
          : ncdf_vardef(nc, varname, (ncdf_varinq(nc, 'qc')).dim)
      endfor
      if ~update then psd_d = ncdf_dimdef(nc, 'psd', 61)
      psd_v = update $
        ? ncdf_varid(nc, 'oap2ds') $
        : ncdf_vardef(nc, 'oap2ds', [(ncdf_varinq(nc, 'qc')).dim, psd_d])
      if ~update then ncdf_control, nc, /endef

      for m=0, n_moments - 1 do ncdf_varput, nc, sdms[m], mom_ffssp[*,*,*,m]
      ncdf_varput, nc, psd_v, psd_oap2ds

    endif
    ncdf_close, nc
  endfor
end
