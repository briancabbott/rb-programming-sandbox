require 'open-uri'
# Grab data from a URL

open("http://www.yahoo.com") {|page| page.each_line {|line| puts line}}
