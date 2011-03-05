require "#{File.dirname(__FILE__)}/test_helper"

class NonDependentTest < Test::Unit::TestCase

  def setup
    @fred   = Parent.create!(:name => "fred")
  end

  def teardown
    NonDependentChild.delete_all
    Parent.delete_all
  end

  def test_destroy_does_not_destroy_non_dependent_children
    @fred.non_dependent_children << pebbles = NonDependentChild.new(:name => "pebbles")
    assert_equal 1, @fred.reload.non_dependent_children.count
    @fred.destroy
    assert_equal @fred.deleted?, true
    assert_not_nil pebbles.reload
  end

  def test_destroy_bang_does_not_destroy_non_dependent_children
    @fred.non_dependent_children << pebbles = NonDependentChild.new(:name => "pebbles")
    assert_equal 1, @fred.reload.non_dependent_children.count
    @fred.destroy!
    assert_nil Parent.where(:name => "fred").first
    assert_not_nil pebbles.reload
  end

end
