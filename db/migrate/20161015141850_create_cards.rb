class CreateCards < ActiveRecord::Migration[5.0]
  def change
    create_table :cards do |t|
      t.string :card_name
      t.string :first_name
      t.string :last_name
      t.string :phone_nbr
      t.string :facebook_link
      t.string :linkedin_link
      t.string :email
      t.string :street
      t.string :city
      t.string :postal_code
      t.string :country
      t.string :description
      t.string :picture_url
      t.references :user, foreign_key: true

      t.timestamps
    end
  end
end
