module SoftDestroyable
  # Simply adds a flag to determine whether a model class is soft_destroyable.
  module IsSoftDestroyable
    def self.extended(base) # :nodoc:
      base.class_eval do
        class << self
          alias_method_chain :soft_destroyable, :flag
        end
      end
    end

    # Overrides the +soft_destroyable+ method to first define the +soft_destroyable?+ class method before
    # deferring to the original +soft_destroyable+.
    def soft_destroyable_with_flag(*args)
      soft_destroyable_without_flag(*args)

      class << self
        def soft_destroyable?
          true
        end
      end
    end

    # For all ActiveRecord::Base models that do not call the +soft_destroyable+ method, the +soft_destroyable?+
    # method will return false.
    def soft_destroyable?
      false
    end
  end
end