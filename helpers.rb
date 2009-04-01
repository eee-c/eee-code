module Eee
  module Helpers
    def hours(minutes)
      h = minutes.to_i / 60
      m = minutes.to_i % 60
      h > 0 ? "#{h} hours" : "#{m} minutes"
    end
  end
end
