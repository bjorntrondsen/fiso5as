if Rails.env == 'production'
  scheduler = Rufus::Scheduler.new
  scheduler.every '5m', blocking: true do
    if Time.zone.now.hour > 10 # Dont run at night
      Match.active.each{|m| m.fpl_sync }
    end
  end
end
