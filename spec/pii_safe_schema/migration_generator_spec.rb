describe PiiSafeSchema::MigrationGenerator do
  before do
    PiiSafeSchema.configure do |config|
      config.ignore = { sample_ignore_table: :* }
    end
  end
  let(:columns) { PiiSafeSchema::PiiColumn.all }
  let(:generator) { PiiSafeSchema::MigrationGenerator }
  describe '#generate_migrations' do
    describe 'without strong_migrations' do
      it 'should add the correct annotations' do
        -> do
          generate_user_migration
          migrate(ChangeCommentsInUsers)
          expect(PiiSafeSchema::PiiColumn.all).to(eq([]))
        end
      end
    end

    describe 'with strong_migrations' do
      before do
        require 'strong_migrations'
        generate_user_migration
      end

      it 'should migrate succesfully' do
        migrate(ChangeCommentsInUsers)
      end

      it 'should add the correct annotations' do
        migrate(ChangeCommentsInUsers)
        expect(PiiSafeSchema::PiiColumn.all).to(eq([]))
      end
    end
  end

  def generate_user_migration
    f = generator.generate_migrations(columns)
    require_relative("../../#{f.first}")
  end
end
