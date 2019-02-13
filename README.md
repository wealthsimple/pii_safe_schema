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




