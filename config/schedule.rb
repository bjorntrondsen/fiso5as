# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#
# set :output, "/path/to/my/cron_log.log"
#
# every 2.hours do
#   command "/usr/bin/some_great_command"
#   runner "MyModel.some_method"
#   rake "some:great:rake:task"
# end
#
# every 4.days do
#   runner "AnotherModel.prune_old_records"
# end

# Learn more: http://github.com/javan/whenever


# Usage script_with_lock 'script_name', lock: 'lock_name'
# job_type :script_with_lock, "cd :path && :environment_variable=:environment flock -n /var/lock/:lock.lock bundle exec bin/:task :output"
# Usage runner_with_lock 'ruby code', lock: 'lock_name'
job_type :runner_with_lock, "cd :path && flock -n /var/lock/:lock.lock bin/rails runner -e :environment ':task' :output"

# Runs every 2 minutes from 10:00 to 23:00
every '*/2 10-23 * * *' do
  runner_with_lock "GameWeek.sync_open", lock: 'job_runner_fiso5as'
end
