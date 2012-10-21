function style, run, title=title
  t = keyword_set(title)
  case run of
    '10122302': return, (~t?"not":"t 'blk-coarse'") + "      lw 1  lc rgb 'red'"
    '10122304': return, (~t?"not":"t 'blk-middle'") + "      lw 1  lc rgb 'blue'" 
    '10122404': return, (~t?"not":"t 'sdm-coarse-512'") + "  lw 8 lc rgb 'red'" 
    '10122403': return, (~t?"not":"t 'sdm-coarse-128'") + "  lw 6 lc rgb 'red'" 
    '10122402': return, (~t?"not":"t 'sdm-coarse-32'") + "   lw 4 lc rgb 'red'"
    '10122401': return, (~t?"not":"t 'sdm-coarse-8'") + "    lw 2 lc rgb 'red'"
    '10122803': return, (~t?"not":"t 'sdm-middle-128'") + "  lw 8 lc rgb 'blue'"  
    '10122802': return, (~t?"not":"t 'sdm-middle-32'") + "   lw 6 lc rgb 'blue'"  
    '10122801': return, (~t?"not":"t 'sdm-middle-8'") + "    lw 4 lc rgb 'blue'"  
    '12010417': return, (~t?"not":"t 'sdm-high-32'") + "     lw 8 lc rgb 'green'"
    '11010502': return, (~t?"not":"t 'sdm-high-8'") + "      lw 6 lc rgb 'green'"
    '11061401': return, (~t?"not":"t 'sdm-middle-32-a'") + " lw 6 lc rgb 'yellow'"
    '11061403': return, (~t?"not":"t 'sdm-middle-32-b'") + " lw 6 lc rgb 'brown'"
    '11061404': return, (~t?"not":"t 'sdm-middle-32-c'") + " lw 6 lc rgb 'pink'"
    '11061402': return, (~t?"not":"t 'sdm-middle-32-d'") + " lw 6 lc rgb 'magenta'"
    else: message, 'undefined style for: ' + run
  endcase
end
