class CreateChanges < ActiveRecord::Migration
  def up
    create_table :changes do |t|
      t.string :uuid
      t.xml :payload
    end
  end

  def down
    drop_table :changes
  end
end
