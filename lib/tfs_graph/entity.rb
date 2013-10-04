module TFSGraph
	class Entity < Related::Node
		RECLASS = -> (attrs) { self.class }

		def self.inherited(klass)
			define_singleton_method :act_as_entity do
				klass::SCHEMA.each do |key, details|
					property key, details[:type]
				end
			end
		end

		def to_hash
			hash = {}
			schema.keys.each {|key| hash[key] = send key }
			hash
		end

		def to_json
			to_hash.to_json
		end

		private
		def schema
			self.class::SCHEMA
		end
	end
end