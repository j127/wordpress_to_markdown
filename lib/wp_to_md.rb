# frozen_string_literal: true

# WordPress to Markdown module
module WordPressToMarkdown
  require 'thor'

  # Convert WordPress to markdown
  class CLI < Thor
    require_relative 'importer'

    desc 'export', 'export WordPress to markdown'
    def export(input_file, output_dir)
      if File.directory? output_dir
        # TODO: check if the dir is empty, not if it exists
        puts "Exiting because directory '#{output_dir}' exists."
        puts 'Please delete it first.'
        exit
      end

      puts "processing #{input_file}"
      Importer.new input_file, output_dir
    end
  end
end
