set size ratio -1
#set term x11
set term postscript portrait solid "Helvetica" 24
set output "grid_glob.ps"
set noborder
set noxtics ; set noytics
#set title "Computational Mesh"
plot "fort.8081" t'' with l lw .4
#pause -1 "Hit any key to exit..."