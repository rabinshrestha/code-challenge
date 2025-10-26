require 'rspec'
require 'json'
require 'pry'
require_relative '../lib/painting_extractor'

RSpec.describe PaintingExtractor do
  let(:html_file_path) { 'files/van-gogh-paintings.html' }
  let(:extractor) { PaintingExtractor.new(html_file_path) }
  let(:paintings) { extractor.extract_paintings[:artworks] }
  
  # Load expected output for comparison
  let(:expected_json) { JSON.parse(File.read('files/expected-array.json'), symbolize_names: true) }
  let(:expected_paintings) { expected_json[:artworks] }
  
  describe 'comparison with expected output' do
    it 'extracts the correct number of paintings' do
      expect(paintings.length).to eq(expected_paintings.length)
    end

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