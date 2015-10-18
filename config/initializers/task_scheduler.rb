if Rails.env == 'production'
  scheduler = Rufus::Scheduler.new
  scheduler.every '5m', blocking: true do
    if Time.zone.now.hour > 10 # Dont run at night
      Match.sync_all
    end
  end
end
