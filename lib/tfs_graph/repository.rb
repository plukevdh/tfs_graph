module TFSGraph
  class Repository
    def initialize(type)
      @type = type
    end

    def save(object, db_object)
      object.internal_id = db_object.id
      object
    end

    def build(args={})
      @type.new self, args
    end

    def create(args)
      object = build(args)
      save(object)
    end
  end
end