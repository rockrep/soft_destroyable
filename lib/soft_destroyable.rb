require "#{File.dirname(__FILE__)}/soft_destroyable/table_definition"
require "#{File.dirname(__FILE__)}/soft_destroyable/is_soft_destroyable"

# Allows one to annotate an ActiveRecord module as being soft_destroyable.
#
# This changes the behavior of the +destroy+ method to being a soft-destroy, which
# will set the +deleted_at+ attribute to <tt>Time.now</tt>, and the +deleted+ attribute to <tt>true</tt>
# It exposes the +revive+ method to reverse the effects of +destroy+.
# It also exposes the +destroy!+ method which can be used to <b>really</b> destroy an object and it's associations.
#
# Standard ActiveRecord destroy callbacks are _not_ called, however you can override +before_soft_destroy+, +after_soft_destroy+,
# and +before_destroy!+ on your soft_destroyable models.
#
# Standard ActiveRecord dependent options :destroy, :restrict, :nullify, :delete_all, and :delete are supported.
# +revive+ will _not_ undo the effects of +nullify+, +delete_all+, and +delete+.   +restrict+ is _not_ effected by the
# +deleted?+ state.  In other words, deleted child models will still restrict destroying the parent.
#
# The +delete+ operation is _not_ modified by this module.
#
# The operations: +destroy+, +destroy!+, and +revive+ are automatically delegated to the dependent association records.
# in a single transaction.
#
# Examples:
#   class Parent
#     has_many :children, :dependent => :restrict
#     has_many :animals, :dependent => :nullify
#     soft_destroyable
#
#
# Author: Michael Kintzer
#

