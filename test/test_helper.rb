require 'test/unit'

require 'rubygems'
gem 'activerecord', '~> 3.0.0'
require 'active_record'

require "#{File.dirname(__FILE__)}/../init"

ActiveRecord::Base.establish_connection(:adapter => "sqlite3", :database => ":memory:")

def setup_db
  ActiveRecord::Schema.define(:version => 1) do
    create_table :parents do |t|
      t.string :name
      t.soft_destroyable
    end

    # used to test non_dependent associations
    create_table :non_dependent_children do |t|
      t.string :name
      t.references :parent
    end

    # used to test has_many through
    create_table :soft_parent_sports do |t|
      t.references :parent
      t.references :soft_sport
      t.soft_destroyable
    end

    # used to test has_many through
    create_table :parent_sports do |t|
      t.references :parent
      t.references :sport
    end

    # used to test has_many through
    create_table :soft_sports do |t|
      t.string :name
    end

    # used to test has_many through
    create_table :sports do |t|
      t.string :name
    end

    # used to test has_one through
    create_table :soft_parent_nicknames do |t|
      t.references :parent
      t.references :soft_nickname
      t.soft_destroyable
    end

    # used to test has_one through
    create_table :parent_nicknames do |t|
      t.references :parent
      t.references :nickname
    end

    # used to test has_one through
    create_table :soft_nicknames do |t|
      t.string :name
    end

    # used to test has_one through
    create_table :nicknames do |t|
      t.string :name
    end

    # used to test has_many <soft_destroyable_model>, :dependent => :destroy
    create_table :soft_children do |t|
      t.string :name
      t.references :parent
      t.soft_destroyable
    end

    # used to test has_many <model>, :dependent => :destroy
    create_table :children do |t|
      t.string :name
      t.references :parent
    end

    # used to test has_one <soft_destroyable_model>, :dependent => :destroy
    create_table :soft_ones do |t|
      t.string :name
      t.references :parent
      t.soft_destroyable
    end

    # used to test has_one <model>, :dependent => :destroy
    create_table :ones do |t|
      t.string :name
      t.references :parent
    end

    # used to test has_many <soft_destroyable_model>, :dependent => :nullify
    create_table :soft_nullify_children do |t|
      t.string :name
      t.references :parent
      t.soft_destroyable
    end

    # used to test has_many <model>, :dependent => :nullify
    create_table :nullify_children do |t|
      t.string :name
      t.references :parent
    end

    # used to test has_one <soft_destroyable_model>, :dependent => :nullify
    create_table :soft_nullify_ones do |t|
      t.string :name
      t.references :parent
      t.soft_destroyable
    end

    # used to test has_one <model>, :dependent => :nullify
    create_table :nullify_ones do |t|
      t.string :name
      t.references :parent
    end

    # used to test has_many <soft_destroyable_model>, :dependent => :restrict
    create_table :soft_restrict_children do |t|
      t.string :name
      t.references :parent
      t.soft_destroyable
    end

    # used to test has_many <model>, :dependent => :restrict
    create_table :restrict_children do |t|
      t.string :name
      t.references :parent
    end

    # used to test has_one <soft_destroyable_model>, :dependent => :restrict
    create_table :soft_restrict_ones do |t|
      t.string :name
      t.references :parent
      t.soft_destroyable
    end

    # used to test has_one <model>, :dependent => :restrict
    create_table :restrict_ones do |t|
      t.string :name
      t.references :parent
    end

    # used to test has_many <soft_destroyable_model>, :dependent => :delete_all
    create_table :soft_delete_all_children do |t|
      t.string :name
      t.references :parent
      t.soft_destroyable
    end

    # used to test has_many <model>, :dependent => :delete_all
    create_table :delete_all_children do |t|
      t.string :name
      t.references :parent
    end

    # used to test has_one <soft_destroyable_model>, :dependent => :delete
    create_table :soft_delete_ones do |t|
      t.string :name
      t.references :parent
      t.soft_destroyable
    end

    # used to test has_one <model>, :dependent => :delete
    create_table :delete_ones do |t|
      t.string :name
      t.references :parent
    end

    # used to test callbacks
    create_table :callback_parents do |t|
      t.string :name
      t.soft_destroyable
    end

    # used to test before_soft_destroy and before_destroy!
    create_table :soft_callback_children do |t|
      t.string :name
      t.references :callback_parent
      t.soft_destroyable
    end

    # used to test callbacks
    create_table :callback_children do |t|
      t.string :name
      t.references :callback_parent
    end

    # used to test behavior of soft_destroy migration without revive_with_parent column
    create_table :soft_no_revive_with_parent_attribute_children do |t|
      t.string :name
      t.references :parent
      t.boolean :deleted, :default => false
      t.datetime :deleted_at
    end

    # todo: HasAndBelongsToMany?
  end
end

setup_db


