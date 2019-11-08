namespace :pii_safe_schema do
  task generate_migrations: :environment do
    PiiSafeSchema.print_help! if ARGV[2] == 'help'

    if ARGV.length == 1
      PiiSafeSchema.generate_migrations
    else
      additional_columns = PiiSafeSchema.parse_additional_columns(ARGV[1..])
      PiiSafeSchema.generate_migrations(additional_columns)
    end

    exit(0) # forces rake to stop after this and not assume args are tasks
  rescue ActiveRecord::StatementInvalid, PiiSafeSchema::InvalidColumnError => e
    raise e if e.class == ActiveRecord::StatementInvalid && e.cause.class != PG::UndefinedTable

    puts <<~HEREDOC
      Unable to generate PII annotation migration. Either the underlying table or column does not exist:

      #{e.message}

      Please create the table & columns first, running their migrations, before attempting to use the pii_safe_schema generator.
    HEREDOC

    exit(1) # forces rake to stop after this and not assume args are tasks
  end
end
