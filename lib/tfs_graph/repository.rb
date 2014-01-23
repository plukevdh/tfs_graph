module TFSGraph
  class Repository
    def initialize(type)
      @type = type
    end

    def build(args={})
      @type.new args
    end

    def create(args)
      object = build(args)
      save(object)
    end

    def save(object, id=nil)
      raise "#{self.class.name} should implement #save method that can persist a #{object.class.name}" unless id

      # persistence handled by subclass, just setting a flag here
      object.save! id
      object
    end
  end
end