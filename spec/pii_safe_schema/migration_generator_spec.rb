require 'spec_helper'
require 'rake'
describe PiiSafeSchema::MigrationGenerator do
  before do
    PiiSafeSchema.configure do |config|
      config.ignore = { sample_ignore_table: :* }
    end
    generate_user_migration
  end
  let(:columns) { PiiSafeSchema::PiiColumn.all }
  let(:generator) { PiiSafeSchema::MigrationGenerator }
  describe "#generate_migrations" do
    it "should create valid migrations" do
      expect{ migrate(ChangeCommentsInUsers) }.to_not(raise_error)
    end

    it "should add the correct annotations" do
      migrate(ChangeCommentsInUsers)
      expect(PiiSafeSchema::PiiColumn.all).to(eq([]))
    end
  end

  def generate_user_migration
    f = generator.generate_migrations(columns)
    require_relative("../../#{f.first}")
  end
end
