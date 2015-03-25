set terminal pdf enhanced
set output 'graphs/summary.pdf'

set style data histogram

set title 'Summary of Performance Across All Benchmarks'
#set xlabel 'Implementation' rotate by 270
set ylabel 'Geometric Mean Speedup Relative to MRI (s/s)'

set style fill solid border rgb 'black'
set auto x
set xtics nomirror rotate by -45
set yrange [0:*]

plot 'graphs/summary.data' using 2:xtic(1) notitle
