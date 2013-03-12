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

Get expose for object

```ruby
expose = client.expose(ID)

# complete expose
puts expose

# eg. address
puts expose.contactDetails.address
```

### Contributing to is24
 
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
