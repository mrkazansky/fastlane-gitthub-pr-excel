require 'fastlane/action'
require 'axlsx' 
require_relative '../helper/gitthub_pr_excel_helper'

module Fastlane
  module Actions
    class GitthubPrExcelAction < Action
      def self.run(params)
        UI.message("The gitthub_pr_excel plugin is working!")
        branch = params[:branch_name]
        branch_name = branch.gsub("/","_")
        response = Actions::GithubApiAction.run(
          server_url: "https://api.github.com",
          api_token: params[:git_token],
          http_method: "GET",
          path: "/search/issues?q=repo:belivetech/#{params[:repo_name]}+base:#{branch}+is:pull-request+is:merged&per_page=100",
        )
        prs = response[:json]["items"].sort_by { |obj| Date.parse(obj["updated_at"].to_s.strip).to_s}.map { |item| { :title => item["title"].strip, :url => item["html_url"], :date => Date.parse(item["updated_at"]).strftime("%a, %d %b %Y").to_s} }.group_by{|h| h[:date]}

        p = Axlsx::Package.new
        wb = p.workbook

        style = wb.styles
        style_release = style.add_style bg_color: '45818e', fg_color: 'FF', sz: 12
        style_review = style.add_style bg_color: '6aa84f', fg_color: 'FF', sz: 12, border: { style: :thin, color: '00' }
        border_black = style.add_style border: { style: :thin, color: '00' }
        style_header = style.add_style bg_color: 'efefef'
        
        wb.add_worksheet(name: "#{branch_name}") do |sheet|
          sheet.add_row ['Release Date: ' << Date.today.strftime("%b xx %Y").to_s, ''], style: [style_release, style_release]
          sheet.add_row ['Review Date: ' << Date.today.strftime("%b %d %Y").to_s, ''], style: [style_release, style_release]
          sheet.merge_cells('A1:B1')
          sheet.merge_cells('A2:B2')
          sheet.add_row ['']
          sheet.add_row ['Approval Status', ''], style: [style_review, style_review]
          sheet.add_row ['Approved By (1)', params[:reviewer]], style: [border_black, border_black]
          sheet.add_row ['Approved By (2)', ''], style: [border_black, border_black]
          sheet.add_row ['']
          sheet.add_row ['']
          row = 8
          prs.each do |key, array|
            row += 1
            sheet.add_row [key], style: [style_header]     
            array.each_with_index {|item, index| 
              row += 1
              sheet.add_row [item[:title]]            
              cell = "A#{row}"
              sheet.add_hyperlink location: item[:url], ref: cell
            }
          end
        end
        
        p.serialize "fastlane/#{params[:file_name]}.xlsx"

      end

      def self.description
        "Exporting PR list of github to excel file"
      end

      def self.authors
        ["Bình Phạm"]
      end

      def self.return_value
      end

      def self.details
        "Exporting PR list of github to excel file"
      end

      def self.available_options
        [
         FastlaneCore::ConfigItem.new(key: :git_token,
                                       env_name: 'GIT_TOKEN',
                                       description: 'Github personal token',
                                       optional: false,
                                       type: String,
                                       verify_block: proc do |value|
                                         UI.user_error!("No token given") unless value and !value.empty?
                                       end),
        FastlaneCore::ConfigItem.new(key: :repo_name,
                                       env_name: 'REPO_NAME',
                                       description: 'Repository name',
                                       optional: false,
                                       type: String,
                                       verify_block: proc do |value|
                                         UI.user_error!("No repo name given") unless value and !value.empty?
                                       end),
        FastlaneCore::ConfigItem.new(key: :branch_name,
                                        env_name: 'REPO_NAME',
                                        description: 'Branch name',
                                        optional: false,
                                        type: String,
                                        verify_block: proc do |value|
                                          UI.user_error!("No branch name given") unless value and !value.empty?
                                        end),                                       
        FastlaneCore::ConfigItem.new(key: :reviewer,
                                        env_name: 'REVIEWER',
                                        description: 'Branch name',
                                        optional: false,
                                        type: String,
                                        verify_block: proc do |value|
                                          UI.user_error!("No reviewer name given") unless value and !value.empty?
                                        end),
        FastlaneCore::ConfigItem.new(key: :file_name,
                                          env_name: 'EXPORT_FILE_NAME',
                                          description: 'Export file name',
                                          optional: false,
                                          type: String,
                                          verify_block: proc do |value|
                                            UI.user_error!("No file name given") unless value and !value.empty?
                                          end)
        ]
      end

      def self.is_supported?(platform)
        true
      end
    end
  end
end
