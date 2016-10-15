# README

Curl de test pour le createcard :
# $ curl 'http://localhost:3000/users/1/createcard.json' -H 'Content-Type: application/json'  -d '{"card": {"card_name": "Business", "first_name": "Ben", "last_name": "Stirrup", "phone_nbr": "0606060606", "facebook_link": "...", "linkedin_link": "...", "email": "...", "street": "5 rue du surf", "city": "Noumea", "postal_code": ".", "country": "Nouvelle-Calédonie", "description": "blabla", "picture_url": "."} }'


Curl de test pour le createlink :
# $ curl 'http://localhost:3000/users/2/createlink.json' -H 'Content-Type: application/json'  -d '{"link": {"card_id": 1, "lat": 48.8771744, "lng": 2.3013612, "meeting_date": "2015-10-30"} }'


Création de la table cards :
# $ rails g model Card card_name:string first_name:string last_name:string phone_nbr:string facebook_link:string linkedin_link:string email:string street:string city:string postal_code:string country:string description:string picture_url:string user:references
# $ rake db:migrate
