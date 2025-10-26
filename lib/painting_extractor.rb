require 'nokogiri'
require 'ferrum'

class PaintingExtractor
  def initialize(html_file_path)
    @html_file_path = File.expand_path(html_file_path)
  end

  def extract_paintings
    browser = setup_browser
    
    begin
      browser.goto("file://#{@html_file_path}")
      
      # Wait for page/js to load
      sleep(2)
      # Get the fully rendered HTML after JavaScript execution
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
      browser.quit if browser
    end
  end

  private

  def setup_browser
    Ferrum::Browser.new(
      timeout: 10
    )
  end

  def extract_from_doc(doc)
    paintings = []
    items = doc.css('.iELo6')  # This is the actual class for painting items
    items.each_with_index do |item, index|
      painting = extract_painting_data(item)
      paintings << painting
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
    extendions = extract_extensions(item)
    return_value[:extensions] = extendions if extendions.any?
    return_value
  end

  def extract_name(item)
    item.at_css('.pgNMRc')&.text&.strip
  end

  def extract_extensions(item)
    extensions = []
    
    # Look for date information
    date_element = item.at_css('.cxzHyb')
    if date_element
      # Extract years (1889, 1890, etc.)
      dates = date_element.text.scan(/\b\d{4}\b/)
      extensions.concat(dates)
    end
    
    extensions
  end

  def extract_link(item)
    link = item.at_css('a')&.[]('href')
    
    # Handle relative URLs
    if link && !link.start_with?('http')
      link = "https://www.google.com#{link}"
    end
    
    link
  end

  def extract_thumbnail(item)
    img = item.at_css('img')
    return nil unless img
 
    img['data-src'] || img['src']
  end
end