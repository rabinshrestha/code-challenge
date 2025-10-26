require 'nokogiri'
require 'json'

class PaintingExtractor
  def initialize(html_content)
    @doc = Nokogiri::HTML(html_content)

  end

  def extract_paintings
    paintings = []
    
    # Find carousel items - adjust selectors based on actual HTML
    carousel_items.each do |item|
      painting = extract_painting_data(item)
      paintings << painting if painting
    end
    { artworks: paintings }
  end

  private

  def carousel_items
    @doc.css('.iELo6') 
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