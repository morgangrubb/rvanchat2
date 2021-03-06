# config valid only for current version of Capistrano
lock '3.4.0'

set :application, 'rvanchat'
set :repo_url, 'git@github.com:morgangrubb/rvanchat2.git'

# Capfile
require 'capistrano/rbenv'

# config/deploy.rb
set :rbenv_type, :user # or :system, depends on your rbenv setup
# set :rbenv_ruby, '2.0.0-p247'

# in case you want to set ruby version from the file:
set :rbenv_ruby, File.read('.ruby-version').strip

set :rbenv_prefix, "RBENV_ROOT=#{fetch(:rbenv_path)} RBENV_VERSION=#{fetch(:rbenv_ruby)} #{fetch(:rbenv_path)}/bin/rbenv exec"
set :rbenv_map_bins, %w{rake gem bundle ruby rails}
set :rbenv_roles, :all # default value

# set :rbenv_ruby, '2.2.1'

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
set :linked_dirs, fetch(:linked_dirs, []).push('log', 'prosody', 'saves')

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
