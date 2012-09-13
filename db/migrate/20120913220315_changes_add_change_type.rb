class ChangesAddChangeType < ActiveRecord::Migration
  def up
    add_column :changes, :change_type, :string
  end

  def down
    drop_column :changes, :change_type
  end
end
