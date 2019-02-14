describe PiiSafeSchema::Notify do
  let(:columns) { PiiSafeSchema::PiiColumn.all }

  describe 'development' do
    it 'should print warnings' do
      columns.each do |c|
        expect(PiiSafeSchema::Notify::StdOut).to(receive(:deliver).with(c))
      end
      PiiSafeSchema::Notify.notify(columns)
    end
  end

  describe 'production' do
    before do
      Rails.env = 'production'
    end

    it 'send warnings to datadog' do
      columns.each do |c|
        expect(PiiSafeSchema::Notify::DataDog).to(receive(:deliver).with(c))
      end
      PiiSafeSchema::Notify.notify(columns)
    end
  end
end
