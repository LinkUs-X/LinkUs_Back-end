# README

Pour parler à Heroku plutôt qu'en local, remplacer localhost:3000 par link-us-back.herokuapp.com

Curl de test pour get les users :
# $ curl 'http://localhost:3000/users/1.json' -H 'Content-Type: application/json'

Curl de test pour le createusers :
# $ curl 'http://localhost:3000/users/createuser.json' -H 'Content-Type: application/json' -d '{"user": {"login": "Ben la murène", "password": "lapetitesirenetoimemetusais"} }'

Curl de test pour le createcard :
# $ curl 'http://localhost:3000/users/1/createcard.json' -H 'Content-Type: application/json'  -d '{"card": {"card_name": "Business", "first_name": "Ben", "last_name": "Stirrup", "phone_nbr": "0606060606", "facebook_link": "...", "linkedin_link": "...", "email": "...", "street": "5 rue du surf", "city": "Noumea", "postal_code": ".", "country": "Nouvelle-Calédonie", "description": "blabla", "picture_url": "."} }'

Curl de test pour le createlink :
# $ curl 'http://localhost:3000/users/2/createlink.json' -H 'Content-Type: application/json'  -d '{"link": {"card_id": 1, "lat": 48.8771744, "lng": 2.3013612, "meeting_date": "2015-10-30"} }'

Création de la table cards :
# $ rails g migration DropCards 
# $ rails g model Card card_name:string first_name:string last_name:string phone_nbr:string facebook_link:string linkedin_link:string email:string street:string city:string postal_code:string country:string description:string picture_url:string user:references
# $ rake db:migrate

Création de la table links :
# $ rails g migration DropLinks 
# $ rails g model Link card_id:integer lat:float lng:float meeting_date:date user:references
# $ rake db:migrate

-------------How to CREATE contact requests & CHECK if they led to links creation-----------------

## POST request: /users/:id/createrequest ; required parameters when creating link_request:
   card_id, lat, lng ; note that user_id is taken from URL.
   
   # Create link request from @user (id: params[:id]) who kind of "display" its card to other users. If another user creates a similar request within a 15 seconds interval and within a 25 meters radius, provided they did not already exchanged their cards in the past, they will exchange their cards now.
   
   # Example: suppose user1 creates a contact request, and then user2 creates a contact request within 15 seconds and within a 25 meters radius. The following links are created:
   link1 => user_id: user2.id, card_id: card_of_user1.id  meaning user2 has the card of user1.
   link2 => user_id: user1.id, card_id: card_of_user2.id  meaning user1 has the card of user2.
   
   # NB: all link_request objects are stored in the database, whether or not they were used
   to successfully create links between two users.

   # Curl de test pour le createrequest : note the 3rd request is too far away from the other two and should not create any link:
   
   # User 1:
   $ curl 'http://localhost:3000/users/1/createrequest.json' -H 'Content-Type: application/json' -d '{"link_request": {"card_id": 1, "lat": 48.713549, "lng": 2.215676} }'

   # User 2:
   $ curl 'http://localhost:3000/users/2/createrequest.json' -H 'Content-Type: application/json' -d '{"link_request": {"card_id": 3, "lat": 48.713341, "lng": 2.215664} }'

   # User 3:
   $ curl 'http://localhost:3000/users/3/createrequest.json' -H 'Content-Type: application/json' -d '{"link_request": {"card_id": 4, "lat": 48.712899, "lng": 2.215017} }'

## GET request: /users/:id/verifylinkcreation
   
   # The following link_request mentionned is the last link_request from @user (id: params[:id]):

   Renders html: 'success' if the link_request is successful within 15 seconds.
   Renders html: 'pending' if the link_request is unsuccessful and was created less than 15s ago.
   Renders html: 'error' if the link_request is unsuccessful and was created more than 15s ago.
   
   # NB: to be used by front-end as condition for timeout after a link-request.
  
-----------------------------------------------------------------------------------------------------


--------------------------------USEFUL TERMINAL COMMANDS --------------------------------------------

## Heroku:
$ heroku run rails console
$ git push heroku master
$ heroku run rake --trace db:migrate

## Rails:
$ rails console
$ rails console --sandbox
$ rails generate migration AddObject_To_AddToModel object_to_add:type
$ rails generate migration RemovePartNumberFromProducts part_number:string
$ rails db:migrate

## In console (rails or heroku):
>>> Object.delete_all
>>> exit
