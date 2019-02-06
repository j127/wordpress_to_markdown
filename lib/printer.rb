# frozen_string_literal: true

require 'erb'

module WordPressToMarkdown
  # Printer class to generate files
  class Printer
    require 'erb'

    TEMPLATE_FILE = './lib/templates/template.toml.erb'

    def initialize(item_hash)
      template = File.open(TEMPLATE_FILE).read
      puts "loaded #{template}"
      @erb = ERB.new template
      @item = item_hash
    end

    def render
      @rendered = @erb.result(binding)
    end

    def save
      # TODO: save file
      puts '======='
      puts @rendered
      puts '======='
    end
  end
end
