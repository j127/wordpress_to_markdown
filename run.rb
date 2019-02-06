require_relative './lib/wp_to_md'

WordPressToMarkdown::CLI.start if $PROGRAM_NAME == __FILE__
