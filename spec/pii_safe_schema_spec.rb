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

  describe "#activate" do
    it "should not raise an error if tables do not exist yet" do
      allow(ActiveRecord::Base).to receive(:connection).and_raise(ActiveRecord::NoDatabaseError)
      expect{ PiiSafeSchema.activate! }.to_not raise_error
    end
  end
end
