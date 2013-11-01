require 'time'

module TFSGraph
  module StoreHelpers
    UPDATED_KEY = "LAST_UPDATED_ON"

    def mark_as_updated(time=nil)
      time ||= Time.now
      Related.redis.set UPDATED_KEY, time.utc
    end

    def last_updated_on
      date = Related.redis.get(UPDATED_KEY)
      return Time.now unless date

      Time.parse(date).localtime
    end
  end
end