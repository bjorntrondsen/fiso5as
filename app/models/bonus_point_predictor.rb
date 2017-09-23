class BonusPointPredictor
  def self.predict(data)
    result = {}
    sorted = (data['bps']['h'] + data['bps']['a']).sort_by{|h| h['value']}.reverse
    current_bp = 4
    last_val = nil
    return result if sorted.first['value'] < 10 # Avoids showing BPs when everyone has the same score
    sorted.each do |bps|
      unless last_val == bps['value']
        current_bp = 3 - result.length
        break if result.length > 2
      end
      break if current_bp == 0
      result[bps['element']] = current_bp
      last_val = bps['value']
    end
    result
  end
end
