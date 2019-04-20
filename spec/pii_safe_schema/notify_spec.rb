describe PiiSafeSchema::Notify do
  let(:columns) { PiiSafeSchema::PiiColumn.all }

  context 'when development' do
    it 'prints warnings' do
      columns.each do |c|
        allow(PiiSafeSchema::Notify::StdOut).to receive(:deliver).with(c)
      end
      described_class.notify(columns)
      columns.each do |c|
        expect(PiiSafeSchema::Notify::StdOut).to(have_received(:deliver).with(c))
      end
    end
  end

  context 'when production' do
    before do
      Rails.env = 'production'
    end

    it 'send warnings to datadog' do
      columns.each do |c|
        allow(PiiSafeSchema::Notify::DataDog).to(receive(:deliver).with(c))
      end
      described_class.notify(columns)
      columns.each do |c|
        expect(PiiSafeSchema::Notify::DataDog).to(have_received(:deliver).with(c))
      end
    end
  end
end
