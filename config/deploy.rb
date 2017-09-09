require 'bundler/capistrano'

require "whenever/capistrano"
set :whenever_command, "bundle exec whenever"

load 'deploy/assets'

set :application, "fiso5as"

set :scm, :git
set :repository, "git@github.com:Sharagoz/fiso5as.git"
set :branch, 'master'

server "thor", :app, :web, :db, :primary => true
set :user, 'sysadmin'
set :use_sudo, false

set :deploy_to, "/apps/#{application}"
set :keep_releases, 5

# Rbenv
set :default_environment, {
  'PATH' => "/usr/local/rbenv/shims:/usr/local/rbenv/bin:$PATH"
}

before 'deploy:assets:precompile', 'custom:symlinking'
after "deploy:update", "deploy:cleanup" 

namespace(:custom) do
  task :symlinking, :roles => :app do
    run "ln -nfs /data/rails_data/#{application}/unicorn.rb #{release_path}/config/unicorn.rb"
    run "ln -nfs /data/rails_data/#{application}/database.yml #{release_path}/config/database.yml"
    run "ln -nfs /data/rails_data/#{application}/application.yml #{release_path}/config/application.yml"
    run "ln -nfs /data/rails_shared/newrelic.yml #{release_path}/config/newrelic.yml"
  end
end

namespace :deploy do
  task :start do 
    run "/data/rails_shared/unicorn_init.sh start #{application}"
  end
  task :stop do
    run "/data/rails_shared/unicorn_init.sh stop #{application}"
  end
  task :restart, :roles => :app, :except => { :no_release => true } do
    #run "/data/rails_shared/unicorn_init.sh restart #{application}"
    stop
    wait_for_unicorn_to_stop
    start
  end
end

namespace :deploy do
  namespace :web do
    task :disable, :roles => :web do
      # invoke with  
      # UNTIL="16:00" REASON="a database upgrade" cap deploy:web:disable

      on_rollback { rm "#{shared_path}/system/maintenance.html" }

      require 'erb'
      deadline, reason = ENV['UNTIL'], ENV['REASON']
      maintenance = ERB.new(File.read("./app/views/layouts/maintenance.html.erb")).result(binding)

      put maintenance, "#{shared_path}/system/maintenance.html", :mode => 0644
    end
  end
end

namespace :bundle do
  task :clean, :except => {:no_release => true} do
    bundle_cmd = fetch(:bundle_cmd, "bundle")
    run "cd #{latest_release} && #{bundle_cmd} clean"
  end
end

def wait_for_unicorn_to_stop
  retries = 60 # Give up after 30 seconds
  while retries > 0 && unicorn_pid_file_exists?
    puts "Waiting for PID file to disappear"
    sleep 0.5
    retries -= 1
  end
  puts "UNICORN PID STILL PRESENT. GIVING UP." if retries == 0
end

def unicorn_pid_file_exists?
  path = "/apps/#{application}/shared/pids/unicorn_#{application}.pid"
  results = []
  invoke_command("if [ -e '#{path}' ]; then echo -n 'true'; fi") do |ch, stream, out|
    results << (out == 'true')
  end
  results.any?
end
