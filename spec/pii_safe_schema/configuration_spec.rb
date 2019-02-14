describe PiiSafeSchema::Configuration do
  let(:configuration) { PiiSafeSchema.configuration }

  describe 'ignore_tables' do
    it 'should return ignored tables' do
      PiiSafeSchema.configure do |config|
        config.ignore = { sample_ignore_table: :* }
      end

      expect(PiiSafeSchema.configuration.ignore_tables).to(
        include('sample_ignore_table'),
      )
    end

    it 'should not tables with specific ignored columns' do
      PiiSafeSchema.configure do |config|
        config.ignore = { sample_ignore_table: [:phone] }
      end

      expect(PiiSafeSchema.configuration.ignore_tables).not_to(
        include('sample_ignore_table'),
      )
    end

    it 'should include defaults' do
      expect(PiiSafeSchema::Configuration.new.ignore_tables).to(
        eq(%w[schema_migrations ar_internal_metadata]),
      )
    end
  end

  describe 'ignore_columns' do
    it 'should return {} by default' do
      expect(PiiSafeSchema::Configuration.new.ignore_columns).to(eq({}))
    end

    it 'should return a hash with {table_name => [column_names]}' do
      ignore_columns = { sample_ignore_table: [:phone] }
      PiiSafeSchema.configure do |config|
        config.ignore = ignore_columns
      end
      expect(PiiSafeSchema.configuration.ignore_columns).to(eq(ignore_columns))
    end

    it 'should not return wholly ignored tables' do
      PiiSafeSchema.configure do |config|
        config.ignore = { sample_ignore_table: :* }
      end
      expect(PiiSafeSchema.configuration.ignore_columns.keys).to_not(
        include(:sample_ignore_table),
      )
    end
  end

  describe 'configure' do
    describe 'invalid ignore params' do
      it 'should reject non-array values other than :*' do
        assert_raise_config_error({ sample_ignore_table: :phone })
      end

      it 'should reject an array of strings' do
        assert_raise_config_error({ sample_ignore_table: ['phone'] })
      end
    end
  end

  def assert_raise_config_error(ignore_value)
    expect do
      PiiSafeSchema.configure do |config|
        config.ignore = ignore_value
      end
    end.to raise_error(PiiSafeSchema::ConfigurationError)
  end
end
