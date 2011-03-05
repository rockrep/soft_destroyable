require "#{File.dirname(__FILE__)}/test_helper"

class BasicTest < Test::Unit::TestCase

  def setup
    @fred   = Parent.create!(:name => "fred")
  end

  def teardown
    Parent.delete_all
  end

  def test_destroy
    @fred.destroy
    fred = Parent.where(:name => "fred").first
    assert_not_nil fred
    assert_equal fred.deleted, true
    assert_not_nil fred.deleted_at
  end

  def test_revive
    @fred.destroy
    assert Parent.deleted.include?(@fred)
    @fred.revive
    assert !Parent.deleted.include?(@fred)
  end

  def test_destroy!
    @fred.destroy!
    assert_nil Parent.where(:name => "fred").first
  end

end