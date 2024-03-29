describe PiiSafeSchema::Configuration do
  let(:configuration) { PiiSafeSchema.configuration }

  describe 'ignore_tables' do
    it 'returns ignored tables' do
      PiiSafeSchema.configure do |config|
        config.ignore = { sample_ignore_table: :* }
      end

      expect(PiiSafeSchema.configuration.ignore_tables).to(
        include('sample_ignore_table'),
      )
    end

    it 'does not return tables with specific ignored columns' do
      PiiSafeSchema.configure do |config|
        config.ignore = { sample_ignore_table: [:phone] }
      end

      expect(PiiSafeSchema.configuration.ignore_tables).not_to(
        include('sample_ignore_table'),
      )
    end

    it 'includes defaults' do
      expect(described_class.new.ignore_tables).to(
        eq(%w[schema_migrations ar_internal_metadata]),
      )
    end
  end

  describe 'ignore_columns' do
    it 'returns {} by default' do
      expect(described_class.new.ignore_columns).to(eq({}))
    end

    it 'returns a hash with {table_name => [column_names]}' do
      ignore_columns = { sample_ignore_table: [:phone] }
      PiiSafeSchema.configure do |config|
        config.ignore = ignore_columns
      end
      expect(PiiSafeSchema.configuration.ignore_columns).to(eq(ignore_columns))
    end

    it 'does not return wholly ignored tables' do
      PiiSafeSchema.configure do |config|
        config.ignore = { sample_ignore_table: :* }
      end
      expect(PiiSafeSchema.configuration.ignore_columns.keys).not_to(
        include(:sample_ignore_table),
      )
    end
  end

  describe 'configure' do
    describe 'invalid ignore params' do
      it 'rejects non-array values other than :*' do
        assert_raise_ignore_config_error({ sample_ignore_table: :phone })
      end

      it 'rejects an array of strings' do
        assert_raise_ignore_config_error({ sample_ignore_table: ['phone'] })
      end
    end

    describe 'invalid datadog_client' do
      it 'rejects objects without #event method' do
        assert_raise_datadog_client_config_error(Object.new)
      end
    end
  end

  def assert_raise_ignore_config_error(value)
    expect do
      PiiSafeSchema.configure do |config|
        config.ignore = value
      end
    end.to raise_error(PiiSafeSchema::ConfigurationError,
      /ignore must be a hash where the values are/)
  end

  def assert_raise_datadog_client_config_error(client)
    expect do
      PiiSafeSchema.configure do |config|
        config.datadog_client = client
      end
    end.to raise_error(PiiSafeSchema::ConfigurationError, /Datadog client must be implement/)
  end
end
