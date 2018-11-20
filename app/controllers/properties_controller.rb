require 'open-uri'
require 'nokogiri'
require 'csv'

class PropertiesController < ApplicationController
  def index
    @properties = []
    search_house
  end

  def show
    @property = Property.find(params[:id])
  end
end

def search_house
  url = "https://www.zoopla.co.uk/for-sale/property/london/?q=London&results_sort=newest_listings&search_source=home"
  html_file = open(url).read
  html_doc = Nokogiri::HTML(html_file)
  html_doc.search('.listing-results-wrapper').each do |element|
    price = element.search('.listing-results-price').text
    name = element.search('.listing-results-attr a').text
    address = element.search('.listing-results-address').text
    photo = element.search('.photo-hover img').attr('src').value
    @properties << Property.new(name: name, price: price, address: address, photo: photo)
    @properties.take(10)
  end
    @properties
end


