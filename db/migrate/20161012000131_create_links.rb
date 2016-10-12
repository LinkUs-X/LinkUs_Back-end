class CreateLinks < ActiveRecord::Migration[5.0]
  def change
    create_table :links do |t|
      t.float :lat
      t.float :lng
      t.date :meeting_date
      t.references :user, foreign_key: true
      t.references :card, foreign_key: true

      t.timestamps
    end
  end
end
