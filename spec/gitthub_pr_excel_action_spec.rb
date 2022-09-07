describe Fastlane::Actions::GitthubPrExcelAction do
  describe '#run' do
    it 'prints a message' do
      expect(Fastlane::UI).to receive(:message).with("The gitthub_pr_excel plugin is working!")

      Fastlane::Actions::GitthubPrExcelAction.run(nil)
    end
  end
end
