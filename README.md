# Gawk

Print Google Analytics reports inside your terminal.

## Getting Started

### Installation

Add this line to your application's Gemfile:

```ruby
gem 'gawk'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install gawk

### Enable Google Analytics Reporting API

Gawk uses the [Google Analytics Reporting API v4](https://developers.google.com/analytics/devguides/reporting/core/v4/) to retrieve the reports. You need to enable the Reporting API in Google's API Console with the following steps:

1. Open the [Library page](https://console.developers.google.com/apis/library) in the API Console.
2. Select the project associated with your application. Create a project if you do not have one already.
3. Use the **Library page** to find the Google Analytics Reporting API. Click on the API and enable it for your project.

### Create Authorization Credentials

Gawk uses OAuth 2.0 to access the Google Analytics Reporting API. You need to create the required credentials with the following steps:

1. Open the [Credentials page](https://console.developers.google.com/apis/credentials) in the API Console.
2. Click **Create credentials > OAuth client ID**.
3. Complete the form.
4. Use the **Credentials page** to download the credentials as JSON.
5. Save the downloaded credentials as `client_secrets.json` in your project's root.

**Attention**: Gawk stores OAuth 2.0 tokens inside `tokens.yaml`. You might want to add both `client_secrets.json` and `tokens.yaml` into your project's `.gitignore`.

## Usage

To start using Gawk, you need to add the Gawk config file `.gawk.yaml` into your project root.

After that, you can print all your reports:

    $ bundle exec gawkat

Or, print a specific report using the report identifier:

    $ bundle exec gawkat mobile_sessions

### .gawk.yaml

You should use the following format when constructing a `.gawk.yaml` file:

```yaml
# Unique identifier for your report
foobar:
    table:
        # Name of your report table
        name: STRING
    request:
         # The View ID you want to use
        view_id: STRING
        # List of date ranges (max. 2 ranges)
        date_ranges:
            - start_date: DATE
              end_date: DATE
            - start_date: DATE
              end_date: DATE
        # List of reporting dimensions
        dimensions:
            - STRING
        # List of reporting metrics
        metrics:
            - STRING
        # Optional filters
        filters_expression: STRING
```

All reports should have the same date ranges. If the reports don't share the same date ranges, you should only print them individually using the report identifer.

Here is a `.gawk.yaml` example that you can try out:

```yaml
hello:
  table:
    name: Hello, world!
  request:
    view_id: XXXX # Replace this with your View ID
    date_ranges:
      - start_date: 2018/06/01
        end_date: 2018/06/30
    dimensions:
      - ga:browser
    metrics:
      - ga:sessions
    filters_expression: ga:deviceCategory==mobile
```


If you don't know your View ID, you can find it here: https://ga-dev-tools.appspot.com/account-explorer/.

You can find a list of all the possible dimensions and metrics here: https://developers.google.com/analytics/devguides/reporting/core/dimsmets


##

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Testing

Run the tests:

```
rspec spec/gawk
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/jonaskay/gawk. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Gawk project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/gawk/blob/master/CODE_OF_CONDUCT.md).
