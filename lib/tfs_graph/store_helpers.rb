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
      return last_updated_from_project unless date

      Time.parse(date).localtime
    end

    def last_updated_from_project
      last_changes = ProjectStore.all_cached.map {|p| p.last_change }.flatten.compact
      last_time = last_changes.max {|a,b| a.created <=> b.created }.created

      # cache if we're looking up for the first time
      mark_as_updated last_time.dup
      last_time
    end
  end
end