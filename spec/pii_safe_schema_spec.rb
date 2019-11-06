# frozen_string_literal: true

require 'git'
require 'logger'

describe PiiSafeSchema do
  it 'has a version number' do
    expect(PiiSafeSchema::VERSION).not_to be nil
  end

  it 'has version been bumped' do
    git = Git.open('.', log: Logger.new(nil))

    skip if git.current_branch == 'master'

    master_version_file = git.show('origin/master', 'lib/pii_safe_schema/version.rb')
    master_version = master_version_file.match(/VERSION = ['"](.*)['"]/)[1]

    expect(Gem::Version.new(PiiSafeSchema::VERSION)).to be > Gem::Version.new(master_version)
  end

  describe ".activate!" do
    it "does not raise an error if tables do not exist yet" do
      allow(ActiveRecord::Base).to receive(:connection).and_raise(ActiveRecord::NoDatabaseError)
      expect { described_class.activate! }.not_to raise_error
    end
  end

  describe ".generate_migrations" do
    subject(:generate_migrations) { described_class.generate_migrations }

    let(:all_columns) do
      [
        instance_double(PiiSafeSchema::PiiColumn, table: 'foobars', column: 'col1'),
        instance_double(PiiSafeSchema::PiiColumn, table: 'foobars', column: 'col2'),
      ]
    end

    before do
      allow(PiiSafeSchema::MigrationGenerator).to receive(:generate_migrations).
        and_return('generate_migrations_return_value')
      allow(PiiSafeSchema::PiiColumn).to receive(:all).and_return(all_columns)
    end

    it do
      generate_migrations
      expect(PiiSafeSchema::MigrationGenerator).to have_received(:generate_migrations).
        with(all_columns)
    end

    it do
      generate_migrations
      expect(PiiSafeSchema::PiiColumn).to have_received(:all)
    end

    it { expect(generate_migrations).to eq('generate_migrations_return_value') }

    context 'when additional columns' do
      subject(:generate_migrations) { described_class.generate_migrations(additional) }

      let(:additional) do
        [
          instance_double(PiiSafeSchema::PiiColumn, table: 'foobars', column: 'add1'),
          instance_double(PiiSafeSchema::PiiColumn, table: 'foobars', column: 'add2'),
        ]
      end

      it do
        generate_migrations
        expect(PiiSafeSchema::MigrationGenerator).to have_received(:generate_migrations).
          with(all_columns + additional)
      end

      it do
        generate_migrations
        expect(PiiSafeSchema::PiiColumn).to have_received(:all)
      end

      it { expect(generate_migrations).to eq('generate_migrations_return_value') }
    end
  end

  describe ".parse_additional_columns" do
    subject(:parse_additional_columns) { described_class.parse_additional_columns(args) }

    let(:from_column_name_return_value) { instance_double(PiiSafeSchema::PiiColumn) }

    before do
      allow(described_class).to receive(:print_help!)
      allow(PiiSafeSchema::PiiColumn).to receive(:from_column_name).
        and_return(from_column_name_return_value)
    end

    context 'when malformed arg' do
      let(:args) { ['banana'] }

      it do
        parse_additional_columns
        expect(PiiSafeSchema::PiiColumn).not_to have_received(:from_column_name)
      end

      it do
        parse_additional_columns
        expect(described_class).to have_received(:print_help!)
      end

      it { expect(parse_additional_columns).to eq(nil) }
    end

    context 'when no args' do
      let(:args) { [] }

      it do
        parse_additional_columns
        expect(PiiSafeSchema::PiiColumn).not_to have_received(:from_column_name)
      end

      it do
        parse_additional_columns
        expect(described_class).not_to have_received(:print_help!)
      end

      it { expect(parse_additional_columns).to eq([]) }
    end

    context 'when args are "users:landline:phone signatures:signatories:name"' do
      let(:args) { ['users:landline:phone', 'signatures:signatories:name'] }

      it do
        parse_additional_columns
        expect(PiiSafeSchema::PiiColumn).to have_received(:from_column_name).with(
          table: 'signatures',
          column: 'signatories',
          suggestion: PiiSafeSchema::Annotations.comment('name'),
        )
      end

      it do
        parse_additional_columns
        expect(PiiSafeSchema::PiiColumn).to have_received(:from_column_name).with(
          table: 'users',
          column: 'landline',
          suggestion: PiiSafeSchema::Annotations.comment('phone'),
        )
      end

      it do
        parse_additional_columns
        expect(described_class).not_to have_received(:print_help!)
      end

      it do
        expect(parse_additional_columns).to eq([
          from_column_name_return_value,
          from_column_name_return_value,
        ])
      end

      context 'when annotation type is "banana"' do
        let(:args) { ['users:landline:banana'] }

        it do
          parse_additional_columns
          expect(PiiSafeSchema::PiiColumn).not_to have_received(:from_column_name)
        end

        it do
          parse_additional_columns
          expect(described_class).to have_received(:print_help!)
        end

        it { expect(parse_additional_columns).to eq(nil) }
      end
    end
  end
end
