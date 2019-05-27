# ZohoHub

[![Build Status](https://travis-ci.com/rikas/zoho_hub.svg?branch=master)](https://travis-ci.com/rikas/zoho_hub)
[![Gem Version](https://badge.fury.io/rb/zoho_hub.svg)](https://badge.fury.io/rb/zoho_hub)

Simple wrapper around Zoho CRM version2, using [OAuth 2.0 protocol](https://www.zoho.com/crm/help/developer/api/oauth-overview.html)
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
application as described here: https://www.zoho.com/crm/help/developer/api/register-client.html.

This will give you a **Client ID** and a **secret**, that you'll use in step 2.

#### 1.1 Zoho Accounts URL

Registration and authorization requests are made to Zoho's domain-specific Accounts URL which
varies depending on your region:

* EU: https://accounts.zoho.eu
* US: https://accounts.zoho.com
* China: https://accounts.zoho.com.cn

ZohoHub uses the EU Account URL by default, but this can be overriden in a `ZohoHub.configure`
block via the `api_domain` method (see step 2.)

#### 1.2 Authorized Redirect URI

Per Zoho's API documentation, providing a **redirect URI** is optional. Doing so allows a user of
your application to be redirected back to your app (to the **redirect URI**) with a **grant token** 
upon successful authentication.

If you don't provide a **redirect URI**, you'll need to use the [self-client option](https://www.zoho.com/crm/help/developer/api/auth-request.html#plink2)
for authorization (see 3.2 below.)

### 2. Configure ZohoHub with your credentials

> **Note:** Treat these credentials like an important password. It is *strongly* recommended to not
> paste them anywhere in plain text. Do *not* add them to version control; keep them out of your
> code directly by referencing them via environment variables. Use something like the dotenv gem or
> encrypted credentials in Rails to keep them as secret and secure as possible.

You need to have a configuration block like the one below (in rails add a `zoho_hub.rb` in your
`config/initializers` directory):

```ruby
ZohoHub.configure do |config|
  config.client_id    = 'YOUR_ZOHO_CLIENT_ID' # obtained in 1.
  config.secret       = 'YOUR_ZOHO_SECRET'    # obtained in 1.
  config.redirect_uri = 'YOUR_ZOHO_OAUTH_REDIRECT_URL'
  config.api_domain   = 'https://accounts.zoho.com' # can be omitted if in the EU
  # config.debug      = true # this will be VERY verbose, but helps to identify bugs / problems
end
```

### 3. Authorization request

In order to access data in Zoho CRM you need to authorize ZohoHub to access your account. To do so
you have to request a specific URL with the right **scope** and **access_type**. Successful
authorization will provide a **grant token** which will be used to generate **access** and
**refresh tokens**.

#### 3.1 Redirection based authentication

To get the right URL you can use this simple line of code:

```ruby
ZohoHub::Auth.auth_url
# => "https://accounts.zoho.eu/oauth/v2/auth?access_type=offline&client_id=&redirect_uri=&response_type=code&scope=ZohoCRM.modules.custom.all,ZohoCRM.settings.all,ZohoCRM.modules.contacts.all,ZohoCRM.modules.all"
```

If you request this generated URL you should see a screen like this one, where you have to click on "Accept":

![](https://duaw26jehqd4r.cloudfront.net/items/1h1i3C1N0k0i02092F0S/Screen%20Shot%202018-11-25%20at%2019.18.38.png)

You will then be redirected to the **redirect URI** you provided with additional query parameters
as follows (the value after `code=` is the **grant token**):

```
{redirect_uri}?code={grant_token}&location=us&accounts-server=https%3A%2F%2Faccounts.zoho.com
```

#### 3.2 Self-Client Authorization

If you don't have a **redirect URI** or you want your application to be able to authorize with Zoho
programmatically (without a user required to be present and click the "Accept" prompt), Zoho
provides a [self-client option](https://www.zoho.com/crm/help/developer/api/auth-request.html#plink2)
for authentication which will provide a **grant token**.

#### 3.3 More on scopes

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

Refer to [Zoho's API documentation on scopes](https://www.zoho.com/crm/help/developer/api/oauth-overview.html#plink5) for detailed information.

#### 3.4 Offline access

By design the **access tokens** returned by the OAuth flow expire after a period of time (1 hour by
default), as a safety mechanism. This means that any application that wants to work with a user's
data needs the user to have recently gone through the OAuth flow, aka be online.

When you request offline access the Zoho API returns a **refresh token**. **Refresh tokens** give your
application the ability to request data on behalf of the user when the user is not present and in
front of your application.

**By default `ZohoHub::Auth.auth_url` will request offline access**

You can force "online" access by using `#auth_url` with a `access_type` argument:

```ruby
ZohoHub::Auth.auth_url(access_type: 'online')
# => "https://accounts.zoho.eu/oauth/v2/auth?access_type=online&client_id=&redirect_uri=&response_type=code&scope=ZohoCRM.modules.custom.all,ZohoCRM.settings.all,ZohoCRM.modules.contacts.all,ZohoCRM.modules.all"
```

### 4. Access token

See Zoho's API documentation for generating an initial **access token**:
https://www.zoho.com/crm/help/developer/api/access-refresh.html

To use an **access token** in a manual request, include it as a request header as
`Authorization: Zoho-oauthtoken {access_token}` (without the braces.)

To use an **access token** with ZohoHub, pass it to the `ZohoHub.setup_connection` method as the
`access_token` parameter.


### 5. Refresh token

TODO

### 6. Basic ZohoHub flow

Once ZohoHub has been configured with your credentials (section 2) and you have a fresh **access
token**, setup a ZohoHub connection:

```ruby
ZohoHub.setup_connection access_token: 'ACCESS_TOKEN',
                         expires_in: 'EXPIRES_IN_SEC',
                         api_domain: 'API_DOMAIN'
```

Now you can issue requests to Zoho's API with the Connection object, e.g.:

```ruby
# request a (paginated) list of all Lead records
ZohoHub.connection.get 'Leads'
```

A successful request will receive a response like the sample here: https://www.zoho.com/crm/help/developer/api/get-records.html.

### 7. BaseRecord and record classes

At this point, ZohoHub is starting to do some of the heavy lifting, but using `ZohoHub.connection`
still gets tedious after just a handful of requests. But we can improve that by allowing ZohoHub
to build our record classes or by manually defining them ourselves.

#### 7.1 Reflection

TODO

#### 7.2 Subclassing BaseRecord

See `lib/zoho_hub/base_record.rb` and any of the classes in `lib/zoho_hub/deprecated_and_only_for_reference_records/`
for reference.

For any Zoho module with which you want to interact via ZohoHub, make a class of the same name that
inherits from `ZohoHub::BaseRecord`. For example, to build a class for the Leads module:

```ruby
# lead.rb

class Lead < BaseRecord
  ...
end
```

Specify this module's fields as attributes:

```ruby
# lead.rb

class Lead < BaseRecord
  attributes: :id, :first_name, :last_name, :phone, :email, :source, # etc.
end
```

Define an `initialize` method to populate attributes:

```ruby
def initialize(params)
  attributes.each do |attr|
    zoho_key = attr_to_zoho_key(attr)

    send("#{attr}=", params[zoho_key] || params[attr] || DEFAULTS[attr])
  end
end
```

Now you can issue requests more easily with your record class, e.g.:

```ruby
# request a (paginated) list of all Lead records
Lead.all
```

## Tips and suggestions

* Using a tool such as Postman or curl to issue HTTP requests and verify responses in isolation
  can be a great sanity check during setup.
* Downloading ZohoHub code (as opposed to the gem) and running `bin/console` is a great way to
  learn how the code works and test aspects of setup and Zoho's API in isolation. 
* [The Zoho API Documentation](https://www.zoho.com/crm/help/developer/api/overview.html) is your
  friend - especially the sample HTTP requests and responses in the various sections under "Rest
  API" on the left.
* If you're manually implementing your record classes (rather than using the reflection mechanism),
  the files in `/lib/zoho_hub/deprecated_and_only_for_reference_records/` can help you get started.
* Requests can be issued to Zoho CRM's [Sandbox](https://help.zoho.com/portal/kb/articles/using-sandbox)
  by configuring `https://crmsandbox.zoho.com/crm` (or regional equivalent) as the `api_domain`.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run
the tests. You can also run `bin/console` for an interactive prompt that will allow you to
experiment.

To install this gem onto your local machine, run `bundle exec rake install`.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/rikas/zoho_hub.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
