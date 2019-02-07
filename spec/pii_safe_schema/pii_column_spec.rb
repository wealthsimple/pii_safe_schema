require 'spec_helper'
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

    it 'should return sample_ignore_table.phone' do
      assert_column_presence_and_suggestion(:sample_ignore_table, 'phone')
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
