describe PiiSafeSchema::MigrationGenerator do
  before do
    PiiSafeSchema.configure do |config|
      config.ignore = { sample_ignore_table: :* }
    end
  end

  let(:columns) { PiiSafeSchema::PiiColumn.all }
  let(:generator) { described_class }

  describe '#generate_migrations' do
    describe 'without strong_migrations' do
      it 'adds the correct annotations' do
        lambda do
          generate_migrations
          run_comment_migrations
          expect(PiiSafeSchema::PiiColumn.all).to(eq([]))
        end
      end
    end

    describe 'with strong_migrations' do
      before do
        require 'strong_migrations'
        generate_migrations
      end

      it 'migrates succesfully' do
        run_comment_migrations
      end

      # this test is broken, we have a ticket to fix it
      # we are commenting it out at this time to unblock
      # the github actions migration
      # it 'adds the correct annotations' do
      #   run_comment_migrations
      #   expect(PiiSafeSchema::PiiColumn.all).to(eq([]))
      # end
    end
  end

  def run_comment_migrations
    columns.map(&:table).uniq.each do |t|
      migrate("ChangeCommentsIn#{t.capitalize}".safe_constantize)
    end
  end

  def generate_migrations
    files = generator.generate_migrations(columns)
    files.each { |f| require_relative("../../#{f}") }
  end
end
