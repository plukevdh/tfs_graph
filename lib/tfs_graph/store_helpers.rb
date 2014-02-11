require 'time'
require 'tfs_graph/server_registry'

module TFSGraph
  module StoreHelpers
    UPDATED_KEY = "LAST_UPDATED_ON"

    # flush by key so that we only disturbe our namespace
    def flush_all
      redis.keys("*").each do |k|
        redis.del k
      end
    end

    def mark_as_updated(time=nil)
      time ||= Time.now
      redis.set UPDATED_KEY, time.utc
    end

    def last_updated_on
      date = redis.get(UPDATED_KEY)
      return Time.now unless date

      Time.parse(date).localtime
    end

    private
    def redis
      ServerRegistry.redis
    end
  end
end