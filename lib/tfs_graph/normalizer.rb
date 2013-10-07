module TFSGraph
  class Normalizer
    class << self
      def normalize_many(data)
        data.map {|item| normalize item }
      end

      def normalize(item)
        representation = {}
        schema.each do |key, lookup|

          if lookup[:key].present?  # for keys that pull data from other sources
            value = item.send lookup[:key]
            value = lookup[:converter].call(value) if lookup[:converter].present?
          else
            value = lookup[:default]
          end

          representation[key] = value
        end
        representation
      end

      private
      def schema
        raise NoMethodError, "please define the schema in the Normalizer subclass"
      end
    end
  end
end