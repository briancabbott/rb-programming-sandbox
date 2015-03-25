# Copyright (c) 2014 Oracle and/or its affiliates. All rights reserved. This
# code is released under a tri EPL/GPL/LGPL license. You can use it,
# redistribute it and/or modify it under the terms of the:
# 
# Eclipse Public License version 1.0
# GNU General Public License version 2
# GNU Lesser General Public License version 2.1

require_relative "perfer/lib/perfer/statistics"
require_relative "statistics"
require_relative "config"

def read_samples(file)
  samples = []

  File.read(file).lines.each do |line|
    match = line.match(/time: (\d+\.\d+)/)
    samples.push(match[1].to_f) if match
  end

  samples
end

benchmark_samples = {}
total_samples = []

BENCHMARKS.each do |benchmark|
  CONFIGURATIONS.each do |configuration|
    benchmark_samples[benchmark] = {} if benchmark_samples[benchmark] == nil
    benchmark_samples[benchmark][configuration] = []

    next if IGNORES.include? [configuration, benchmark]
    
    if File.exist? "data/#{benchmark}-#{configuration}.data"
      samples = read_samples("data/#{benchmark}-#{configuration}.data")
      total_samples.push(*samples)

      if samples.length == 0
        puts "#{benchmark}-#{configuration} failed"
      else
        benchmark_samples[benchmark][configuration] = samples.drop(WARMUP)
      end
    else
      puts "#{benchmark}-#{configuration} failed"
    end
  end
end

def speedup_summary(benchmark_samples, from, to)
  benchmarks_with_enough_data = BENCHMARKS.select do |benchmark|
    not (benchmark_samples[benchmark][from].empty? || benchmark_samples[benchmark][to].empty?)
  end

  speedups = benchmarks_with_enough_data.map do |benchmark|
    from_mean = Perfer::Statistics.new(benchmark_samples[benchmark][from]).mean
    to_mean = Perfer::Statistics.new(benchmark_samples[benchmark][to]).mean
    from_mean / to_mean
  end

  speedups = speedups.select do |speedup|
    not speedup.nan?
  end

  min = speedups.min
  geomean = Perfer::Statistics.new(speedups).geomean
  max = speedups.max
  [min, geomean, max]
end

def speedup_summary_string(benchmark_samples, from, to)
  min, geomean, max = speedup_summary(benchmark_samples, from, to)
  "#{geomean.round(2)}x geometric mean (min #{min.round(2)}x, max #{max.round(2)}x)"
end

puts

CONFIGURATIONS.each do |baseline|
  CONFIGURATIONS.each do |compared|
    next if baseline == compared
    puts "speedup #{baseline} -> #{compared}: #{speedup_summary_string(benchmark_samples, baseline, compared)}"
  end
  puts
end

File.open("graphs/detail-time.data", "w") do |file|
  file.write("Benchmark")

  CONFIGURATIONS.each do |configuration|
    file.write(" \"#{FULL_NAMES[configuration]}\"")
  end

  file.write("\n")

  BENCHMARKS.each do |benchmark|
    file.write("#{benchmark}")

    CONFIGURATIONS.each do |configuration|
      file.write(" #{Perfer::Statistics.new(benchmark_samples[benchmark][configuration]).mean}")
    end

    file.write("\n")
  end
end

`gnuplot graphs/detail-time.gnuplot`

File.open("graphs/detail-speedup.data", "w") do |file|
  file.write("Benchmark")

  CONFIGURATIONS.each do |configuration|
    file.write(" \"#{FULL_NAMES[configuration]}\"")
  end

  file.write("\n")

  BENCHMARKS.each do |benchmark|
    file.write("#{benchmark}")

    CONFIGURATIONS.each do |configuration|
      from_mean = Perfer::Statistics.new(benchmark_samples[benchmark]["mri"]).mean
      to_mean = Perfer::Statistics.new(benchmark_samples[benchmark][configuration]).mean
      speedup = from_mean / to_mean
      file.write(" #{speedup}")
    end

    file.write("\n")
  end
end

`gnuplot graphs/detail-speedup.gnuplot`
`gnuplot graphs/detail-speedup-log.gnuplot`

File.open("graphs/summary.data", "w") do |file|
  CONFIGURATIONS.each do |configuration|
    min, geomean, max = speedup_summary(benchmark_samples, "mri", configuration)
    file.write("\"#{FULL_NAMES[configuration]}\" #{geomean} #{min} #{max}\n")
  end
end

`gnuplot graphs/summary.gnuplot`

puts "total time: #{(total_samples.inject(&:+)/60/60).round} hours"
