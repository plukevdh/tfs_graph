# Wraps TFS OData domain knowledge
require 'tfs'

module TFSGraph
  module TFSClient
    InvalidConfig = Class.new(RuntimeError)

    REQUIRED_KEYS = [:endpoint, :collection, :username, :password]

    # Requires a hash of settings
    def setup(settings=TFSGraph.config.tfs)
      raise InvalidConfig unless REQUIRED_KEYS.all? {|key| settings.keys.include? key }

      TFS.configure do |c|
        c.endpoint = endpoint(settings)
        c.username = settings[:username]
        c.password = settings[:password]
        c.namespace = settings[:namespace] || "TFS"
      end
    end

    def tfs
      @tfs ||= begin
        setup
        TFS.client
      end
    end

    def tfs=(client)
      @tfs = client
    end

    def endpoint(settings)
      "#{settings[:endpoint]}/#{settings[:collection]}"
    end
  end
end