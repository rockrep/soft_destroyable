# Utility module for Specing Database constraints
#
# Would like to rewrite these at some point to be more RSpec 'matcherish' so they would read more BDD-like.
#
#  Author: Michael Kintzer
#  August 31, 2010

module SoftDestroySpecHelper

  # Ensures that the model class is annotated as +soft_destroyable+
  # and that the model behaves appropriately to destroy and revive
  def asserts_soft_destroy?(model_klass, new_record_args={})
    model_klass = model_klass.constantize if model_klass.is_a?(String)

    model_klass.respond_to?(:not_deleted).should be_true

    current_count         = model_klass.count
    current_deleted_count = model_klass.deleted.count

    # create a new record
    obj                   = model_klass.create!(new_record_args)

    # verify the database migration
    asserts_soft_destroy_migration?(obj)

    model_klass.count.should == 1 + current_count

    # verify soft destroy behaves correctly, and the record still exists and is correctly marked
    obj.destroy.should be_true
    obj.reload
    obj.deleted_at.should_not be_nil
    obj.deleted?.should be_true

    # verify counts are correct
    model_klass.count.should == 1 + current_count
    model_klass.not_deleted.count.should == 0 + current_count
    model_klass.deleted.count.should == 1 + current_deleted_count

    # verify revive behaves correctly
    obj.revive
    obj.reload
    obj.deleted_at.should be_nil
    obj.deleted?.should be_false

    # verify counts are correct
    model_klass.count.should == 1 + current_count
    model_klass.not_deleted.count.should == 1 + current_count
    model_klass.deleted.count.should == 0 + current_deleted_count
  end

  # Ensures that the model class soft destroys the associated dependent association on +destroy+
  # This helper only valid if :dependent => :destroy
  def asserts_soft_destroy_associations?(model_obj, association_symbol, new_association_record)
    # save model_obj in case it hasn't been yet
    model_obj.save
    association_reflection           = model_obj.class.reflect_on_association(association_symbol.to_sym)
    association_reflection.options[:dependent].should == :destroy
    assign_association(model_obj, association_reflection, new_association_record)

    unless new_association_record.respond_to?(:revive)
      # if associated_klass is NOT soft_destroyable, then calling destroy on parent is a NO-OP so associated_klass should
      # NOT receive a destroy call
      new_association_record.expects(:destroy).never
    end

    model_obj.destroy

    if new_association_record.respond_to?(:revive)
      # if associated_klass IS soft_destroyable, then the new_association_record should be deleted
      new_association_record.deleted?.should be_true
    end
  end

  # Ensures that the model class hard destroys the associated dependent association on +destroy!+
  # This helper only valid if :dependent => :destroy
  def asserts_hard_destroy_associations?(model_obj, association_symbol, new_association_record)
    # save model obj in case it hasn't been yet
    model_obj.save
    association_reflection = model_obj.class.reflect_on_association(association_symbol.to_sym)
    association_reflection.options[:dependent].should == :destroy
    assign_association(model_obj, association_reflection, new_association_record)
    association_reflection.klass.where(association_reflection.primary_key_name => model_obj.id).count.should > 0
    model_obj.destroy!
    association_reflection.klass.where(association_reflection.primary_key_name => model_obj.id).count.should == 0
  end

  private

  # verifies the table contains the expected soft destroy fields,
  # and they have the appropriate defaults
  def asserts_soft_destroy_migration?(obj)
    obj.respond_to?(:deleted_at).should be_true
    obj.respond_to?(:deleted).should be_true
    obj.deleted_at.should be_nil
    obj.deleted?.should be_false
  end

  # Assigns the new_association_record to the model_obj
  def assign_association(model_obj, association_reflection, new_association_record)
    case association_reflection.macro
      when :has_many
        model_obj.send(association_reflection.name) << new_association_record
      when :has_one
        model_obj.send("#{association_reflection.name}=", new_association_record)
      else
        raise NotImplementedError.new("Association #{association_reflection.macro} not handled")
    end
    new_association_record.id.should_not be_nil
  end

end