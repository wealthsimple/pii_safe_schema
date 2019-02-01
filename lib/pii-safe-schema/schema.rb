class PiiSafeSchema::Schema
  include Singleton

  def hash
    @hash ||= get_hash
  end

  def dump
    @dump ||= get_dump
  end

  private

    def get_dump
      f = File.open('tmp.txt', 'w') do |file|
        ActiveRecord::SchemaDumper.dump(
          connection = ActiveRecord::Base.connection,
          stream = file
        )
      end
      File.open('tmp.txt', 'r') { |f| return f.read }
    end

    def get_hash
      table_blocks.map { |tb| table_hash_from_string(tb) }.compact.to_h
    end

    def table_hash_from_string(string_block)
      block_lines = string_block.split("\n")
      table_name = /^ "(\w*)"/.match(block_lines.shift)&.captures&.first
      return nil unless table_name
      columns = block_lines.map do |bl|
        column_name, type = parse_column(bl) 
        { column_name => { "type" => type } }
      end.compact.inject(&:merge)
      [table_name, columns]
    end

    def parse_column(column)
      type = /\W\w\.(\w*)/.match(column)&.captures&.first
      column_name = /\"(.*)\",/.match(column)&.captures&.first
      # comment = //
      return nil if type == "index" || column_name.blank?
      [column_name, type]
    end

    def table_blocks
      dump.split(/create_table|end$/)[1..-1]
    end
end
