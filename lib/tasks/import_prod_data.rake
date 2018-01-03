desc "Copy DB and assets from production server"
task :import_prod_data => :environment do

  STDOUT.puts 'WARNING: Local database and assets will be overwritten. Press y to continue.'
  confirm = STDIN.gets.strip
  unless confirm == 'y'
    STDOUT.puts 'Task aborted'
    exit
  end

  settings = YAML::load(File.open(Rails.root + 'config/import_prod_data.yml'))

  Net::SSH.start(settings[:remote_machine][:ssh][:host], settings[:remote_machine][:ssh][:user]) do |ssh|
    STDOUT.puts 'Fetching database'
    remote_path = '/tmp/db_export.sql'
    local_path = Rails.root.to_s + '/tmp/db_export.sql'
    ssh.exec! "mysqldump --user=#{settings[:remote_machine][:db][:user]} --password=#{settings[:remote_machine][:db][:password]} #{settings[:remote_machine][:db][:name]} > #{remote_path}"
    ssh.scp.download!(remote_path, local_path) do |ch, name, received, total|
      percentage = format('%.2f', received.to_f / total.to_f * 100) + '%'
      print "Saving to #{name}: Received #{received/1_000_000}/#{total/1_000_000} MB" + " (#{percentage})               \r"
      STDOUT.flush
    end
    sh "mysql --user=#{settings[:local_machine][:db][:user]} --password=#{settings[:local_machine][:db][:password]} #{settings[:local_machine][:db][:name]} < #{local_path}"
    sh "rm #{local_path}"

    STDOUT.puts 'Database successfully imported'
    STDOUT.puts 'Fetching assets'
  end
end
