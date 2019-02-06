# frozen_string_literal: true

# Convert WordPress to Markdown
module WordPressToMarkdown
  # The importer functionality
  class Importer
    require 'time'
    require 'nokogiri'
    require 'reverse_markdown'

    def initialize(input_file, output_dir)
      puts "about to convert #{input_file} to markdown & save to #{output_dir}"
      @doc = File.open(input_file) { |f| Nokogiri::XML(f) }

      parse_items
    end

    # Extract taxonomy from a post item returning an array of terms
    def extract_taxonomy(item, type)
      if type = :categories
        result = item.xpath("category[@domain='category']")
      else if type = :tags
        result = item.xpath("category[@domain='post_tag']")
      end

      # send the taxonomy terms as an array
      result.map { |taxonomy_term| taxonomy_term.text }
    end

    def extract_comments(item)
      # TODO
      item
    end

    # Take a nokogiri item and return a hash with the post/comment data
    def parse_item(item)
      raw_content = item.xpath('content:encoded').text

      {
        title: item.xpath('title').text,
        pub_date: Time.parse(item.xpath('pubDate').text),
        raw_content: raw_content,
        tags: extract_taxonomy(item, :tags),
        categories: extract_taxonomy(item, :categories),
        type: item.xpath('wp:post_type'), # post, attachment, page?
        markdown: ReverseMarkdown.convert(raw_content),
        status: item.xpath('wp:status').text, # publish, inherit, private, draft?
        comments: extract_comments(items),
        slug: item.xpath('wp:post_name').text,
        post_id: item.xpath('wp:post_id').text,
        original_link: item.xpath('link').text,
        author: item.xpath('db:creator').text
      }
    end

    def parse_items
      # puts doc.xpath('//item')
      puts 'parsing'

      @posts = []
      items = @doc.xpath('//channel/item')
      puts "found #{items.count} items"
      puts items[605]['title']
    end
  end
end

# wp:status
# if status == 'private'

# else if status == 'draft'

# else

# end
