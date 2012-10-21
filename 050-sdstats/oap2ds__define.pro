function oap2ds::init
  ; left edges, in micrometers, diameter (assumed from the paper and docs)
  self.classes = [$
    5, 15, 25, 35, 45, 55, 65, 75, 85, 95, 105, 115, 125, 135, 145, $
    155, 165, 175, 185, 195, 205, 225, 245, 265, 285, 305, 325, 345, $
    365, 385, 405, 425, 445, 465, 485, 505, 555, 605, 655, 705, 755, $
    805, 855, 905, 955, 1005, 1105, 1205, 1305, 1405, 1505, 1605, 1705, $
    1805, 1905, 2005, 2205, 2405, 2605, 2805, 3005 $
  ]
  return, 1
end

function oap2ds::getClasses
  return, self.classes
end

pro oap2ds__define
  struct = {oap2ds, classes : fltarr(61)}
end
