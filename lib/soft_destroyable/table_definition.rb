module SoftDestroyable
  module TableDefinition

    # provide a migration short-cut for defining the required soft-destroyable columns
    # can be used inside of a create_table or change_table (to add the columns)
    #
    # If you want to index on either of these fields, you need to handle that separately
    def soft_destroyable
      column "deleted", :boolean, :default => false
      column "deleted_at", :datetime
      column "revive_with_parent", :boolean, :default => true
    end

    # useful on migration's for tables which were migrated with 'soft_destroyable' prior to revive_with_parent
    def revive_tracking
      column "revive_with_parent", :boolean, :default => true
    end

  end
end

