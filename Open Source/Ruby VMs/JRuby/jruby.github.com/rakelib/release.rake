require 'github_api'
require 'jira'

def github_milestone_for(issues, user, repo, title)
  ['open', 'closed'].each do |state|
    issues.milestones.list(user, repo, state: state) do |milestone|
      return milestone.number if milestone.title == title
    end
  end
  nil
end

##
# return a list of closed issues in a tuple-format: [github_id, title, url]
# 
def github_closed_issues(user, repo, milestone)
  issues = Github::Issues.new(user: user, repo: repo)
  mid = github_milestone_for(issues, user, repo, milestone)

  return nil if mid == -1

  options = { user: user, repo: repo, milestone: mid.to_s, state: 'closed', per_page: 100 }

  full_list = []
  1.upto(1_000_000) do |i|
    options[:page] = i
    page = issues.list(options).map do |issue|
      ['#' + issue.number.to_s, issue.title, issue.html_url]
    end
    return full_list if page.size == 0
    full_list.concat page
  end
  full_list
end

##
# return a list of closed issues in a tuple-format: [github_id, title, url]
#
# options should contain all info needed by jira-ruby gem to connect to Jira.
# Depending on connection mechanism the hash will have different fields.
# 
def jira_closed_issues(project, version, options)
  client = JIRA::Client.new(options)
  query = %Q{project = #{project} AND fixVersion = "#{version}" AND status = Resolved ORDER BY priority DESC}
  url = "#{options[:site]}browse/"

  client.Issue.jql(query).inject([]) do |list, issue|
    attrs = issue.attrs
    list << [attrs['key'], attrs['fields']['summary'], url + attrs['key']]
    list
  end
end

def grab_username_password_from_m2
  username, password = nil, nil
  File.readlines(File.join(ENV['HOME'], '.m2', 'settings.xml')).each do |line|
    if line =~ /<username>([^<]+)<\/username>/
      username = $1
    elsif line =~ /<password>([^<]+)<\/password>/
      password = $1
    end
  end
  [username, password]
end

# FIXME: It would be nice to make text + markdown/html output at some point
def issue_notes_for(name, version, issues, notes)
  notes << "\n### #{name} Issues resolved for #{version}\n\n"

  notes << "<ul>\n"
  issues.each do |issue|
    notes << %Q{<li><a href="#{issue[2]}">#{issue[0]}</a> - #{issue[1]}</li>\n}
  end
  notes << "</ul>\n\n"
  notes
end

def release_issues(version, options)
  milestone_label = "JRuby #{version}"
#  jira_issues = jira_closed_issues('jruby', milestone_label, options)
  github_issues = github_closed_issues('jruby', 'jruby', milestone_label)

#  number_resolved = jira_issues.length + github_issues.length
  number_resolved = github_issues.length

  notes = "- #{number_resolved} issues fixed for #{version}\n"
#  notes = issue_notes_for('Jira', version, jira_issues, notes)
  notes = issue_notes_for('Github', version, github_issues, notes)
  notes
end
