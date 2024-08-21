# README

# How to use
 1. Pull down repo and bundle install.
 2. Run `rails s` to start server.
 3. Rename `.env.example` to `.env` and populate values. 
    * Make google developer account and get API key or contact me for API key. Use "https://maps.googleapis.com/maps/api/distancematrix/json?" for MAPS_BASE_URL
 5. Run `rails db:create db:migrate db:seed` on the command line to setup the database. 
 5. Use curl or an http client like postman to hit [localhost:3000/rides?driver_id=1](localhost:3000/rides?driver_id=1) and view ordered ride scores. 

# API Docs

### Retrieve Rides By Driver Endpoint
**URL:** `/rides`

**Method:** GET

**Description:** This endpoint retrieves rides for a specific driver. 

**Query Parameters:**

- `driver_id` (integer, required): ID of the driver whose rides are being retrieved.

**Response Format:** The response contains a JSON array of ride objects in descending score order, each including the ride ID and score.



# Limitations
Due to the sample app nature of this project, I did not write this to the standard of a production app. There are several areas that I would implement differently if this was a production app: 
1. I would implement pagination or limit number of rides fetched at once since some drivers may have a large number of rides.  
2. To reduce duplicate API calls, I could persist the score of a ride in case it is recurring.
3. I would use feature branching instead of commiting on the main branch. 
4. I would implement a real logging system for errors, instead of just using `puts`.
5. I would likely round the `ride_score` to a few decimals, depending on use case. 
6. I would add authentication. 
