describe PiiSafeSchema::Notify::DataDog do
  let(:pii_column) { PiiSafeSchema::PiiColumn.all.last }

  describe '.deliver' do
    subject(:deliver) { described_class.deliver(pii_column) }

    let(:datadog_client) { instance_double('DatadogClient') }
    let(:env) { 'production' }

    before do
      Rails.env = env
      allow(datadog_client).to receive(:event)
      PiiSafeSchema.configure do |config|
        config.datadog_client = datadog_client
      end
    end

    context 'when unknown env' do
      let(:env) { 'banana' }

      it 'does not call datadog client' do
        deliver
        expect(datadog_client).not_to have_received(:event)
      end
    end

    context 'when client is nil' do
      let(:datadog_client) { nil }

      it 'does nothing' do
        expect(deliver).to eq(nil)
      end
    end

    it 'calls configured datadog client with expected arguments' do
      deliver
      expect(datadog_client).to have_received(:event).with(
        'PII Annotation Warning',
        "column #{pii_column.table}.#{pii_column.column.name} is not annotated",
        msg_title: 'Unannotated PII Column',
        alert_type: 'warning',
      ).once
    end
  end
end
