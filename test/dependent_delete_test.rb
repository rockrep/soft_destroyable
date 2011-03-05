require "#{File.dirname(__FILE__)}/test_helper"

class DependentDeleteTest < Test::Unit::TestCase

  def setup
    @fred   = Parent.create!(:name => "fred")
  end

  def teardown
    Parent.delete_all
    DeleteOne.delete_all
    SoftDeleteOne.delete_all
  end

  def test_destroy_has_one_soft_delete_one
    @fred.soft_delete_one = pebbles = SoftDeleteOne.new(:name => "pebbles")
    assert_equal pebbles, @fred.reload.soft_delete_one
    assert_equal @fred, pebbles.parent
    @fred.destroy
    assert_equal true, @fred.deleted?
    assert_equal 0, SoftDeleteOne.where(:name => "pebbles", :parent_id => @fred.id).count
  end

  def test_destroy_has_one_delete_children
    @fred.delete_one = pebbles = DeleteOne.new(:name => "pebbles")
    assert_equal pebbles, @fred.reload.delete_one
    @fred.destroy
    assert_equal true, @fred.deleted?
    assert_equal 0, DeleteOne.where(:name => "pebbles", :parent_id => @fred.id).count
  end

  def test_destroy_bang_has_one_soft_delete_one
    @fred.soft_delete_one = pebbles = SoftDeleteOne.new(:name => "pebbles")
    assert_equal pebbles, @fred.reload.soft_delete_one
    assert_equal @fred, pebbles.parent
    @fred.destroy!
    assert_nil Parent.find_by_id(@fred.id)
    assert_equal 0, SoftDeleteOne.where(:name => "pebbles", :parent_id => @fred.id).count
  end

  def test_destroy_bang_has_one_delete_one
    @fred.delete_one = pebbles = DeleteOne.new(:name => "pebbles")
    assert_equal pebbles, @fred.reload.delete_one
    @fred.destroy!
    assert_nil Parent.find_by_id(@fred.id)
    assert_equal 0, DeleteOne.where(:name => "pebbles", :parent_id => @fred.id).count
  end

end