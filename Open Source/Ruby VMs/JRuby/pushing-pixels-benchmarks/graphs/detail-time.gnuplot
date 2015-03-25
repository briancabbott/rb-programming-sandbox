set terminal pdf enhanced size 15,5
set output 'graphs/detail-time.pdf'

set style data histogram
set style histogram cluster gap 4

set ylabel "Mean Run Time (s)"
set key top left

set style fill solid border rgb 'black'
set auto x
set xtics rotate by 60 right
set yrange [0:*]

plot 'graphs/detail-time.data' using 2:xtic(1) linecolor rgb '#cc0000' title col, \
        '' using 3:xtic(1) linecolor rgb '#ef2929' title col, \
        '' using 4:xtic(1) linecolor rgb '#888a85' title col, \
        '' using 5:xtic(1) linecolor rgb '#babdb6' title col, \
        '' using 6:xtic(1) linecolor rgb '#dd400' title col, \
        '' using 7:xtic(1) linecolor rgb '#75507b' title col, \
        '' using 8:xtic(1) linecolor rgb '#3465a4' title col
