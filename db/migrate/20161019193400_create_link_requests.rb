class CreateLinkRequests < ActiveRecord::Migration[5.0]
  def change
    create_table :link_requests do |t|
      t.integer :user_id
      t.integer :card_id
      t.float :lat
      t.float :lng

      t.timestamps
    end
  end
end
