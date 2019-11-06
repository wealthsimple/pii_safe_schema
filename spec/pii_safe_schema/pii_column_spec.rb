describe PiiSafeSchema::PiiColumn do
  let(:annotations) { PiiSafeSchema::Annotations::COLUMNS }

  describe '.all' do
    let(:pii_columns) { described_class.all }

    before do
      PiiSafeSchema.configure { |config| config.ignore = {} }
    end

    it 'returns users.name' do
      assert_column_presence_and_suggestion(:users, 'name')
    end

    it 'does not return users.first_name' do
      refute_column_presence(:users, 'first_name')
    end

    it 'returns users.last_name' do
      assert_column_presence_and_suggestion(:users, 'last_name', annotation_type: :name)
    end

    it 'returns users.email' do
      assert_column_presence_and_suggestion(:users, 'email')
    end

    it 'returns users.phone' do
      assert_column_presence_and_suggestion(:users, 'phone')
    end

    it 'returns users.ip_address' do
      assert_column_presence_and_suggestion(:users, 'ip_address')
    end

    it 'returns users.latitude' do
      assert_column_presence_and_suggestion(:users, 'latitude', annotation_type: :geolocation)
    end

    it 'returns users.longitude' do
      assert_column_presence_and_suggestion(:users, 'longitude', annotation_type: :geolocation)
    end

    it 'returns social_insurance_number' do
      assert_column_presence_and_suggestion(:users, 'sin', annotation_type: :sensitive_data)
      assert_column_presence_and_suggestion(
        :users,
        'social_insurance_number',
        annotation_type: :sensitive_data,
      )
    end

    it 'does not return business' do
      refute_column_presence(:users, 'business')
    end

    it 'returns sample_ignore_table.phone' do
      assert_column_presence_and_suggestion(:sample_ignore_table, 'phone')
    end

    it 'returns street_name, street_number, and unit_number' do
      assert_column_presence_and_suggestion(:addresses, 'street_number', annotation_type: :address)
      assert_column_presence_and_suggestion(:addresses, 'street_name', annotation_type: :address)
      assert_column_presence_and_suggestion(:addresses, 'unit_number', annotation_type: :address)
    end

    it 'returns postal_code' do
      assert_column_presence_and_suggestion(:addresses, 'postal_code')
    end

    it 'returns encrypted_postal_code' do
      assert_column_presence_and_suggestion(
        :addresses,
        'encrypted_postal_code',
        annotation_type: :encrypted_data,
      )
    end

    it 'does not return country or city' do
      refute_column_presence(:addresses, 'country')
      refute_column_presence(:addresses, 'city')
    end

    it 'returns the correct annotation type for encrypted columns' do
      assert_column_presence_and_suggestion(
        :users,
        'encrypted_sin',
        annotation_type: :encrypted_data,
      )
    end

    it 'does not return ignored columns' do
      PiiSafeSchema.configure do |config|
        config.ignore = { sample_ignore_table: [:phone] }
      end
      refute_column_presence(:sample_ignore_table, 'phone')
    end

    it 'does not return columns from ignored tables' do
      PiiSafeSchema.configure do |config|
        config.ignore = { sample_ignore_table: :* }
      end
      refute_column_presence(:sample_ignore_table, 'phone')
    end
  end

  describe '.from_column_name' do
    subject(:from_column_name) do
      described_class.from_column_name(table: table, column: column, suggestion: suggestion)
    end

    let(:table) { 'users' }
    let(:column) { 'landline' }
    let(:suggestion) { PiiSafeSchema::Annotations.comment(:phone) }

    it do
      expect(from_column_name).to have_attributes(
        table: :users,
        column: 'landline',
        suggestion: suggestion,
      )
    end

    it { expect(from_column_name).to be_an_instance_of(described_class) }

    context 'when table doesnt exist' do
      let(:table) { 'banana' }

      it { expect { from_column_name }.to raise_error(ActiveRecord::StatementInvalid) }
    end

    context 'when column doesnt exist' do
      let(:column) { 'banana' }

      it do
        expect { from_column_name }.to raise_error(
          PiiSafeSchema::InvalidColumnError,
          'column "banana" does not exist for table "users"',
        )
      end
    end
  end

  describe '#recommended_comment' do
    subject(:recommended_comment) do
      described_class.recommended_comment(column)
    end

    let(:column) { instance_double(ActiveRecord::ConnectionAdapters::Column) }

    context 'when encrypted column' do
      before do
        allow(described_class).to receive(:apply_encrypted_recommendation?).and_return(true)
      end

      it { expect(recommended_comment).to eq(pii: { obfuscate: 'null_obfuscator' }) }

      it do
        recommended_comment
        expect(described_class).to have_received(:apply_encrypted_recommendation?).with(column)
      end
    end

    context 'when recommendable column' do
      before do
        allow(described_class).to receive(:apply_encrypted_recommendation?).and_return(false)
        allow(described_class).to receive(:apply_recommendation?).and_return(true)
      end

      it { expect(recommended_comment).to eq(pii: { obfuscate: 'email_obfuscator' }) }

      it do
        _, first_annotation_entry_info = annotations.first

        recommended_comment
        expect(described_class).to have_received(:apply_recommendation?).with(
          column,
          first_annotation_entry_info,
        )
      end
    end

    context 'when regular column' do
      before do
        allow(described_class).to receive(:apply_encrypted_recommendation?).and_return(false)
        allow(described_class).to receive(:apply_recommendation?).and_return(false)
      end

      it { expect(recommended_comment).to eq(nil) }
    end
  end

  describe '#apply_recommendation?' do
    subject(:apply_recommendation) do
      described_class.apply_recommendation?(column, pii_info)
    end

    let(:pii_info) { annotations[:postal_code] }
    let(:column) do
      instance_double(
        ActiveRecord::ConnectionAdapters::Column,
        name: column_name,
        comment: 'blaaahhh',
      )
    end

    context 'when matching name' do
      let(:column_name) { 'postal_code' }

      it { expect(apply_recommendation).to eq(true) }

      context 'when contains /encrypted/' do
        let(:column_name) { 'encrypted_postal_code' }

        it { expect(apply_recommendation).to eq(false) }
      end
    end

    context 'when not matching name' do
      let(:column_name) { 'banana' }

      it { expect(apply_recommendation).to eq(false) }
    end
  end

  describe '#encrypted?' do
    subject(:encrypted) { described_class.encrypted?(column) }

    let(:column) { instance_double(ActiveRecord::ConnectionAdapters::Column, name: column_name) }

    context 'when column name "foobar"' do
      let(:column_name) { 'foobar' }

      it { expect(encrypted).to eq(false) }
    end

    context 'when column name "postal_code"' do
      let(:column_name) { 'postal_code' }

      it { expect(encrypted).to eq(false) }
    end

    context 'when column name "encrypted"' do
      let(:column_name) { 'encrypted' }

      it { expect(encrypted).to eq(true) }
    end

    context 'when column name "encrypted_foobar"' do
      let(:column_name) { 'encrypted_foobar' }

      it { expect(encrypted).to eq(true) }
    end

    context 'when column name "foobar_encrypted"' do
      let(:column_name) { 'foobar_encrypted' }

      it { expect(encrypted).to eq(true) }
    end

    context 'when column name "foo_encrypted_bar"' do
      let(:column_name) { 'foo_encrypted_bar' }

      it { expect(encrypted).to eq(true) }
    end
  end

  describe '#apply_encrypted_recommendation?' do
    subject(:apply_encrypted_recommendation) do
      described_class.apply_encrypted_recommendation?(column)
    end

    let(:column) do
      instance_double(
        ActiveRecord::ConnectionAdapters::Column,
        comment: column_comment,
      )
    end
    let(:column_comment) { 'foobar' }

    context 'when encrypted? true' do
      before { allow(described_class).to receive(:encrypted?).and_return(true) }

      it do
        apply_encrypted_recommendation
        expect(described_class).to have_received(:encrypted?).with(column)
      end

      context 'when comment matches' do
        let(:column_comment) { annotations[:encrypted_data][:comment].to_json }

        it { expect(apply_encrypted_recommendation).to eq(false) }
      end

      context 'when comment doesnt match' do
        let(:column_comment) { 'foobar' }

        it { expect(apply_encrypted_recommendation).to eq(true) }
      end
    end

    context 'when encrypted? false' do
      before { allow(described_class).to receive(:encrypted?).and_return(false) }

      it { expect(apply_encrypted_recommendation).to eq(false) }

      it do
        apply_encrypted_recommendation
        expect(described_class).to have_received(:encrypted?).with(column)
      end
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
