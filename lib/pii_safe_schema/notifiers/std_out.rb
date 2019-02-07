module PiiSafeSchema::Notify::StdOut
  def self.deliver(pii_column)
    puts message(pii_column)
  end

  def self.message(pii_column)
    "annotation recommended on #{pii_column.table}.#{pii_column.column.name}: #{pii_column.suggestion}"
  end
end
