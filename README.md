# PII Safe Schema [![CircleCI](https://circleci.com/gh/wealthsimple/pii_safe_schema.svg?style=svg)](https://circleci.com/gh/wealthsimple/pii_safe_schema)

Schema migration tool for checking and adding comments on *Personally Identifiable Information* (PII) columns in Rails.

Specifically, this gem serves a few functions:

* Warning you when you might be missing an annotation on a column
* Auto generating your migrations for you
* Customizable actions through Datadog Events if there are remaining unannotated columns. E.g. alerting your Security Team

## Why

Data privacy is an ever increasing concern for users, especially if your project or business is in sensitive industries like healthcare or finance.

Having structured metadata on the database level of your application ensures Business Intelligence consumers (I.e. Periscope Data) can appropriately filter or obfuscate columns that personally identify your users without impacting business needs.

In other words, as your attack surface increases, the risk of user PII disclosure remains the same.

In your data warehousing pipeline, consume the structured metadata this gem provides in order to maintain the privacy of your users.

## Getting Started

Add your Rails project Gemfile:

```ruby
gem 'pii_safe_schema'
```

Then, to your `application.rb`

```ruby
config.after_initialize do
  PiiSafeSchema.activate!
end
```

If you want to ignore certain columns, add the following initializer:

```ruby
# initializers/pii_safe_schema.rb

PiiSafeSchema.configure do |config|
  config.ignore = {
    some_table:       :*,                       # ignore the whole table
    some_other_table: [:column_1, :column_2]    # just those columns
  }
end
```

## Generating Comment Migrations

```ruby
rake pii_safe_schema:generate_migrations
```

This will generate one migration file for each table that should be commented.
it will create a comment field for each column that it warns you about when you start a rails server or console.

## Credits

Thanks to [Alexi Garrow](https://github.com/AGarrow) for the original code.

## Contributing

Everyone is encouraged to help improve this project. Here are a few ways you can help:

* [Report bugs](https://github.com/wealthsimple/pii_safe_schema/issues)
* Fix bugs and [submit pull requests](https://github.com/wealthsimple/pii_safe_schema/pulls)
* Write, clarify, or fix documentation
* Suggest or add new features

To get started with development and testing:

```bash
git clone https://github.com/wealthsimple/pii_safe_schema.git
cd pii_safe_schema
bundle install
bundle exec rspec
```