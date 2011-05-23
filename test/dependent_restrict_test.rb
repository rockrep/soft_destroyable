require "#{File.dirname(__FILE__)}/test_helper"

class DependentRestrictTest < Test::Unit::TestCase

  def setup
    @fred   = Parent.create!(:name => "fred")
  end

  def teardown
    Parent.delete_all
    RestrictChild.delete_all
    SoftRestrictChild.delete_all
    RestrictOne.delete_all
    SoftRestrictOne.delete_all
  end

  def test_destroy_no_restrict_or_soft_restrict_children
    @fred.destroy
    assert_equal true, @fred.deleted?
  end

  def test_destroy_bang_no_restrict_or_soft_restrict_children
    @fred.destroy!
    assert_nil Parent.find_by_id(@fred.id)
  end

  def test_destroy_has_many_restrict_soft_children
    @fred.soft_restrict_children << pebbles = SoftRestrictChild.new(:name => "pebbles")
    @fred.soft_restrict_children << bambam = SoftRestrictChild.new(:name => "bambam")
    assert_equal 2, @fred.reload.soft_restrict_children.count
    assert_raise ActiveRecord::DeleteRestrictionError do
      @fred.destroy
    end
    assert_equal false, @fred.deleted?
    assert_equal false, pebbles.reload.deleted?
    assert_equal false, bambam.reload.deleted?
  end

  def test_destroy_has_many_restrict_soft_children_which_are_deleted
    @fred.soft_restrict_children << pebbles = SoftRestrictChild.new(:name => "pebbles")
    @fred.soft_restrict_children << bambam = SoftRestrictChild.new(:name => "bambam")
    assert_equal 2, @fred.reload.soft_restrict_children.count
    pebbles.destroy
    bambam.destroy
    assert_equal 0, @fred.soft_restrict_children.not_deleted.count
    @fred.destroy
    assert_equal true, @fred.deleted?
  end

  def test_destroy_has_many_restrict_children
    @fred.restrict_children << pebbles = RestrictChild.new(:name => "pebbles")
    @fred.restrict_children << bambam = RestrictChild.new(:name => "bambam")
    assert_equal 2, @fred.reload.restrict_children.count
    assert_raise ActiveRecord::DeleteRestrictionError do
      @fred.destroy
    end
    assert_equal false, @fred.deleted?
    assert_not_nil RestrictChild.find_by_name("pebbles")
    assert_not_nil RestrictChild.find_by_name("bambam")
  end

  def test_destroy_bang_has_many_restrict_soft_children
    @fred.soft_restrict_children << pebbles = SoftRestrictChild.new(:name => "pebbles")
    @fred.soft_restrict_children << bambam = SoftRestrictChild.new(:name => "bambam")
    assert_equal 2, @fred.reload.soft_restrict_children.count
    assert_raise ActiveRecord::DeleteRestrictionError do
      @fred.destroy!
    end
    assert_equal false, @fred.deleted?
    assert_equal false, pebbles.reload.deleted?
    assert_equal false, bambam.reload.deleted?
  end

  def test_destroy_bang_has_many_restrict_soft_children_which_are_deleted
    @fred.soft_restrict_children << pebbles = SoftRestrictChild.new(:name => "pebbles")
    @fred.soft_restrict_children << bambam = SoftRestrictChild.new(:name => "bambam")
    assert_equal 2, @fred.reload.soft_restrict_children.count
    pebbles.destroy
    bambam.destroy
    assert_equal 0, @fred.soft_restrict_children.not_deleted.count
    @fred.destroy!
    assert_nil Parent.find_by_id(@fred.id)
  end

  def test_destroy_bang_has_many_restrict_children
    @fred.restrict_children << pebbles = RestrictChild.new(:name => "pebbles")
    @fred.restrict_children << bambam = RestrictChild.new(:name => "bambam")
    assert_equal 2, @fred.reload.restrict_children.count
    assert_raise ActiveRecord::DeleteRestrictionError do
      @fred.destroy!
    end
    assert_equal false, @fred.deleted?
    assert_not_nil RestrictChild.find_by_name("pebbles")
    assert_not_nil RestrictChild.find_by_name("bambam")
  end

  def test_destroy_has_soft_restrict_ones
    @fred.soft_restrict_one = SoftRestrictOne.new(:name => "bambam")
    assert_equal @fred.reload.soft_restrict_one, SoftRestrictOne.where(:name => "bambam", :parent_id => @fred.id).first
    assert_raise ActiveRecord::DeleteRestrictionError do
      @fred.destroy
    end
    assert_equal false, @fred.deleted?
    assert_not_nil SoftRestrictOne.find_by_name("bambam")
  end

  def test_destroy_has_soft_restrict_ones_which_is_deleted
    @fred.soft_restrict_one = bambam = SoftRestrictOne.new(:name => "bambam")
    assert_equal @fred.reload.soft_restrict_one, SoftRestrictOne.where(:name => "bambam", :parent_id => @fred.id).first
    bambam.destroy
    assert_equal true, @fred.reload.soft_restrict_one.deleted?
    @fred.destroy
    assert_equal true, @fred.deleted?
    assert_not_nil SoftRestrictOne.find_by_name("bambam")
  end

  def test_destroy_has_restrict_ones
    @fred.restrict_one = RestrictOne.new(:name => "bambam")
    assert_equal @fred.reload.restrict_one, RestrictOne.where(:name => "bambam", :parent_id => @fred.id).first
    assert_raise ActiveRecord::DeleteRestrictionError do
      @fred.destroy
    end
    assert_equal false, @fred.deleted?
    assert_not_nil RestrictOne.find_by_name("bambam")
  end

  def test_destroy_bang_has_soft_restrict_ones
    @fred.soft_restrict_one = SoftRestrictOne.new(:name => "bambam")
    assert_equal @fred.reload.soft_restrict_one, SoftRestrictOne.where(:name => "bambam", :parent_id => @fred.id).first
    assert_raise ActiveRecord::DeleteRestrictionError do
      @fred.destroy!
    end
    assert_equal false, @fred.deleted?
    assert_not_nil SoftRestrictOne.find_by_name("bambam")
  end

  def test_destroy_bang_has_soft_restrict_ones_which_is_deleted
    @fred.soft_restrict_one = bambam = SoftRestrictOne.new(:name => "bambam")
    assert_equal @fred.reload.soft_restrict_one, SoftRestrictOne.where(:name => "bambam", :parent_id => @fred.id).first
    bambam.destroy
    assert_equal true, @fred.reload.soft_restrict_one.deleted?
    @fred.destroy!
    assert_nil Parent.find_by_id(@fred.id)
  end  

  def test_destroy_bang_has_restrict_ones
    @fred.restrict_one = RestrictOne.new(:name => "bambam")
    assert_equal @fred.reload.restrict_one, RestrictOne.where(:name => "bambam", :parent_id => @fred.id).first
    assert_raise ActiveRecord::DeleteRestrictionError do
      @fred.destroy!
    end
    assert_equal false, @fred.deleted?
    assert_not_nil RestrictOne.find_by_name("bambam")
  end
  
  # revive
  
  def test_revive_has_many_restrict_children_not_empty
    #pending
    #assert_can_revive do
    #  @fred.restrict_children << pebbles = RestrictChild.new(:name => "pebbles")
    #  assert_equal pebbles, @fred.restrict_children.first
    #end
  end
  
  def test_revive_has_many_restrict_soft_children_not_all_deleted
    #pending
    #assert_can_revive do
    #  @fred.soft_restrict_children << pebbles = SoftRestrictChild.new(:name => "pebbles")
    #  assert_equal pebbles, @fred.soft_restrict_children.first
    #end
  end
  
  def test_revive_has_restrict_ones_not_nil
    #pending
    #assert_can_revive do
    #  @fred.restrict_one = bambam = RestrictOne.new(:name => "bambam")
    #  assert_equal bambam, @fred.restrict_one
    #end
  end
  
  def test_revive_has_soft_restrict_ones_not_deleted
    #pending
    #assert_can_revive do
    #  @fred.soft_restrict_one = bambam = SoftRestrictOne.new(:name => "bambam")
    #  assert_equal bambam, @fred.soft_restrict_one
    #end
  end
  
  private
  
  def assert_can_revive
    assert_equal true, @fred.destroy
    yield if block_given?
    # assert_not_raise ActiveRecord::DeleteRestrictionError do
      @fred.revive
    # end
    assert_equal false, @fred.deleted?
  end
  
  def assert_true value
    assert_equal true, value
  end
  
end