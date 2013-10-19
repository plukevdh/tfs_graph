module TFSGraph
	class Entity < Related::Node
		def self.inherited(klass)
			define_singleton_method :act_as_entity do
				klass::SCHEMA.each do |key, details|
					property key, details[:type]
				end
			end
		end

		private
		def schema
			self.class::SCHEMA
		end
	end
end