class Parent < ActiveRecord::Base
  has_many :non_dependent_children

  # dependent destroy associations
  has_many :soft_children, :dependent => :destroy
  has_many :children, :dependent => :destroy
  has_one :soft_one, :dependent => :destroy
  has_one :one, :dependent => :destroy

  # used to test has_many through associations
  has_many :soft_parent_sports, :dependent => :destroy
  has_many :soft_sports, :through => :soft_parent_sports
  has_many :parent_sports, :dependent => :destroy
  has_many :sports, :through => :parent_sports

  # used to test has_one through associations
  has_one :soft_parent_nickname, :dependent => :destroy
  has_one :soft_nickname, :through => :soft_parent_nickname
  has_one :parent_nickname, :dependent => :destroy
  has_one :nickname, :through => :parent_nickname

  # dependent nullify associations
  has_many :soft_nullify_children, :dependent => :nullify
  has_many :nullify_children, :dependent => :nullify
  has_one :soft_nullify_one, :dependent => :nullify
  has_one :nullify_one, :dependent => :nullify

  # dependent restrict associations
  has_many :soft_restrict_children, :dependent => :restrict
  has_many :restrict_children, :dependent => :restrict
  has_one :soft_restrict_one, :dependent => :restrict
  has_one :restrict_one, :dependent => :restrict

  # dependent delete_all, delete associations
  has_many :soft_delete_all_children, :dependent => :delete_all
  has_many :delete_all_children, :dependent => :delete_all
  has_one :soft_delete_one, :dependent => :delete
  has_one :delete_one, :dependent => :delete

  has_many :soft_no_revive_with_parent_attribute_children, :dependent => :destroy

  soft_destroyable
end

class NonDependentChild < ActiveRecord::Base
  belongs_to :parent
end

class SoftChild < ActiveRecord::Base
  belongs_to :parent
  soft_destroyable
end

class Child < ActiveRecord::Base
  belongs_to :parent
end

class SoftOne < ActiveRecord::Base
  belongs_to :parent
  soft_destroyable
end

class One < ActiveRecord::Base
  belongs_to :parent
end

class SoftNullifyChild < ActiveRecord::Base
  belongs_to :parent
  soft_destroyable
end

class NullifyChild < ActiveRecord::Base
  belongs_to :parent
end

class SoftNullifyOne < ActiveRecord::Base
  belongs_to :parent
  soft_destroyable
end

class NullifyOne < ActiveRecord::Base
  belongs_to :parent
end

class SoftRestrictChild < ActiveRecord::Base
  belongs_to :parent
  soft_destroyable
end

class RestrictChild < ActiveRecord::Base
  belongs_to :parent
end

class SoftRestrictOne < ActiveRecord::Base
  belongs_to :parent
  soft_destroyable
end

class RestrictOne < ActiveRecord::Base
  belongs_to :parent
end

class SoftDeleteAllChild < ActiveRecord::Base
  belongs_to :parent
  soft_destroyable
end

class DeleteAllChild < ActiveRecord::Base
  belongs_to :parent
end

class SoftDeleteOne < ActiveRecord::Base
  belongs_to :parent
  soft_destroyable
end

class DeleteOne < ActiveRecord::Base
  belongs_to :parent
end

class ParentSport < ActiveRecord::Base
  belongs_to :parent
  belongs_to :sport
end

class SoftParentSport < ActiveRecord::Base
  belongs_to :parent
  belongs_to :soft_sport
  soft_destroyable
end

class SoftSport < ActiveRecord::Base
  has_many :soft_parent_sports
  soft_destroyable
end

class Sport < ActiveRecord::Base
  has_many :parent_sports
end

class ParentNickname < ActiveRecord::Base
  belongs_to :parent
  belongs_to :nickname
end

class SoftParentNickname < ActiveRecord::Base
  belongs_to :parent
  belongs_to :soft_nickname
  soft_destroyable
end

class SoftNickname < ActiveRecord::Base
  has_one :soft_parent_nickname
  soft_destroyable
end

class Nickname < ActiveRecord::Base
  has_one :parent_nickname
end

class CallbackParent < ActiveRecord::Base
  has_many :soft_callback_children, :dependent => :destroy
  has_many :callback_children, :dependent => :destroy
  soft_destroyable
end

class PreventDestroyBangError < StandardError

end

class PreventSoftDestroyError < StandardError

end

class SoftCallbackChild < ActiveRecord::Base
  belongs_to :callback_parent
  soft_destroyable

  def before_soft_destroy
    raise PreventSoftDestroyError.new
  end

  def before_destroy!
    raise PreventDestroyBangError.new
  end
end

class CallbackChild < ActiveRecord::Base
  belongs_to :callback_parent

  def before_soft_destroy
    raise PreventSoftDestroyError.new
  end

  def before_destroy!
    raise PreventDestroyBangError.new
  end
end

class SoftNoReviveWithParentAttributeChild < ActiveRecord::Base
  belongs_to :parent
  soft_destroyable
end
