require 'vlad'

namespace :vlad do
  set :god_command, '/usr/bin/god'
  set :god_group, 'app'

  desc "Restart the app servers"

  remote_task :start_app, :roles => :app do
    run "#{god_command} restart #{god_group}"
  end

  desc "Stop the app servers"

  remote_task :stop_app, :roles => :app do
    run "#{god_command} stop #{god_group}"
  end
end
