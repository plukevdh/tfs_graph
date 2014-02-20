module TFSGraph
  class Behaviors
  end
end

types = %w{project branch changeset}

types.each {|type| require_relative "behaviors/related_repository/#{type}" }
types.each {|type| require_relative "behaviors/neo4j_repository/#{type}" }