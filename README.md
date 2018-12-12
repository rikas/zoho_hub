# ZohoHub

[![Build Status](https://travis-ci.com/rikas/zoho_hub.svg?branch=master)](https://travis-ci.com/rikas/zoho_hub)
[![Gem Version](https://badge.fury.io/rb/zoho_hub.svg)](https://badge.fury.io/rb/zoho_hub)

Simple wrapper around Zoho CRM version2, using [OAuth 2.0 protocol](https://www.zoho.com/crm/help/api/v2/#OAuth2_0)
for authentication.

This gem reads your Module configuration and builds the corresponding classes for you, using some
reflection mechanisms. You should then be able to use simple classes with an API close to
ActiveRecord, to do CRUD operations.

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

## Setup process

### 1. Register your application

If you want to access your Zoho CRM account from your application you first need to create your
application as described here: https://www.zoho.com/crm/help/api/v2/#oauth-request.

**TODO TODO - explain "Authorized redirect URIs"**

This will give you a **Client ID** and a **secret**, that you'll use in the next step.

### 2. Authorization

#### 2.1 Configure ZohoHub with your credentials

You need to have a configuration block like the one below (in rails add a `zoho_hub.rb` in your
`config/initializers` dir):

```ruby
ZohoHub.configure do |config|
  config.client_id    = 'YOUR_ZOHO_CLIENT_ID' # obtained in 1.
  config.secret       = 'YOUR_ZOHO_SECRET'    # obtained in 1.
  config.redirect_uri = 'YOUR_ZOHO_OAUTH_REDIRECT_URL'
  # config.debug      = true # this will be VERY verbose, but helps to identify bugs / problems
end
```

**Note:** if you don't know what the `redirect_url` is then **TODO TODO TODO TODO TODO**

##### 2.1.1 Configuring for use with a single Zoho CRM database

You can add the following to your `zoho_hub.rb` initializer if you will only be integrating with a single Zoho CRM account:

```ruby
  if crm = YOUR_AUTHENTICATION_MODEL.zohocrm_scope.first
    ZohoHub.setup_connection(
      access_token: crm.token,
      expires_in: crm.expires_in,
      refresh_token: crm.refresh_token,
      api_domain: 'https://www.zohoapis.com' # Only needed if using Zoho CRM in North America
    )
    ZohoHub.on_refresh do |params|
      # Perform logic to refresh access token and persist the data
      # to the existing record
      api_client = YOUR_AUTHENTICATION_MODEL.zohocrm_scope.first
      ZohoHub.setup_connection(
        access_token: api_client.token,
        refresh_token: api_client.refresh_token,
        api_domain: 'https://www.zohoapis.com'
      )
    end
  end
```

#### 2.2 Authorization request

In order to access data in Zoho CRM you need to authorize ZohoHub to access your account. To do so
you have to request a specific URL with the right **scope** and **access_type**.

To get the right URL you can use this simple line of code:

```ruby
ZohoHub::Auth.auth_url
# => "https://accounts.zoho.eu/oauth/v2/auth?access_type=offline&client_id=&redirect_uri=&response_type=code&scope=ZohoCRM.modules.custom.all,ZohoCRM.settings.all,ZohoCRM.modules.contacts.all,ZohoCRM.modules.all"
```

If you request this generated URL you should see a screen like this one, where you have to click on "Accept":

![](https://duaw26jehqd4r.cloudfront.net/items/1h1i3C1N0k0i02092F0S/Screen%20Shot%202018-11-25%20at%2019.18.38.png)

You can change the default scope (what data can be accessed by your application). This is the list
provided as the default scope:

```
ZohoCRM.modules.custom.all
ZohoCRM.settings.all
ZohoCRM.modules.contacts.all
ZohoCRM.modules.all
```

To get the URL for a different scope you can provide a `scope` argument:

```ruby
ZohoHub::Auth.auth_url(scope: ['ZohoCRM.modules.custom.all', 'ZohoCRM.modules.all'])
# => "https://accounts.zoho.eu/oauth/v2/auth?access_type=offline&client_id=&redirect_uri=&response_type=code&scope=ZohoCRM.modules.custom.all,ZohoCRM.modules.all"
```

#### 2.3 Offline access

By design the access tokens returned by the OAuth flow expire after a period of time (1 hour by
default), as a safety mechanism. This means that any application that wants to work with a user's
data needs the user to have recently gone through the OAuth flow, aka be online.

When you request offline access the Zoho API returns a refresh token. Refresh tokens give your
application the ability to request data on behalf of the user when the user is not present and in
front of your application.

**By default `ZohoHub::Auth.auth_url` will request offline access**

You can force "online" access by using `#auth_url` with a `access_type` argument:

```ruby
ZohoHub::Auth.auth_url(access_type: 'online')
# => "https://accounts.zoho.eu/oauth/v2/auth?access_type=online&client_id=&redirect_uri=&response_type=code&scope=ZohoCRM.modules.custom.all,ZohoCRM.settings.all,ZohoCRM.modules.contacts.all,ZohoCRM.modules.all"
```

## 3. Generate Access Token

**TODO**

## 4. Refreshing Access Token

**TODO**

## Extending the Default API

The base APIs do not provide lots of functionality, especially if your
CRM data has several custom fields. It is easiest to define what your
models appear as on Zoho CRM. The 
[Zoho CRM API v2 docs provide information about their naming conventions](https://www.zoho.com/crm/help/api-diff/),
which ZohoHub should handle gracefully. If some fields have strange names,
or names that don't make sense (this can be common with existing CRM databases)
they can be corrected through the use of the `attribute_translation` method.

For example:

```ruby
class MyAccount < ZohoHub::Account
  attributes :id, :account_name
  attributes :billing_contact_name, :billing_city, :billing_code, :billing_country
  attributes :shipping_contact, :shipping_phone

  attribute_translation(
    # class attribute name => zoho crm attribute name
    shipping_contact: :Main_Contact_Name,
    shipping_phone: :Phone,
    billing_contact_name: :BillingContactName
  )
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
