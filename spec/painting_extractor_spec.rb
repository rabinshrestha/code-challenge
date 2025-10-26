require 'rspec'
require 'json'
require 'pry'
require_relative '../lib/painting_extractor'

RSpec.describe PaintingExtractor do
  let(:html) { File.read('files/van-gogh-paintings.html') }
  let(:extractor) { PaintingExtractor.new(html) }
  let(:result) { extractor.extract_paintings }
  let(:paintings) { result[:artworks] }
  
  # Load expected output for comparison
  let(:expected_json) { JSON.parse(File.read('files/expected-array.json'), symbolize_names: true) }
  let(:expected_paintings) { expected_json[:artworks] }
  
  describe '#extract_paintings' do
    it 'returns a hash with artworks key' do
      expect(result).to have_key(:artworks)
      expect(result[:artworks]).to be_an(Array)
    end
    
    it 'extracts the correct number of paintings' do
      expect(paintings.length).to eq(expected_paintings.length)
    end
    
    it 'extracts painting names' do
      expect(paintings.first).to have_key(:name)
      expect(paintings.first[:name]).to be_a(String)
      expect(paintings.first[:name]).not_to be_empty
    end
    
    it 'extracts extensions (years)' do
      expect(paintings.first[:extensions]).to be_an(Array)
      
      # Should contain 4-digit years
      paintings.each do |painting|
        # only check this if extensions exists
        painting[:extensions]&.each do |ext|
          expect(ext).to match(/^\d{4}$/)
        end
      end
    end
    
    it 'extracts valid Google links' do
      expect(paintings.first).to have_key(:link)
      expect(paintings.first[:link]).to match(/^https?:\/\//)
      expect(paintings.first[:link]).to include('google.com')
    end
    
    it 'extracts base64 encoded images' do
      expect(paintings.first).to have_key(:image)
      image = paintings.first[:image]
      
      expect(image).to be_a(String)
      expect(image).to start_with('data:image/')
      expect(image).to include('base64')
    end
    
    it 'matches expected structure' do
      painting = paintings.first
      expect(painting.keys).to match_array([:name, :extensions, :link, :image])
    end
  end
  
  describe 'comparison with expected output' do
    it 'extracts the same painting names as expected' do
      extracted_names = paintings.map { |p| p[:name] }.sort
      expected_names = expected_paintings.map { |p| p[:name] }.sort
      
      expect(extracted_names).to eq(expected_names)
    end

    it 'extracts the same painting link as expected' do
      extracted_values = paintings.map { |p| p[:link] }.sort
      expected_values = expected_paintings.map { |p| p[:link] }.sort
      
      expect(extracted_values).to eq(expected_values)
    end

    it 'extracts the same painting image as expected' do
      extracted_values = paintings.map { |p| p[:image] }.sort
      expected_values = expected_paintings.map { |p| p[:image] }.sort
      expect(extracted_values).to eq(expected_values)
    end
    
    it 'extracts correct extensions for all paintings' do
      paintings.each do |painting|
        expected = expected_paintings.find { |p| p[:name] == painting[:name] }
        next unless expected
        
        expect(painting[:extensions]).to eq(expected[:extensions]),
          "Extensions mismatch for '#{painting[:name]}'"
      end
    end
  end
end