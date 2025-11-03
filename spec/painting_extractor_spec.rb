# frozen_string_literal: true

require 'rspec'
require 'json'
require 'pry'
require_relative '../lib/painting_extractor'

RSpec.describe PaintingExtractor do
  let(:extractor) { PaintingExtractor.new(html_file_path) }
  subject { extractor.extract_paintings[:artworks] }

  context 'comparison with expected output for van gogh paintings' do
    let(:html_file_path) { 'files/van-gogh-paintings.html' }
    let(:expected_json) { JSON.parse(File.read('files/expected-array.json'), symbolize_names: true) }

    it 'cross check painting data' do
      expect(subject).to eq(expected_json[:artworks])
    end
  end

  context 'data comparsion for pablo picasso artwork page' do
    let(:html_file_path) { 'spec/fixtures/pablo-picasso-artwork/web.html' }
    let(:expected_json) do
      JSON.parse(File.read('spec/fixtures/pablo-picasso-artwork/expected-array.json'),
                 symbolize_names: true)
    end
    it 'cross check data' do
      expect(subject).to eq(expected_json)
    end
  end

  context 'data comparsion for top nepali movies page' do
    let(:html_file_path) { 'spec/fixtures/top-nepali-movies/web.html' }
    let(:expected_json) do
      JSON.parse(File.read('spec/fixtures/top-nepali-movies/expected-array.json'),
                 symbolize_names: true)
    end
    it 'cross check data' do
      expect(subject).to eq(expected_json)
    end
  end

  context 'data comparsion for top actors page' do
    let(:html_file_path) { 'spec/fixtures/top-actors/web.html' }
    let(:expected_json) do
      JSON.parse(File.read('spec/fixtures/top-actors/expected-array.json'),
                 symbolize_names: true)
    end
    it 'cross check data' do
      expect(subject).to eq(expected_json)
    end
  end

  context 'data comparsion for the matrix actors page' do
    let(:html_file_path) { 'spec/fixtures/the-matrix-actors/web.html' }
    let(:expected_json) do
      JSON.parse(File.read('spec/fixtures/the-matrix-actors/expected-array.json'),
                 symbolize_names: true)
    end
    it 'cross check data' do
      expect(subject).to eq(expected_json)
    end
  end
end
