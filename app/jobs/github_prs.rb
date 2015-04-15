require 'octokit'

Dashing.scheduler.every '1m', :first_in => 0 do |job|
  unless $dashboard_widget_github.nil?
    client = Octokit::Client.new(:access_token => $dashboard_widget_github.access_token)
    my_organization = $dashboard_widget_github.organization_name
    repos = client.organization_repositories(my_organization).map { |repo| repo.name }

    open_pull_requests = repos.inject([]) { |pulls, repo|
      client.pull_requests("#{my_organization}/#{$dashboard_widget_github.repo_name}", :state => 'open').each do |pull|
        pulls.push({
          title: pull.title,
          repo: $dashboard_widget_github.repo_name,
          updated_at: pull.updated_at.strftime("%b %-d %Y, %l:%m %p"),
          creator: "@" + pull.user.login,
          })
      end
      pulls
    }
  Dashing.send_event('open_pull_requests', { header: "Open Pull Requests", pulls: open_pull_requests })
  end
end

