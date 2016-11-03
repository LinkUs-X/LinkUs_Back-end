if (defined? @link1) == "instance-variable" && (defined? @link2) == "instance-variable"
	@links = [@link1, @link2]
	json.links @links.each do |link|
	  json.user_id link.user_id
	  json.card_id link.card_id
	  json.lat link.lat
	  json.lng link.lng
	  json.created_at link.created_at
	  json.updated_at link.updated_at

	  @card = Card.find(link.card_id)
	  json.card @card 
	end
 end