module SoftDestroyable

  def self.included(base)
    base.class_eval do
      extend ClassMethods
      extend IsSoftDestroyable
    end
  end

  module ClassMethods

    def soft_destroyable(options = {})
      return if soft_destroyable?

      scope :not_deleted, where(:deleted => false)
      scope :deleted, where(:deleted => true)

      include InstanceMethods
      extend SingletonMethods
    end
  end

  module SingletonMethods

    # returns an array of association symbols that must be managed by soft_destroyable on
    # destroy and destroy!
    def soft_dependencies
      has_many_dependencies + has_one_dependencies
    end

    def restrict_dependencies
      with_restrict_option(:has_many).map(&:name) + with_restrict_option(:has_one).map(&:name)
    end

    private

    def non_through_dependent_associations(type)
      reflect_on_all_associations(type).reject { |k, v|
        k.class == ActiveRecord::Reflection::ThroughReflection }.reject { |k, v| k.options[:dependent].nil? }
    end

    def has_many_dependencies
      non_through_dependent_associations(:has_many).map(&:name)
    end

    def has_one_dependencies
      non_through_dependent_associations(:has_one).map(&:name)
    end

    def with_restrict_option(type)
      non_through_dependent_associations(type).reject { |k, v| k.options[:dependent] != :restrict }
    end

  end

  module InstanceMethods

    # overrides the normal ActiveRecord::Transactions#destroy.
    # can be recovered with +revive+
    def destroy
      before_soft_destroy
      result = soft_destroy
      after_soft_destroy
      result
    end

    # not a recoverable operation
    def destroy!
      transaction do
        before_destroy!
        cascade_destroy!
        delete
      end
    end

    # un-does the effect of +destroy+.  Does not undo nullify on dependents
    def revive
      transaction do
        cascade_revive
        update_attributes(:deleted_at => nil, :deleted => false)
      end
    end

    def soft_dependencies
      self.class.soft_dependencies
    end

    def restrict_dependencies
      self.class.restrict_dependencies
    end

    # override
    def before_soft_destroy
      # empty
    end

    # override
    def after_soft_destroy
      # empty
    end

    # override
    def before_destroy!
      # empty
    end

    private

    def non_restrict_dependencies
      soft_dependencies.reject { |assoc_sym| restrict_dependencies.include?(assoc_sym) }
    end

    def soft_destroy
      transaction do
        cascade_soft_destroy
        update_attributes(:deleted_at => Time.now, :deleted => true)
      end
    end

    def cascade_soft_destroy
      cascade_to_soft_dependents { |assoc_obj|
        if assoc_obj.respond_to?(:destroy) && assoc_obj.respond_to?(:revive)
          wrap_with_callbacks(assoc_obj, "soft_destroy") do
            assoc_obj.destroy
          end
        else
          wrap_with_callbacks(assoc_obj, "soft_destroy") do
            # no-op
          end
        end
      }
    end

    def cascade_destroy!
      cascade_to_soft_dependents { |assoc_obj|
      # cascade destroy! to soft dependencies objects
        if assoc_obj.respond_to?(:destroy!)
          wrap_with_callbacks(assoc_obj, "destroy!") do
            assoc_obj.destroy!
          end
        else
          wrap_with_callbacks(assoc_obj, "destroy!") do
            assoc_obj.destroy
          end
        end
      }
    end

    def cascade_revive
      cascade_to_soft_dependents { |assoc_obj|
        assoc_obj.revive if assoc_obj.respond_to?(:revive)
      }
    end

    def cascade_to_soft_dependents(&block)
      return unless block_given?

      # fail fast on :dependent => :restrict
      restrict_dependencies.each { |assoc_sym| handle_restrict(assoc_sym) }

      non_restrict_dependencies.each do |assoc_sym|
        reflection  = reflection_for(assoc_sym)
        association = send(reflection.name)

        case reflection.options[:dependent]
          when :destroy
            handle_destroy(reflection, association, &block)
          when :nullify
            handle_nullify(reflection, association)
          when :delete_all
            handle_delete_all(reflection, association)
          when :delete
            handle_delete(reflection, association)
          else
        end

      end
      # reload as dependent associations may have updated
      reload if self.id
    end

    def handle_destroy(reflection, association, &block)
      case reflection.macro
        when :has_many
          association.each { |assoc_obj| yield(assoc_obj) }
        when :has_one
          # handle non-nil has_one
          yield(association) if association
        else
      end
    end

    def handle_restrict(assoc_sym)
      reflection  = reflection_for(assoc_sym)
      association = send(reflection.name)
      case reflection.macro
        when :has_many
          restrict_on_non_empty_has_many(reflection, association)
        when :has_one
          restrict_on_non_nil_has_one(reflection, association)
        else
      end
    end

    def handle_nullify(reflection, association)
      return unless association
      case reflection.macro
        when :has_many
          self.class.send(:nullify_has_many_dependencies,
                          self,
                          reflection.name,
                          reflection.klass,
                          reflection.primary_key_name,
                          reflection.dependent_conditions(self, self.class, nil))
        when :has_one
          association.update_attributes(reflection.primary_key_name => nil)
        else
      end

    end

    def handle_delete_all(reflection, association)
      return unless association
      self.class.send(:delete_all_has_many_dependencies,
                      self,
                      reflection.name,
                      reflection.klass,
                      reflection.dependent_conditions(self, self.class, nil))
    end

    def handle_delete(reflection, association)
      return unless association
      association.update_attribute(reflection.primary_key_name, nil)
    end

    def wrap_with_callbacks(assoc_obj, action)
      return unless block_given?
      assoc_obj.send("before_#{action}".to_sym) if assoc_obj.respond_to?("before_#{action}".to_sym)
      yield
      assoc_obj.send("after_#{action}".to_sym) if assoc_obj.respond_to?("after_#{action}".to_sym)
    end

    def reflection_for(assoc_sym)
      self.class.reflect_on_association(assoc_sym)
    end

    def restrict_on_non_empty_has_many(reflection, association)
      return unless association
      association.each {|assoc_obj|
        if assoc_obj.respond_to?(:deleted?)
          raise ActiveRecord::DeleteRestrictionError.new(reflection) if !assoc_obj.deleted?
        else
          raise ActiveRecord::DeleteRestrictionError.new(reflection)
        end
      }
    end

    def restrict_on_non_nil_has_one(reflection, association)
      if association.respond_to?(:deleted?)
        raise ActiveRecord::DeleteRestrictionError.new(reflection) if !association.nil? && !association.deleted?
      else
        raise ActiveRecord::DeleteRestrictionError.new(reflection) if !association.nil?
      end
    end

  end

  ActiveRecord::Base.send :include, SoftDestroyable
  [ActiveRecord::ConnectionAdapters::TableDefinition, ActiveRecord::ConnectionAdapters::Table].each { |base|
    base.send(:include, SoftDestroyable::TableDefinition)
  }

  class SoftDestroyError < StandardError

  end

end
