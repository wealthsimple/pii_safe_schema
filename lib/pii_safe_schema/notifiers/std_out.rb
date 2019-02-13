module PiiSafeSchema::Notify::StdOut
  def self.deliver(pii_column)
    puts message(pii_column) if %w[development test].include?(Rails.env)
  end

  def self.message(pii_column)
    <<~HEREDOC
      annotation recommended on column:
      #{pii_column.table}.#{pii_column.column.name}: #{pii_column.suggestion}
      run `rake pii_safe_schema:generate_migrations`
      to generate all necessary annotation migrations.
    HEREDOC
  end
end
