class AddCardToLinks < ActiveRecord::Migration[5.0]
  def change
    add_column :links, :card_id, :int
  end
end
