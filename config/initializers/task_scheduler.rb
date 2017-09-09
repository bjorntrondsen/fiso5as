if Rails.env == 'production'
  scheduler = Rufus::Scheduler.new
  #scheduler.every '2m', blocking: true do
    #if Time.zone.now.hour > 10 # Dont run at night
      #Match.sync_all
    #end
  #end
  scheduler.every '10s', blocking: true do
    sleep(5)
  end
end
