TestMigration = ActiveRecord::Migration[ActiveRecord.version.to_s.to_f]

# rubocop:disable Metrics/MethodLength, Metrics/AbcSize
class CreateTables < TestMigration
  def change
    create_table 'users' do |t|
      t.string :name
      t.string :first_name
      t.string :last_name
      t.string :email
      t.string :phone
      t.string :ip_address
      t.float :latitude
      t.float :longitude
      t.string :social_insurance_number
      t.string :encrypted_sin
      t.string :sin
      t.string :business
    end

    create_table 'addresses' do |t|
      t.string :street_number
      t.string :street_name
      t.string :unit_number
      t.string :city
      t.string :postal_code
      t.string :encrypted_postal_code
      t.string :country
    end

    create_table 'schema_migrations' do |t|
      t.string :name
    end

    create_table 'ar_internal_metadata' do |t|
      t.string :name
    end

    create_table 'sample_ignore_table' do |t|
      t.string :phone
    end
  end
end
# rubocop:enable Metrics/MethodLength, Metrics/AbcSize
