# ZohoHub

[![Build Status](https://travis-ci.com/rikas/zoho_hub.svg?branch=master)](https://travis-ci.com/rikas/zoho_hub)
[![Gem Version](https://badge.fury.io/rb/zoho_hub.svg)](https://badge.fury.io/rb/zoho_hub)

Simple wrapper around Zoho CRM version2, using [OAuth 2.0 protocol](https://www.zoho.com/crm/help/api/v2/#OAuth2_0)
for authentication.

This gem reads your Module configuration and builds the corresponding classes for you.

**NOTE: this gem is WIP, please try to use it and open an issue if you run into limitations / problems**

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'zoho_hub'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install zoho_hub

## Usage

First you need to have a configuration block like the one below:

```ruby
ZohoHub.configure do |config|
  config.client_id    = 'YOUR_ZOHO_CLIENT_ID'
  config.secret       = 'YOUR_ZOHO_SECRET'
  config.redirect_uri = 'YOUR_ZOHO_OAUTH_REDIRECT_URL'
  # config.debug      = true # this will be VERY verbose, but helps to identify bugs / problems
end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run
the tests. You can also run `bin/console` for an interactive prompt that will allow you to
experiment.

To install this gem onto your local machine, run `bundle exec rake install`.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/rikas/zoho_hub.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
