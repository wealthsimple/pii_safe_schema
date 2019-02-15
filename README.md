## PiiSafeSchema

this gem serves a few functions:

* Warning you when you might be missing an annotation on a column
* auto generating your migrations for you
* alerting the security team through datadog events if there are remaining unannotated columns



### Getting Started

`gem 'pii-safe-schema'`

add the following to `application.rb`

```
config.after_initialize do
  PiiSafeSchema.activate!
end
```

if you want to ignore certain columns, add the following initializer:

```
# initializers/pii-safe-schema.rb

PiiSafeSchema.configure do |config|
  config.ignore = {
    some_table:       :*,                       # ignore the whole table
    some_other_table: [:column_1, :column_2]    # just those columns
  }
end
```

### Generating Comment Migrations

`rake pii_safe_schema:generate_migrations`

this will generate one migration file for each table that should be commented.
it will create a comment field for each column that it warns you about when you start a rails server or console.





