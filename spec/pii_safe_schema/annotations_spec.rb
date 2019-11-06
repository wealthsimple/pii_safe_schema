describe PiiSafeSchema::Annotations do
  describe '.comment' do
    subject(:comment) { described_class.comment(annotation_type) }

    let(:annotation_type) { :name }

    it { expect(comment).to eq(pii: { obfuscate: 'name_obfuscator' }) }

    context 'when string annotation' do
      let(:annotation_type) { 'name' }

      it { expect(comment).to eq(pii: { obfuscate: 'name_obfuscator' }) }
    end

    context 'when invalid annotation' do
      let(:annotation_type) { :foobar }

      it { expect(comment).to eq(nil) }
    end
  end
end
