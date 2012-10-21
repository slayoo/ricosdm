.compile ../020-cressvis/knmidata.pro
;vars = ['qt', 'ql', 'qr', 'qt_cld', 'ql_cld']
vars = ['ql', 'qr']
knmidata, vars, min, max
profilepro, vars, min, max
exit
