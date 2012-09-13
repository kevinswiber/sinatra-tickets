class ChangesAddCreatedAt < ActiveRecord::Migration
  def up
    add_column :changes, :created_at, :datetime
  end

  def down
    drop_column :changes, :created_at
  end
end