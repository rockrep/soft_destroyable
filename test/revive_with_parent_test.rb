require "#{File.dirname(__FILE__)}/test_helper"

class ReviveWithParentTest < Test::Unit::TestCase

  def setup
    @fred   = Parent.create!(:name => "fred")
  end

  def teardown
    Parent.delete_all
    SoftChild.delete_all
    SoftNoReviveWithParentAttributeChild.delete_all
  end

  # revive of previously deleted soft children

  def test_revive_previously_deleted_has_many_soft_children
    @fred.soft_children << pebbles = SoftChild.new(:name => "pebbles")
    @fred.soft_children << bambam = SoftChild.new(:name => "bambam")
    # soft destroy pebbles
    pebbles.destroy
    assert_equal @fred.reload.soft_children.count, 2
    @fred.destroy
    assert_equal @fred.deleted?, true
    assert_equal pebbles.reload.deleted?, true
    assert_equal pebbles.revive_with_parent?, false
    assert_equal bambam.reload.deleted?, true
    assert_equal bambam.revive_with_parent?, true
    @fred.revive
    assert_equal @fred.deleted?, false
    # pebbles should NOT have been revived because she was destroyed _prior_ to destroy of fred
    assert_equal pebbles.reload.deleted?, true
    assert_equal pebbles.revive_with_parent?, false
    assert_equal bambam.reload.deleted?, false
    assert_equal bambam.revive_with_parent?, true

    # revive pebbles manually
    pebbles.revive
    assert_equal pebbles.deleted?, false
    assert_equal pebbles.revive_with_parent?, true
  end

  # revive of previously deleted soft children that do NOT support the revive_with_parent attribute

  def test_revive_previously_deleted_has_many_soft_children_no_revive_with_parent
    @fred.soft_no_revive_with_parent_attribute_children <<
        pebbles = SoftNoReviveWithParentAttributeChild.new(:name => "pebbles")
    @fred.soft_no_revive_with_parent_attribute_children <<
        bambam = SoftNoReviveWithParentAttributeChild.new(:name => "bambam")
    # soft destroy pebbles
    pebbles.destroy
    assert_equal @fred.reload.soft_no_revive_with_parent_attribute_children.count, 2
    @fred.destroy
    assert_equal @fred.deleted?, true
    assert_equal pebbles.reload.deleted?, true
    assert_equal bambam.reload.deleted?, true
    @fred.revive
    assert_equal @fred.deleted?, false
    # pebbles should have been revived because attribute revive_with_parent is NOT supported by this model
    assert_equal pebbles.reload.deleted?, false
    assert_equal bambam.reload.deleted?, false
  end

end