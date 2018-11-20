require 'open-uri'
require 'nokogiri'
require 'csv'

class House
 attr_reader :name, :price, :href
  def initialize(name, price, href)
    @name = name
    @price = price
    @href = href
  end
end

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
  html_doc.search('.listing-results-right').each do |element|
    price = element.search('.listing-results-price').text.strip
    href = element.search('.listing-results-attr').css('a').first['href']

    @properties << House.new(, price, href)
    @properties.take(10)
  end
  display_properties(@properties)
end

def display_properties(property_instances)
  # View
  properties = property_instances.take(5)
  properties.each_with_index do |house, index|
    gbp_conversion = house.price.gsub('.', '').to_i
    gbp = (gbp_conversion * 0.00025)
    puts "#{index + 1} - #{house.name.text.strip} : #{house.price} (£#{gbp})"
    # binding.pry
    puts house.href.to_s
    puts ''
  end
end
