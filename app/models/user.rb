class User < ApplicationRecord
	has_many :cards
	has_many :links
	has_many :link_requests
end
