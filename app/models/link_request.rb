class LinkRequest < ApplicationRecord
  belongs_to :user
  belongs_to :card 

  validates_presence_of :card_id 
  validates_presence_of :lat 
  validates_presence_of :lng

end
