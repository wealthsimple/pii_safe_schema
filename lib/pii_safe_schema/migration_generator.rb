module PiiSafeSchema
  module MigrationGenerator
    class << self
      def generate_migrations(pii_columns)
        pii_columns.group_by(&:table).map do |table, columns|
          generate_migration_for(table, columns)
        end
      end

      private

      def generate_migration_for(table, columns)
        generator = ActiveRecord::Generators::MigrationGenerator.new(["change_comments_in_#{table}"])
        generated_lines = generate_migration_lines(table, columns)
        migration_file = generator.create_migration_file
        file_lines = File.open(migration_file, 'r').read.split("\n")
        change_line = file_lines.find_index { |i| /def change/.match(i) }
        new_contents = file_lines[0..change_line] + generated_lines + file_lines[change_line + 1..-1]

        File.open(migration_file, 'w') do |f|
          f.write(new_contents.join("\n"))
        end
        migration_file
      end

      def generate_migration_lines(table, columns)
        safety_assured = defined?(StrongMigrations)
        columns.map do |c|
          "    #{'safety_assured {' if safety_assured}"\
          "change_column :#{table}, :#{c.column.name}, :#{c.column.type}, "\
          "comment: \'#{c.suggestion.to_json}\'"\
          "#{'}' if safety_assured}"
        end
      end
    end
  end
end
