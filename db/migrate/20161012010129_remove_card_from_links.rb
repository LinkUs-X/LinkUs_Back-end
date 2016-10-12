class RemoveCardFromLinks < ActiveRecord::Migration[5.0]
  def change
    remove_index :links, :card_id
    remove_column :links, :card_id, :string
  end
end
