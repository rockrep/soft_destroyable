require "#{File.dirname(__FILE__)}/test_helper"

class ThroughAssociationsTest < Test::Unit::TestCase

  def setup
    @fred   = Parent.create!(:name => "fred")
  end

  def teardown
    Parent.delete_all
    Sport.delete_all
    SoftSport.delete_all
    SoftParentSport.delete_all
    ParentSport.delete_all
    Nickname.delete_all
    SoftNickname.delete_all
    ParentNickname.delete_all
    SoftParentNickname.delete_all
  end

  def test_destroy_does_not_destroy_has_many_through_associations
    baseball = Sport.create!(:name => "baseball")
    basketball = SoftSport.create!(:name => "basketball")
    @fred.sports << baseball
    @fred.soft_sports << basketball
    @fred.reload
    assert_equal 1, @fred.sports.count
    assert_equal 1, @fred.parent_sports.count
    assert_equal 1, @fred.soft_sports.count
    assert_equal 1, @fred.soft_parent_sports.count
    @fred.destroy
    assert_equal true, @fred.reload.deleted?
    assert_equal 1, @fred.sports.count
    assert_equal 1, @fred.soft_sports.count
  end

  def test_destroy_bang_does_not_destroy_has_many_through_associations
    baseball = Sport.create!(:name => "baseball")
    basketball = SoftSport.create!(:name => "basketball")
    @fred.sports << baseball
    @fred.soft_sports << basketball
    @fred.reload
    assert_equal 1, @fred.sports.count
    assert_equal 1, @fred.parent_sports.count
    assert_equal 1, @fred.soft_sports.count
    assert_equal 1, @fred.soft_parent_sports.count
    @fred.destroy!
    assert_nil Parent.where(:name => "fred").first
    assert_equal 1, Sport.count
    assert_equal 1, SoftSport.count
  end

  def test_destroy_does_not_destroy_has_one_through_associations
    rocky = Nickname.create!(:name => "rocky")
    scar = SoftNickname.create!(:name => "scar")
    @fred.nickname = rocky
    @fred.soft_nickname = scar
    @fred.reload
    assert_equal rocky, @fred.nickname
    assert_equal scar, @fred.soft_nickname
    assert_equal rocky, @fred.parent_nickname.nickname
    assert_equal scar, @fred.soft_parent_nickname.soft_nickname
    @fred.destroy
    assert_equal true, @fred.reload.deleted?
    assert_equal rocky, @fred.nickname
    assert_equal scar, @fred.soft_nickname
  end

  def test_destroy_bang_does_not_destroy_has_one_through_associations
    rocky = Nickname.create!(:name => "rocky")
    scar = SoftNickname.create!(:name => "scar")
    @fred.nickname = rocky
    @fred.soft_nickname = scar
    @fred.reload
    assert_equal rocky, @fred.nickname
    assert_equal scar, @fred.soft_nickname
    assert_equal rocky, @fred.parent_nickname.nickname
    assert_equal scar, @fred.soft_parent_nickname.soft_nickname
    @fred.destroy!
    assert_nil Parent.where(:name => "fred").first
    assert_equal 1, Nickname.count
    assert_equal 1, SoftNickname.count
  end

end