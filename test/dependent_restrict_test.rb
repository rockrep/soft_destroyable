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

  def test_destroys_has_soft_restrict_ones
    @fred.soft_restrict_one = SoftRestrictOne.new(:name => "bambam")
    assert_equal @fred.reload.soft_restrict_one, SoftRestrictOne.where(:name => "bambam", :parent_id => @fred.id).first
    assert_raise ActiveRecord::DeleteRestrictionError do
      @fred.destroy
    end
    assert_equal false, @fred.deleted?
    assert_not_nil SoftRestrictOne.find_by_name("bambam")
  end

  def test_destroys_has_restrict_ones
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

  def test_destroy_bang_has_restrict_ones
    @fred.restrict_one = RestrictOne.new(:name => "bambam")
    assert_equal @fred.reload.restrict_one, RestrictOne.where(:name => "bambam", :parent_id => @fred.id).first
    assert_raise ActiveRecord::DeleteRestrictionError do
      @fred.destroy!
    end
    assert_equal false, @fred.deleted?
    assert_not_nil RestrictOne.find_by_name("bambam")
  end

end