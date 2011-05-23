require "#{File.dirname(__FILE__)}/test_helper"

class DependentDestroyTest < Test::Unit::TestCase

  def setup
    @fred   = Parent.create!(:name => "fred")
  end

  def teardown
    Parent.delete_all
    Child.delete_all
    SoftChild.delete_all
    One.delete_all
    SoftOne.delete_all
  end

  def test_destroys_has_many_soft_children
    @fred.soft_children << pebbles = SoftChild.new(:name => "pebbles")
    @fred.soft_children << bambam = SoftChild.new(:name => "bambam")
    assert_equal @fred.reload.soft_children.count, 2
    @fred.destroy
    assert_equal @fred.deleted?, true
    assert_equal pebbles.reload.deleted?, true
    assert_equal bambam.reload.deleted?, true
  end

  def test_destroys_has_many_children
    @fred.children << Child.new(:name => "pebbles")
    @fred.children << Child.new(:name => "bambam")
    assert_equal @fred.reload.children.count, 2
    @fred.destroy
    assert_equal @fred.deleted?, true
    pebbles = Child.where(:name => "pebbles").first
    bambam  = Child.where(:name => "bambam").first
    assert_not_nil pebbles
    assert_not_nil bambam
    assert_equal pebbles.parent, @fred
    assert_equal bambam.parent, @fred
  end

  def test_destroy_bang_has_many_soft_children
    @fred.soft_children << SoftChild.new(:name => "pebbles")
    @fred.soft_children << SoftChild.new(:name => "bambam")
    assert_equal @fred.reload.soft_children.count, 2
    @fred.destroy!
    assert_nil Parent.find_by_name("fred")
    assert_nil SoftChild.find_by_name("pebbles")
    assert_nil SoftChild.find_by_name("bambam")
  end

  def test_destroy_bang_has_many_children
    @fred.children << Child.new(:name => "pebbles")
    @fred.children << Child.new(:name => "bambam")
    assert_equal @fred.reload.children.count, 2
    @fred.destroy!
    assert_nil Parent.find_by_name("fred")
    assert_nil Child.find_by_name("pebbles")
    assert_nil Child.find_by_name("bambam")
  end

  def test_destroys_has_soft_ones
    @fred.soft_one = SoftOne.new(:name => "bambam")
    assert_equal @fred.reload.soft_one, SoftOne.where(:name => "bambam", :parent_id => @fred.id).first
    @fred.destroy
    assert_equal @fred.deleted?, true
    assert_equal SoftOne.where(:name => "bambam").first.deleted?, true
  end

  def test_destroys_has_ones
    @fred.one = One.new(:name => "bambam")
    assert_equal @fred.reload.one, One.where(:name => "bambam", :parent_id => @fred.id).first
    @fred.destroy
    assert_equal @fred.deleted?, true
    the_one   = One.where(:name => "bambam").first
    assert_not_nil the_one
    assert_equal the_one.parent, @fred
  end

  def test_destroy_bang_has_soft_ones
    @fred.soft_one = SoftOne.new(:name => "bambam")
    assert_equal @fred.reload.soft_one, SoftOne.where(:name => "bambam", :parent_id => @fred.id).first
    @fred.destroy!
    assert_nil Parent.find_by_name("fred")
    assert_nil SoftOne.find_by_name("bambam")
  end

  def test_destroy_bang_has_ones
    @fred.one = One.new(:name => "bambam")
    assert_equal @fred.reload.one, One.where(:name => "bambam", :parent_id => @fred.id).first
    @fred.destroy!
    assert_nil Parent.find_by_name("fred")
    assert_nil One.find_by_name("bambam")
  end

  # revive

  def test_revive_has_many_soft_children
    @fred.soft_children << pebbles = SoftChild.new(:name => "pebbles")
    @fred.soft_children << bambam = SoftChild.new(:name => "bambam")
    assert_equal @fred.reload.soft_children.count, 2
    @fred.destroy
    assert_equal @fred.deleted?, true
    assert_equal pebbles.reload.deleted?, true
    assert_equal bambam.reload.deleted?, true
    @fred.soft_children << dino = SoftChild.new(:name => "dino")
    @fred.revive
    assert_equal @fred.deleted?, false
    assert_equal pebbles.reload.deleted?, false
    assert_equal bambam.reload.deleted?, false
    assert_equal dino.reload.deleted?, false
  end

  def test_revive_has_soft_ones
    @fred.soft_one = bambam = SoftOne.new(:name => "bambam")
    assert_equal @fred.reload.soft_one, SoftOne.where(:name => "bambam", :parent_id => @fred.id).first
    @fred.destroy
    assert_equal @fred.deleted?, true
    assert_equal SoftOne.where(:name => "bambam").first.deleted?, true
    @fred.revive
    assert_equal @fred.deleted?, false
    assert_equal SoftOne.where(:name => "bambam").first.deleted?, false
  end

end