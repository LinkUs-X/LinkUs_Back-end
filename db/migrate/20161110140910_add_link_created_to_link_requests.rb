class AddLinkCreatedToLinkRequests < ActiveRecord::Migration[5.0]
  def change
    add_column :link_requests, :link_created, :boolean
  end
end
