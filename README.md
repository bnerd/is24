# is24

## Overview

Simple Ruby Client for Immobilienscout24.

### Installation

```ruby
gem install is24
```

### Usage

```ruby
# create client
client = Is24::Api.new(
  token: YOUR_ACCESS_TOKEN,
  secret: YOUR_TOKEN_SECRET,
  consumer_key: YOUR_CONSUMER_KEY,
  consumer_secret: YOUR_CONSUMER_SECRET
)
```

Get exposé for object

```ruby
expose = client.expose(ID)

# complete expose
puts expose

# eg. address
puts expose.contactDetails.address
```

## Authentication

IS24 uses oauth v1.0.

### Step 1: Get a request token

Set up a new client

```ruby
client = Is24::Api.new(
  consumer_key: YOUR_CONSUMER_KEY,
  consumer_secret: YOUR_CONSUMER_SECRET
)
```

and request a request_token providing a callback uri to your app

```ruby
request_token = client.request_token(YOUR_CALLBACK_URI)

## returns
# {
#  :oauth_token => OAUTH_TOKEN,
#  :oauth_token_secret => OAUTH_TOKEN_SECRET,
#  :redirect_uri => "http://rest.immobilienscout24.de/restapi/security/oauth/confirm_access?oauth_token=OAUTH_TOKEN"
# }
```

Redirect your user to the redirect_uri to authorize your request.

### Step 2: Request access token

Once the user has authorized your request you'll receive a get request to your
callback. Parse the response params and grab your tokens:

```ruby
tokens = client.request_access_token(
  oauth_token: OAUTH_TOKEN,
  oauth_token_secret: OAUTH_TOKEN_SECRET,
  oauth_verifier: OAUTH_VERIFIER )

## returns
# {
#  :oauth_token=> OAUTH_TOKEN,
#  :oauth_token_secret=> OAUTH_TOKEN_SECRET
# }
```

Until the user revokes permission to your app, the access_token is valid for an unlimited time. Store the tokens and reuse them for subsequent calls to restricted resources of the REST API.

## TODO

* Error handling ;)

## Contributing to is24
 
* Check out the latest master to make sure the feature hasn't been implemented or the bug hasn't been fixed yet.
* Check out the issue tracker to make sure someone already hasn't requested it and/or contributed it.
* Fork the project.
* Start a feature/bugfix branch.
* Commit and push until you are happy with your contribution.
* Make sure to add tests for it. This is important so I don't break it in a future version unintentionally.
* Please try not to mess with the Rakefile, version, or history. If you want to have your own version, or is otherwise necessary, that is fine, but please isolate to its own commit so I can cherry-pick around it.

## Copyright

Copyright (c) 2013 Bernd Suenkel. See LICENSE.txt for
further details.
