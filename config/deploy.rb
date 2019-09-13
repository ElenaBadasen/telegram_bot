# config valid for current version and patch releases of Capistrano
lock "~> 3.11.0"

set :application, "mayor_organizer"
set :repo_url, "git@mayor.idzaaus.org:mayor.git"
set :user, 'tivel'
set :rvm_type, :system
set :rvm_custom_path, '/usr/share/rvm'

set :pty,             false
set :use_sudo,        false
set :deploy_via,      :remote_cache
set :deploy_to,       "/home/#{fetch(:user)}/#{fetch(:application)}"
set :puma_bind,       "unix://#{shared_path}/tmp/sockets/#{fetch(:application)}-puma.sock"
set :puma_state,      "#{shared_path}/tmp/pids/puma.state"
set :puma_pid,        "#{shared_path}/tmp/pids/puma.pid"
set :puma_access_log, "#{release_path}/log/puma.error.log"
set :puma_error_log,  "#{release_path}/log/puma.access.log"
set :ssh_options,     { forward_agent: true, user: fetch(:user), keys: %w(~/.ssh/id_rsa.pub) }
set :puma_preload_app, true
set :puma_worker_timeout, nil
set :puma_init_active_record, true
set :keep_releases, 5

set :linked_files, %w{config/database.yml config/secrets.yml}
set :linked_dirs,  %w{log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system storage}

namespace :sidekiq do
  task :stop do
    on roles(:app) do
      execute! :sudo, :systemctl, :stop, 'sidekiq'
    end

  end
  task :restart do
    on roles(:app) do
      execute! :sudo, :systemctl, :restart, 'sidekiq'
    end
  end
end

namespace :puma do
  desc 'Puma dirs'
  task :make_dirs do
    on roles(:web) do
      execute "mkdir #{shared_path}/tmp/sockets -p"
      execute "mkdir #{shared_path}/tmp/pids -p"
    end
  end

  before :start, :make_dirs
end

namespace :deploy do

  desc 'Initial Deploy'
  task :initial do
    on roles(:web) do
      before 'deploy:restart', 'puma:start'
      invoke 'deploy'
    end
  end

  desc 'Restart application'
  task :restart do
    on roles(:web) do
      invoke 'puma:restart'
    end
  end

  after  :finishing,    :compile_assets
  after  :finishing,    :cleanup
  after  :finishing,    :restart

end

namespace :deploy  do
  after :finishing, 'puma:restart'
  after :finishing, 'sidekiq:restart'
  before 'deploy:migrate', 'sidekiq:stop'
end

# Default branch is :master
# ask :branch, `git rev-parse --abbrev-ref HEAD`.chomp

# Default deploy_to directory is /var/www/my_app_name
# set :deploy_to, "/var/www/my_app_name"

# Default value for :format is :airbrussh.
# set :format, :airbrussh

# You can configure the Airbrussh format using :format_options.
# These are the defaults.
# set :format_options, command_output: true, log_file: "log/capistrano.log", color: :auto, truncate: :auto

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
# append :linked_files, "config/database.yml"

# Default value for linked_dirs is []
# append :linked_dirs, "log", "tmp/pids", "tmp/cache", "tmp/sockets", "public/system"

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for local_user is ENV['USER']
# set :local_user, -> { `git config user.name`.chomp }

# Default value for keep_releases is 5
# set :keep_releases, 5

# Uncomment the following to require manually verifying the host key before first deploy.
# set :ssh_options, verify_host_key: :secure
