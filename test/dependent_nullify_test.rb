require "#{File.dirname(__FILE__)}/test_helper"

class DependentNullifyTest < Test::Unit::TestCase

  def setup
    @fred   = Parent.create!(:name => "fred")
  end

  def teardown
    Parent.delete_all
    NullifyChild.delete_all
    SoftNullifyChild.delete_all
    NullifyOne.delete_all
    SoftNullifyOne.delete_all
  end

  def test_destroy_has_many_nullify_soft_children
    @fred.soft_nullify_children << pebbles = SoftNullifyChild.new(:name => "pebbles")
    @fred.soft_nullify_children << bambam = SoftNullifyChild.new(:name => "bambam")
    assert_equal 2, @fred.reload.soft_nullify_children.count
    assert_equal @fred, pebbles.parent
    @fred.destroy
    assert_equal true, @fred.deleted?
    assert_nil pebbles.reload.parent
    assert_nil bambam.reload.parent
  end

  def test_destroy_has_many_nullify_children
    @fred.nullify_children << pebbles = NullifyChild.new(:name => "pebbles")
    @fred.nullify_children << bambam = NullifyChild.new(:name => "bambam")
    assert_equal 2, @fred.reload.nullify_children.count
    assert_equal @fred, pebbles.parent
    @fred.destroy
    assert_equal true, @fred.deleted?
    assert_nil pebbles.reload.parent
    assert_nil bambam.reload.parent
  end

  def test_destroys_has_soft_nullify_ones
    @fred.soft_nullify_one = bambam = SoftNullifyOne.new(:name => "bambam")
    assert_equal bambam, @fred.reload.soft_nullify_one
    assert_equal bambam.parent, @fred
    @fred.destroy
    assert_equal true, @fred.deleted?
    assert_nil bambam.reload.parent
    assert_nil SoftNullifyOne.where(:id => bambam.id).first.parent_id
  end

  def test_destroy_has_nullify_ones
    @fred.nullify_one = bambam = NullifyOne.new(:name => "bambam")
    assert_equal bambam , @fred.reload.nullify_one
    assert_equal bambam.parent, @fred
    @fred.destroy
    assert_equal true, @fred.deleted?
    assert_nil NullifyOne.where(:id => bambam.id).first.parent_id
  end

  def test_destroy_bang_has_many_nullify_soft_children
    @fred.soft_nullify_children << pebbles = SoftNullifyChild.new(:name => "pebbles")
    @fred.soft_nullify_children << bambam = SoftNullifyChild.new(:name => "bambam")
    assert_equal 2, @fred.reload.soft_nullify_children.count
    assert_equal @fred, pebbles.parent
    @fred.destroy!
    assert_equal 1, SoftNullifyChild.where(:name => "pebbles", :parent_id => nil).count
    assert_equal 1, SoftNullifyChild.where(:name => "bambam", :parent_id => nil).count
  end

  def test_destroy_bang_has_many_nullify_children
    @fred.nullify_children << pebbles = NullifyChild.new(:name => "pebbles")
    @fred.nullify_children << bambam = NullifyChild.new(:name => "bambam")
    assert_equal 2, @fred.reload.nullify_children.count
    assert_equal @fred, pebbles.parent
    @fred.destroy!
    assert_nil pebbles.reload.parent
    assert_nil bambam.reload.parent
  end

  def test_destroy_bang_has_soft_nullify_ones
    @fred.soft_nullify_one = bambam = SoftNullifyOne.new(:name => "bambam")
    assert_equal bambam, @fred.reload.soft_nullify_one
    assert_equal bambam.parent, @fred
    @fred.destroy!
    assert_nil Parent.find_by_name("fred")
    assert_nil bambam.reload.parent
  end

  def test_destroy_bang_has_nullify_ones
    @fred.nullify_one = bambam = NullifyOne.new(:name => "bambam")
    assert_equal bambam, @fred.reload.nullify_one
    assert_equal bambam.parent, @fred
    @fred.destroy!
    assert_nil Parent.find_by_name("fred")
    assert_nil bambam.reload.parent
  end

  # revive

  def test_revive_does_not_nullify_has_many_nullify_soft_children
    @fred.destroy
    @fred.soft_nullify_children << pebbles = SoftNullifyChild.new(:name => "pebbles")
    assert_equal @fred, pebbles.reload.parent
    @fred.revive
    assert_equal @fred, pebbles.reload.parent
  end

  def test_revive_does_not_nullify_has_many_nullify_children
    @fred.destroy
    @fred.nullify_children << pebbles = NullifyChild.new(:name => "pebbles")
    assert_equal @fred, pebbles.reload.parent
    @fred.revive
    assert_equal @fred, pebbles.reload.parent
  end

  def test_revive_does_not_nullify_has_soft_nullify_ones
    @fred.destroy
    @fred.soft_nullify_one = bambam = SoftNullifyOne.new(:name => "bambam")
    assert_equal bambam, @fred.reload.soft_nullify_one
    @fred.revive
    assert_equal bambam, @fred.reload.soft_nullify_one
  end

  def test_revive_does_not_nullify_has_nullify_ones
    @fred.destroy
    @fred.nullify_one = bambam = NullifyOne.new(:name => "bambam")
    assert_equal bambam, @fred.reload.nullify_one
    @fred.revive
    assert_equal bambam, @fred.reload.nullify_one
  end


end