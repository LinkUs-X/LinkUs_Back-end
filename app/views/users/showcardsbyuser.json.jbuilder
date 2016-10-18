 json.cards @cards do |card|
  json.user_id card.user_id
  json.card_name card.card_name 
  json.first_name card.first_name 
  json.last_name card.last_name 
  json.phone_nbr card.phone_nbr 
  json.facebook_link card.facebook_link 
  json.linkedin_link card.linkedin_link 
  json.email card.email 
  json.street card.street 
  json.city card.city 
  json.postal_code card.postal_code 
  json.country card.country 
  json.description card.description 
  json.picture_url card.picture_url 
  json.created_at card.created_at
  json.updated_at card.updated_at
end