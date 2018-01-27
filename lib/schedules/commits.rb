require 'rufus-scheduler'

schedule = Rufus::Scheduler.singleton

def commits(owner, repo, branch = 'master', path)
  branch = 'master' if branch.blank?

  puts "Getting commits for #{owner}/#{repo}::#{branch}..."

  commits = []

  current = `git --git-dir=#{path}/.git rev-parse --short HEAD`.strip
  unless current.length == 7
    current = `cat #{path}/REVISION`.strip[0..6]
  end

  deployed = false
  for page in 1..5
    uri = URI.parse("https://api.github.com/repos/#{owner}/#{repo}/commits")
    https = Net::HTTP.new(uri.host, uri.port)
    https.read_timeout = 3
    https.use_ssl = true
    req = Net::HTTP::Get.new(uri.path + "?sha=#{branch}&page=#{page}")
    req['Authorization'] = $avicus['github']['api-auth']
    begin
      res = https.request(req)
    rescue Exception
      break
    end

    json = JSON.parse(res.body).to_a

    if json.size == 0 || !res.response.kind_of?(Net::HTTPSuccess)
      break
    end

    json.each do |commit|
      sha = commit['sha']
      user = commit['commit']['committer']['name']
      user = commit['author']['login'] if commit['author']
      message = commit['commit']['message'].force_encoding('UTF-8')
      date = Time.parse(commit['commit']['committer']['date'])
      next if message =~ /Revert/
      next if message =~ /\[HIDE\]/i
      next if message =~ /Merge (?:branch|pull request)/
      is_current = current == sha[0..6]
      deployed = deployed || is_current
      commits << Commit.new(repo, branch, sha, user, message, date, deployed, is_current)
    end
  end

  puts "Done getting commits for #{owner}/#{repo}::#{branch}"

  unless commits.empty?
    reset_cache "repo.#{repo}-#{branch}"
    set_cache "repo.#{repo}-#{branch}", commits, 1.week
  end
end

Avicus::Application.config.after_initialize do
  # This is so it runs on startup. THREADED!
  Thread.new do
    Avicus::Application.config.repos.each do |rep, vals|
      commits(vals[:owner], vals[:name], vals[:branch], vals[:path])
    end
  end
end

# Schedule which populates the commit cache which is used for the development page.
schedule.every '10m' do
  Avicus::Application.config.repos.each do |rep, vals|
    commits(vals[:owner], vals[:name], vals[:branch], vals[:path])
  end
end
