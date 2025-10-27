# frozen_string_literal: true

require 'nokogiri'
require 'ferrum'

class PaintingExtractor
  ITEMS_SELECTOR = '#search div.iELo6, g-scrolling-carousel div[jscontroller="A4LTfe"], .sinMW, .QjXCXd'
  ITEM_NAME_SELECTOR = '.pgNMRc, .NJU16b, .B0jnne .FZPZX, .JjtOHd'
  ITEM_EXTENSION_SELECTOR = '.cxzHyb, .ellip.yF4Rkc'

  def initialize(html_file_path)
    @html_file_path = File.expand_path(html_file_path)
  end

  def extract_paintings
    browser = setup_browser
    begin
      browser.goto("file://#{@html_file_path}")
      rendered_html = browser.body

      # Parse with Nokogiri
      doc = Nokogiri::HTML(rendered_html)
      paintings = extract_from_doc(doc)
      { artworks: paintings }
    rescue StandardError => e
      puts "❌ Error during extraction: #{e.message}"
      puts e.backtrace
      { artworks: [] }
    ensure
      browser&.quit
    end
  end

  private

  def setup_browser
    Ferrum::Browser.new(timeout: 15)
  end

  def extract_from_doc(doc)
    paintings = []
    items = doc.css(ITEMS_SELECTOR)
    items.each_with_index do |item, _index|
      painting = extract_painting_data(item)
      paintings << painting if painting
    end
    paintings
  end

  def extract_painting_data(item)
    name = extract_name(item)
    return nil unless name

    return_value = {
      name: name,
      link: extract_link(item),
      image: extract_thumbnail(item)
    }
    extentions = extract_extensions(item)
    return_value[:extensions] = extentions if extentions.any?
    return_value
  end

  def extract_name(item)
    item.at_css(ITEM_NAME_SELECTOR)&.text&.strip
  end

  def extract_extensions(item)
    extension_element = item.at_css(ITEM_EXTENSION_SELECTOR)&.text

    return [] if extension_element.nil? || extension_element.empty?

    [extension_element]
  end

  def extract_link(item)
    link = item.at_css('a')&.attr('href')

    # Handle relative URLs
    link = "https://www.google.com#{link}" if link && !link.start_with?('http')

    link
  end

  def extract_thumbnail(item)
    img = item.at_css('img')
    return nil unless img

    img['data-src'] || img['src']
  end
end

if __FILE__ == $PROGRAM_NAME
  if ARGV.empty?
    puts "Usage: ruby lib/painting_extractor.rb path/to/file.html"
    exit 1
  end

  html_file_path = ARGV[0]
  extractor = PaintingExtractor.new(html_file_path)
  result = extractor.extract_paintings

  puts JSON.pretty_generate(result)
end
