require "#{File.dirname(__FILE__)}/test_helper"


class ClassMethodTest < Test::Unit::TestCase

  def setup
    @fred   = Parent.create!(:name => "fred")
  end

  def teardown
    Parent.delete_all
  end

  def test_soft_dependencies
    assert_equal 20, Parent.soft_dependencies.count

    assert Parent.soft_dependencies.include? :soft_children
    assert Parent.soft_dependencies.include? :children
    assert Parent.soft_dependencies.include? :soft_one
    assert Parent.soft_dependencies.include? :one

    assert Parent.soft_dependencies.include? :soft_restrict_children
    assert Parent.soft_dependencies.include? :restrict_children
    assert Parent.soft_dependencies.include? :soft_restrict_one
    assert Parent.soft_dependencies.include? :restrict_one

    assert Parent.soft_dependencies.include? :soft_nullify_children
    assert Parent.soft_dependencies.include? :nullify_children
    assert Parent.soft_dependencies.include? :soft_nullify_one
    assert Parent.soft_dependencies.include? :nullify_one

    assert Parent.soft_dependencies.include? :soft_delete_all_children
    assert Parent.soft_dependencies.include? :delete_all_children
    assert Parent.soft_dependencies.include? :soft_delete_one
    assert Parent.soft_dependencies.include? :delete_one

    assert Parent.soft_dependencies.include? :soft_parent_sports
    assert Parent.soft_dependencies.include? :parent_sports
    assert Parent.soft_dependencies.include? :soft_parent_nickname
    assert Parent.soft_dependencies.include? :parent_nickname   
  end

  def test_soft_dependency_order
    # verify has_one dependencies are evaluated before has_many
    assert Parent.soft_dependencies.index(:soft_one) < Parent.soft_dependencies.index(:soft_children)
  end

  def test_restrict_dependencies
    assert_equal 4, Parent.restrict_dependencies.count

    assert Parent.restrict_dependencies.include? :soft_restrict_children
    assert Parent.restrict_dependencies.include? :restrict_children
    assert Parent.restrict_dependencies.include? :soft_restrict_one
    assert Parent.restrict_dependencies.include? :restrict_one
  end

  def test_respond_to_destroy!
    assert @fred.respond_to?(:destroy!)
  end

  def test_respond_to_deleted_scope
    assert SoftChild.respond_to?(:deleted)
    assert_equal Child.respond_to?(:deleted), false
  end

  def test_respond_to_not_deleted_scope
    assert SoftChild.respond_to?(:not_deleted)
    assert_equal Child.respond_to?(:not_deleted), false
  end

  def test_soft_destroyable?
    assert SoftChild.soft_destroyable?
    assert_equal Child.soft_destroyable?, false
  end

  def test_not_deleted_scope
    barney = Parent.create!(:name => "barney")
    @fred.destroy
    assert_equal Parent.not_deleted.size, 1
    assert !Parent.not_deleted.include?(@fred)
    assert Parent.not_deleted.include? barney
  end

  def test_deleted_scope
    barney = Parent.create!(:name => "barney")
    @fred.destroy
    assert_equal Parent.deleted.size, 1
    assert Parent.deleted.include?(@fred)
    assert !Parent.deleted.include?(barney)
  end

end