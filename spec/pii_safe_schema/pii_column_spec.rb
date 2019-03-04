describe PiiSafeSchema::PiiColumn do
  let(:annotations) { PiiSafeSchema::Annotations::COLUMNS }
  describe '#all' do
    let(:pii_columns) { PiiSafeSchema::PiiColumn.all }
    before do
      PiiSafeSchema.configure { |config| config.ignore = {} }
    end

    it 'should return users.name' do
      assert_column_presence_and_suggestion(:users, 'name')
    end

    it 'should not return users.first_name' do
      refute_column_presence(:users, 'first_name')
    end

    it 'should return users.last_name' do
      assert_column_presence_and_suggestion(:users, 'last_name', annotation_type: :name)
    end

    it 'should return users.email' do
      assert_column_presence_and_suggestion(:users, 'email')
    end

    it 'should return users.phone' do
      assert_column_presence_and_suggestion(:users, 'phone')
    end

    it 'should return users.ip_address' do
      assert_column_presence_and_suggestion(:users, 'ip_address')
    end

    it 'should return users.latitude' do
      assert_column_presence_and_suggestion(:users, 'latitude', annotation_type: :geolocation)
    end

    it 'should return users.longitude' do
      assert_column_presence_and_suggestion(:users, 'longitude', annotation_type: :geolocation)
    end

    it 'should return social_insurance_number' do
      assert_column_presence_and_suggestion(:users, 'sin', annotation_type: :sensitive_data)
      assert_column_presence_and_suggestion(:users, 'social_insurance_number', annotation_type: :sensitive_data)
    end

    it 'should not return business' do
      refute_column_presence(:users, 'business')
    end

    it 'should return sample_ignore_table.phone' do
      assert_column_presence_and_suggestion(:sample_ignore_table, 'phone')
    end

    it 'should return street_name, street_number, and unit_number' do
      assert_column_presence_and_suggestion(:addresses, 'street_number', annotation_type: :address)
      assert_column_presence_and_suggestion(:addresses, 'street_name', annotation_type: :address)
      assert_column_presence_and_suggestion(:addresses, 'unit_number', annotation_type: :address)
    end

    it 'should return postal_code' do
      assert_column_presence_and_suggestion(:addresses, 'postal_code')
    end

    it 'should return encrypted_postal_code' do
      assert_column_presence_and_suggestion(:addresses, 'encrypted_postal_code', annotation_type: :encrypted_data)
    end

    it 'should not return country or city' do
      refute_column_presence(:addresses, 'country')
      refute_column_presence(:addresses, 'city')
    end

    it 'should return the correct annotation type for encrypted columns' do
      assert_column_presence_and_suggestion(:users, 'encrypted_sin', annotation_type: :encrypted_data)
    end

    it 'should not return ignored columns' do
      PiiSafeSchema.configure do |config|
        config.ignore = { sample_ignore_table: [:phone] }
      end
      refute_column_presence(:sample_ignore_table, 'phone')
    end

    it 'should not return columns from ignored tables' do
      PiiSafeSchema.configure do |config|
        config.ignore = { sample_ignore_table: :* }
      end
      refute_column_presence(:sample_ignore_table, 'phone')
    end
  end

  def assert_column_presence_and_suggestion(table, column_name, annotation_type: nil)
    annotation_type = annotation_type.presence || column_name.to_sym
    pii_column = find_column(pii_columns, table, column_name)
    expect(pii_column).to be_truthy
    expect(pii_column.suggestion).to(
      eq(annotations[annotation_type][:comment]),
    )
  end

  def refute_column_presence(table, column_name)
    pii_column = find_column(pii_columns, table, column_name)
    expect(pii_column).to be_nil
  end
end
