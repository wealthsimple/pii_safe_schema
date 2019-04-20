describe PiiSafeSchema::Notify::DataDog do
  let(:pii_column) { PiiSafeSchema::PiiColumn.all.last }

  describe '.deliver' do
    let(:datadog_client) { double('DatadogClient', event: 'foobar') }
    let(:env) { 'production' }

    before do
      Rails.env = env
      PiiSafeSchema.configure do |config|
        config.datadog_client = datadog_client
      end
    end

    subject { described_class.deliver(pii_column) }

    context 'when unknown env' do
      let(:env) { 'banana' }

      it 'does not call datadog client' do
        expect(datadog_client).not_to receive(:event)
        subject
      end
    end

    context 'when client is nil' do
      let(:datadog_client) { nil }

      it 'does nothing' do
        expect(subject).to eq(nil)
      end
    end

    it 'calls configured datadog client with expected arguments' do
      expect(datadog_client).to receive(:event).with(
        'PII Annotation Warning',
        "column #{pii_column.table}.#{pii_column.column.name} is not annotated",
        msg_title: 'Unannotated PII Column',
        alert_type: 'warning',
      ).once
      subject
    end
  end
end
