class CreateUsers < ActiveRecord::Migration
  def up
    create_table :users do |t|
      t.string :uuid
      t.xml :payload
    end
  end

  def down
    drop_table :users
  end
end
