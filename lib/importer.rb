# frozen_string_literal: true

# Convert WordPress to Markdown
module WordPressToMarkdown
  # The importer functionality
  class Importer
    require 'nokogiri'
    def initialize(input_file, output_dir)
      puts "about to convert #{input_file} to markdown and save to #{output_dir}"
    end

    def parse
      # doc = File.open(input_file) { |f| Nokogiri::XML(f) }
      # puts doc.xpath('//item')
      puts 'parsing'
    end
  end
end
