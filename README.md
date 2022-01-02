[![Gem Version](https://badge.fury.io/rb/omniauth-seznam-cz.svg)](https://badge.fury.io/rb/omniauth-seznam-cz)
[![Build Status](https://travis-ci.com/zquestz/omniauth-seznam-cz.svg)](https://travis-ci.com/zquestz/omniauth-seznam-cz)

# OmniAuth Seznam.cz Strategy

Strategy to authenticate with Seznam.cz in OmniAuth.

Get your API key at: https://vyvojari.seznam.cz/oauth/admin  Note the Client ID and the Client Secret.

For more details, read the Seznam.cz docs: https://vyvojari.seznam.cz/oauth

## Installation

Add to your `Gemfile`:

```ruby
gem 'omniauth-seznam-cz'
```

Then `bundle install`.

## Usage

Here's an example for adding the middleware to a Rails app in `config/initializers/omniauth.rb`:

```ruby
Rails.application.config.middleware.use OmniAuth::Builder do
  provider :seznam_cz, ENV['SEZNAM_CLIENT_ID'], ENV['SEZNAM_CLIENT_SECRET']
end
```

You can now access the OmniAuth Seznam.cz URL: `/auth/seznam_cz`

NOTE: While developing your application, if you change the scope in the initializer you will need to restart your app server.

## Configuration

You can configure several options, which you pass in to the `provider` method via a hash:

* `scope`: A comma-separated list of permissions you want to request from the user.

* `redirect_uri`: Override the redirect_uri used by the gem.

## Auth Hash

Here's an example of an authentication hash available in the callback by accessing `request.env['omniauth.auth']`:

```ruby
{
  "provider" => "seznam_cz",
  "uid" => "100000000000000000000",
  "info" => {
    "name" => "John Smith",
    "email" => "john@example.com",
    "first_name" => "John",
    "last_name" => "Smith",
    "image" => "https://lh4.googleusercontent.com/photo.jpg",
    "urls" => {
      "google" => "https://plus.google.com/+JohnSmith"
    }
  },
  "credentials" => {
    "token" => "TOKEN",
    "refresh_token" => "REFRESH_TOKEN",
    "expires_at" => 1496120719,
    "expires" => true
  }
}
```

## License

Copyright (c) 2018 by Jan Sterba

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
