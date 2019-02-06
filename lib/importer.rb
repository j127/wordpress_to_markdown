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
      if type == :categories
        result = item.xpath("category[@domain='category']")
      elsif type == :tags
        result = item.xpath("category[@domain='post_tag']")
      end

      # send the taxonomy terms as an array
      result.map(&:text)
    end

    # Return the comments for an item as an array of hashes
    def extract_comments(item)
      comments = []
      comment_nodes = item.xpath('wp:comments')

      unless comment_nodes.empty?
        comment_nodes.each do |c|
          comments << process_comment(c) if comment_is_valid?(c)
        end
      end

      comments
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
        markdown: process_content(raw_content),
        # publish, inherit, private, draft?
        status: item.xpath('wp:status').text,
        comments: extract_comments(items),
        slug: item.xpath('wp:post_name').text,
        post_id: item.xpath('wp:post_id').text,
        original_link: item.xpath('link').text,
        author: item.xpath('db:creator').text
      }
    end

    def parse_items
      puts 'parsing'

      @posts = []
      items = @doc.xpath('//channel/item')
      puts "found #{items.count} items"
      puts items[611]
    end

    private

    # Make sure that a comment should be published
    def comment_is_valid?(comment)
      comment.xpath('wp:comment_approved').text == '1' && \
        comment.xpath('wp:comment_type').text != 'pingback'
    end

    # Extract data from an individual comment node
    def process_comment(comment)
      {
        id: comment.xpath('wp:comment_id').text,
        author: comment.xpath('wp:comment_author').text,
        date: Time.parse(comment.xpath('wp:comment_date').text),
        raw_content: comment.xpath('wp:comment_content').text,
        markdown: process_content(raw_content)
      }
    end

    # Remove caption shortcodes from WordPress content
    def strip_captions(content)
      content.gsub(/\[caption.+?\]/, '').gsub(/\[\/caption\]/, '')
    end

    # Convert a YouTube URL to embed code
    def youtube_url_to_embed(content)
      # TODO
      lines = content.lines.map(&:chomp)
      lines.map do |line|
        # TODO: double check this regex
        pattern = %r{^https?:\/\/(.*?\.?)(youtube\.com|youtu\.be)\/.*?v=([-_a-zA-Z0-9]+)$}
        video_id = pattern.last

        if video_id
          return %{
            <iframe
            width="640" height="360"
            src="https://www.youtube-nocookie.com/embed/#{video_id}?rel=0"
            frameborder="0" allow="accelerometer; autoplay; encrypted-media;
            gyroscope; picture-in-picture" allowfullscreen></iframe>
          }.gsub(/\s+/, '')
        end

        line # if there is no video, retrun the unmodified line
      end
    end

    # Peform multiple cleaning operations and convert to markdown
    def process_content(content)
      ReverseMarkdown.convert(youtube_url_to_embed(strip_captions(content)))
    end
  end
end
