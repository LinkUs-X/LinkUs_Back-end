json.links @links do |link|
  json.card_id link.card_id
  json.lat link.lat
  json.lng link.lng
  json.meeting_date link.meeting_date
  json.user_id link.user_id
  json.created_at link.created_at
  json.updated_at link.updated_at
end