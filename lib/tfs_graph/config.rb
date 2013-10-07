module TFSGraph
  class Config
    SETTINGS = [:tfs, :redis]

    attr_accessor *SETTINGS

  end
end