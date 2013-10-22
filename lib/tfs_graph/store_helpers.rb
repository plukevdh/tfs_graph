require 'time'

module TFSGraph
  module StoreHelpers
    UPDATED_KEY = "LAST_UPDATED_ON"

    def mark_as_updated
      Related.redis.set UPDATED_KEY, Time.now.utc
    end

    def last_updated_on
      Time.parse(Related.redis.get(UPDATED_KEY)).localtime
    end
  end
end