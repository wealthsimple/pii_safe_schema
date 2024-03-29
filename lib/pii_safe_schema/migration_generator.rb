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
        generator = ActiveRecord::Generators::MigrationGenerator.new(
          ["change_comments_in_#{table}"],
        )
        generated_lines = generate_migration_lines(table, columns)
        migration_file = generator.create_migration_file
        file_lines = File.read(migration_file).split("\n")
        change_line = file_lines.find_index { |i| i.include?('def change') }
        new_contents = file_lines[0..change_line] + generated_lines + file_lines[change_line + 1..]

        File.open(migration_file, 'w') do |f|
          f.write(new_contents.join("\n"))
          f.write("\n")
        end
        migration_file
      end

      def generate_migration_lines(table, columns)
        migration_lines = columns.map do |c|
          "#{' ' * (safety_assured? ? 6 : 4)}" \
            "change_column :#{table}, :#{c.column.name}, :#{c.column.type}, " \
            "comment: \'#{c.suggestion.to_json}\'" \
        end
        wrap_in_safety_assured(migration_lines)
      end

      def wrap_in_safety_assured(migration_lines)
        return migration_lines unless safety_assured?

        ["#{' ' * 4}safety_assured do", *migration_lines, "#{' ' * 4}end"]
      end

      def safety_assured?
        defined?(StrongMigrations)
      end
    end
  end
end
