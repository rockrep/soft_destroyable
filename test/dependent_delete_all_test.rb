require "#{File.dirname(__FILE__)}/test_helper"

class DependentDeleteAllTest < Test::Unit::TestCase

  def setup
    @fred   = Parent.create!(:name => "fred")
  end

  def teardown
    Parent.delete_all
    DeleteAllChild.delete_all
    SoftDeleteAllChild.delete_all
  end

  def test_destroy_has_many_delete_all_soft_children
    @fred.soft_delete_all_children << pebbles = SoftDeleteAllChild.new(:name => "pebbles")
    @fred.soft_delete_all_children << bambam = SoftDeleteAllChild.new(:name => "bambam")
    assert_equal 2, @fred.reload.soft_delete_all_children.count
    @fred.destroy
    assert_equal true, @fred.deleted?
    assert_equal 0, SoftDeleteAllChild.where(:name => "pebbles", :parent_id => @fred.id).count
    assert_equal 0, SoftDeleteAllChild.where(:name => "bambam", :parent_id => @fred.id).count
  end

  def test_destroy_has_many_delete_all_children
    @fred.delete_all_children << pebbles = DeleteAllChild.new(:name => "pebbles")
    @fred.delete_all_children << bambam = DeleteAllChild.new(:name => "bambam")
    assert_equal 2, @fred.reload.delete_all_children.count
    @fred.destroy
    assert_equal true, @fred.deleted?
    assert_equal 0, SoftDeleteAllChild.where(:name => "pebbles", :parent_id => @fred.id).count
    assert_equal 0, SoftDeleteAllChild.where(:name => "bambam", :parent_id => @fred.id).count
  end

  def test_destroy_bang_has_many_delete_all_soft_children
    @fred.soft_delete_all_children << pebbles = SoftDeleteAllChild.new(:name => "pebbles")
    @fred.soft_delete_all_children << bambam = SoftDeleteAllChild.new(:name => "bambam")
    assert_equal 2, @fred.reload.soft_delete_all_children.count
    @fred.destroy!
    assert_nil Parent.find_by_id(@fred.id)
    assert_equal 0, SoftDeleteAllChild.where(:name => "pebbles", :parent_id => @fred.id).count
    assert_equal 0, SoftDeleteAllChild.where(:name => "bambam", :parent_id => @fred.id).count
  end

  def test_destroy_bang_has_many_delete_all_children
    @fred.delete_all_children << pebbles = DeleteAllChild.new(:name => "pebbles")
    @fred.delete_all_children << bambam = DeleteAllChild.new(:name => "bambam")
    assert_equal 2, @fred.reload.delete_all_children.count
    @fred.destroy!
    assert_nil Parent.find_by_id(@fred.id)
    assert_equal 0, SoftDeleteAllChild.where(:name => "pebbles", :parent_id => @fred.id).count
    assert_equal 0, SoftDeleteAllChild.where(:name => "bambam", :parent_id => @fred.id).count
  end

  # revive

  def test_revive_does_not_delete_all_has_many_delete_all_soft_children
    @fred.destroy
    assert_equal true, @fred.deleted?
    @fred.soft_delete_all_children << dino = SoftDeleteAllChild.new(:name => "dino")
    assert_equal 1, @fred.reload.soft_delete_all_children.count
    @fred.revive
    assert_equal false, @fred.deleted?
    assert_equal 1, SoftDeleteAllChild.where(:name => "dino", :parent_id => @fred.id).count
  end

  def test_revive_does_not_delete_all_has_many_delete_all_children
    @fred.destroy
    assert_equal true, @fred.deleted?
    @fred.delete_all_children << dino = DeleteAllChild.new(:name => "dino")
    assert_equal 1, @fred.reload.delete_all_children.count
    @fred.revive
    assert_equal false, @fred.deleted?
    assert_equal 1, DeleteAllChild.where(:name => "dino", :parent_id => @fred.id).count
  end

end