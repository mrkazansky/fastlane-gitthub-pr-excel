require 'fastlane_core/ui/ui'

module Fastlane
  UI = FastlaneCore::UI unless Fastlane.const_defined?("UI")

  module Helper
    class GitthubPrExcelHelper
      # class methods that you define here become available in your action
      # as `Helper::GitthubPrExcelHelper.your_method`
      #
      def self.show_message
        UI.message("Hello from the gitthub_pr_excel plugin helper!")
      end
    end
  end
end
