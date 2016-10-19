json.links @links do |link|
  json.user_id link.user_id
  json.card_id link.card_id
  json.lat link.lat
  json.lng link.lng
  json.created_at link.created_at
  json.updated_at link.updated_at
end