# Wraps TFS OData domain knowledge
require 'tfs'

module TFSGraph
  module TFSClient
    InvalidConfig = Class.new(RuntimeError)

    REQUIRED_KEYS = [:endpoint, :username, :password]

    # Requires a has
    def setup(settings)
      raise InvalidConfig unless REQUIRED_KEYS.all? {|key| settings.keys.include? key }

      TFS.configure do |c|
        c.endpoint = settings[:endpoint]
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
  end
end