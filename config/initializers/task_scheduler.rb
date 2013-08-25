if Rails.env == 'production'
  scheduler = Rufus::Scheduler.new
  scheduler.every '5m', blocking: true do
    # Runs from 13:00- 23.59
    if Time.zone.now.hour > 12
      GameweeksController.get_matches
    end
  end
end
