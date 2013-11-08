module TFSGraph
  class Config
    attr_accessor :tfs
    attr_reader :redis

    def redis=(server)
      @redis = Related.redis = server
    end
  end
end