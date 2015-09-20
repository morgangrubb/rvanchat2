# config valid only for current version of Capistrano
lock '3.4.0'

set :application, 'rvanchat'
set :repo_url, 'git@github.com:morgangrubb/rvanchat2.git'
set :rbenv_ruby, '2.2.1'

# Default branch is :master
# ask :branch, `git rev-parse --abbrev-ref HEAD`.chomp

# Default deploy_to directory is /var/www/my_app_name
set :deploy_to, '/home/miggles/rvanchat'

# Default value for :scm is :git
# set :scm, :git

# Default value for :format is :pretty
# set :format, :pretty

# Default value for :log_level is :debug
set :log_level, :debug

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
set :linked_files, fetch(:linked_files, []).push('config/database.yml', 'config/constants.rb', 'config/redis.yml', 'config/yt.yml')

# Default value for linked_dirs is []
set :linked_dirs, fetch(:linked_dirs, []).push('log', 'prosody')

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for keep_releases is 5
# set :keep_releases, 5

namespace :prosody do
  task :update_modules do
    on roles(:web) do
      execute "cd /opt/prosody-modules && sudo hg pull --update"
      execute "sudo prosodyctl reload"
    end
  end
end

namespace :deploy do

  after :restart, :clear_cache do
    on roles(:web), in: :groups, limit: 3, wait: 10 do
      execute "sudo service wopr restart"
    end
  end

end
