class CreateTickets < ActiveRecord::Migration
  def up
    create_table :tickets do |t|
      t.string :uuid
      t.xml :payload
    end
  end

  def down
    drop_table :tickets
  end
end
