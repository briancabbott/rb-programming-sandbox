# Hack for now to get rid of: OpenSSL::SSL::SSLError: hostname "jruby.org.s3.amazonaws.com" does not match the server certificate
require 'fog'

Fog.credentials = { path_style: true }

INDEXED_FOLDERS = %w(downloads prerelease presentations tryjruby)

def sorted_files
  entries = []
  INDEXED_FOLDERS.each do |folder|
    collection = jruby_org_bucket.files.dup
    collection.prefix = folder
    collection.each do |f|
      puts "f.key = #{f.key}"
      entries << f.key.sub(/_\$folder\$$/, '/')
    end
  end
  dirs = {"." => []}
  entries.sort.each do |f|
    dirs[File.dirname(f)] ||= []
    dirs[File.dirname(f)] << f
  end
  dirs
end

def write_index_html(html, dir, entries)
  html.puts <<HDR
---
layout: main
title: Files/#{dir == '.' ? '' : dir}
---
<h1>Files/#{dir == '.' ? '' : dir}</h1>
<p class="trackDownloads">
HDR
  parent = File.dirname(dir)
  parent = parent == '.' ? '' : "#{parent}/"
  html.puts "  <a href='/files/#{parent}index.html'>..</a><br/>" unless dir == '.'
  entries.sort.each do |entry|
    if entry =~ /\/$/
      html.puts "  <a href='/files/#{entry}index.html'>#{File.basename(entry)}</a><br/>"
    else
      html.puts "  <a href='https://s3.amazonaws.com/jruby.org/#{entry}'>#{File.basename(entry)}</a><br/>"
    end
  end
  html.puts "</p>"
end

def s3_connection
  @connection ||= begin
                    require 'fog'
                    ey_cloud = open(File.expand_path('~/.ey-cloud.yml')) { |f| YAML::load(f) }
                    Fog::Storage.new(:provider => 'AWS', :aws_secret_access_key => ey_cloud[:aws_secret_key],
                                     :aws_access_key_id => ey_cloud[:aws_secret_id])
                  end
end

def jruby_org_bucket
  @bucket ||= s3_connection.directories.get('jruby.org')
end

##
# Yield all files and not directories unless you want those too.
# === Examples
# jruby_org_s3_in('directories')
def jruby_org_s3_in(subdir, folder=false)
  subdir += '/' if !subdir.end_with? '/'
  jruby_org_bucket.files.tap {|fs| fs.prefix = subdir }.each do |f|
    yield f if folder || f.key !~ /_\$folder\$$/
  end
end

def log_line_match(line)
  unless @line_def
    require 'request_log_analyzer'
    require 'request_log_analyzer/file_format'
    require 'request_log_analyzer/file_format/amazon_s3'
    @format = RequestLogAnalyzer::FileFormat::AmazonS3.create
    @req = @format.request
    @line_def = @format.line_definitions[:access]
    # Bleh. R-L-A's S3 format is a little buggy, this fixes it
    @line_def.regexp = Regexp.new(@line_def.regexp.to_s.sub('(\\d+) (\\d+) (\\d+) (\\d+)', '([^\\ ]+) ([^\\ ]+) ([^\\ ]+) ([^\\ ]+)'))
  end
  @line_def.match_for(line, @req)
end

require 'date'
def jruby_download_summary(date = nil, output = nil)
  date ||= Date.today - 1
  output = File.new(output, "w") if String === output
  output ||= $stdout
  log_objects = s3_connection.directories.get('jrubylogs', :prefix => "jruby-access-log/#{date.to_s}").files
  requests = {}
  user_agents = {}
  log_objects.each do |log|
    log.body.lines.each do |line|
      match_hash = log_line_match(line)
      if match_hash && match_hash[:key] &&
          match_hash[:http_status] == 200 &&
          match_hash[:bytes_sent] == match_hash[:object_size]
        file = match_hash[:key]
        if file =~ /.(zip|exe|tar\.gz)$/
          requests[file] ||= 0
          requests[file] += 1
        end
        if ua = match_hash[:user_agent]
          ua = ua[0..20] + '...'
          user_agents[ua] ||= 0
          user_agents[ua] += 1
        end
      end
    end
  end
  if requests.size == 0
    output.puts "No requests on #{date}"
  else
    total = 0
    max_width = requests.keys.max {|a,b| a.length <=> b.length }.length
    requests.keys.sort.each do |k|
      total += requests[k]
      output.puts "%-#{max_width}s  %s" % [k, requests[k]]
    end
    output.puts "%-#{max_width}s  %s" % ["Total", total]
  end
  if user_agents.size > 0
    output.puts
    max_width = user_agents.keys.max {|a,b| a.length <=> b.length }.length
    user_agents.to_a.sort {|a,b| b[1] <=> a[1]}.each do |agent, count|
      output.puts "%-#{max_width}s  %s" % [agent, count]
    end
  end
end
