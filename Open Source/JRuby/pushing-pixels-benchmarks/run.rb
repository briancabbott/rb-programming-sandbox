# Copyright (c) 2014 Oracle and/or its affiliates. All rights reserved. This
# code is released under a tri EPL/GPL/LGPL license. You can use it,
# redistribute it and/or modify it under the terms of the:
# 
# Eclipse Public License version 1.0
# GNU General Public License version 2
# GNU Lesser General Public License version 2.1

require_relative "config"

def run(benchmarks, configurations)
  benchmarks.each do |benchmark|
    configurations.each do |name, command|
      next if IGNORES.include? [name, benchmark]

      benchmark_file = "benchmarks/#{benchmark}.rb"
      data_file = "data/#{benchmark}-#{name}.data"

      if !File.exist?(data_file) or File.mtime(benchmark_file) > File.mtime(data_file)
        puts "#{command} -I#{WD}/benchmarks -I#{WD}/benchmarks/patterns -r#{benchmark} #{WD}/harness.rb"
        data = `#{command} -I#{WD}/benchmarks -I#{WD}/benchmarks/patterns -r#{benchmark} #{WD}/harness.rb`

        samples = []

        data.lines.each do |line|
          match = line.match(/time: (\d+\.\d+)/)
          samples.push(match[1].to_f) if match
        end

        if samples.size != REPS
          puts data
          puts "error"
        else
          File.open(data_file, "w") do |file|
            file.write(data)
          end
        end
      end
    end
  end
end

run(CHUNKY_BENCHMARKS, CHUNKY_CONFIGURATIONS)
run(PSD_BENCHMARKS, PSD_CONFIGURATIONS)
