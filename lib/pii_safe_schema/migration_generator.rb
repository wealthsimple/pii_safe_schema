module PiiSafeSchema::MigrationGenerator
  def self.generate_migrations(pii_columns)
    pii_columns.group_by(&:table).map do |table, columns|
      generate_migration_for(table, columns)
    end
  end

  private

  def self.generate_migration_for(table, columns)
    generator = ActiveRecord::Generators::MigrationGenerator.new(["change_comments_in_#{table}"])
    # generator.destination_root = ENV["DESTINATION_ROOT"] if ENV["DESTINATION_ROOT"]
    generated_lines = columns.map do |c|
      "#{' ' * 4}change_column :#{table}, :#{c.column.name}, :#{c.column.type}, comment: \'#{c.suggestion.to_json}\'"
    end

    migration_file = generator.create_migration_file
    file_lines = File.open(migration_file, 'r').read.split("\n")
    change_line = file_lines.find_index { |i| /def change/.match(i) }
    new_contents = file_lines[0..change_line] + generated_lines + file_lines[change_line + 1..-1]

    File.open(migration_file, 'w') do |f|
      f.write(new_contents.join("\n"))
    end
    migration_file
  end
end
