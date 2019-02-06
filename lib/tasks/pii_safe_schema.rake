namespace :pii_safe_schema do
  task generate_migrations: :environment do
    PiiSafeSchema.generate_migrations
  end
end
