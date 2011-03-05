module SoftDestroyable
  module TableDefinition

    # provide a migration short-cut for defining the required soft-destroyable columns
    # can be used inside of a create_table or change_table (to add the columns)
    #
    # If you want to index on either of these fields, you need to handle that separately
    def soft_destroyable
      column "deleted", :boolean, :default => false
      column "deleted_at", :datetime
    end

  end
end

