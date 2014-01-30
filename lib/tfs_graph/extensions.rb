require 'active_support/inflector'
require 'active_support/concern'

module TFSGraph
  module Extensions
    extend ActiveSupport::Concern

    module ClassMethods
      private
      def base_class_name
        name.demodulize.downcase
      end
    end

    private
    def add_behavior(repo, additions)
      repo.extend additions
    end

    def constantize(string)
      string.constantize
    end

    def base_class_name
      self.class.base_class_name
    end
  end
end