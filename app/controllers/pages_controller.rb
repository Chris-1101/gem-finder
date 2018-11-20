class PagesController < ApplicationController
  skip_before_action :authenticate_user!, only: [:home]

  def home
  end

  def properties
  end

  def about
  end

  def contact
  end


end

require 'nokogiri'
require 'json'
require 'open-uri'

postcodes = ['E26FG','SW50NU',]
postcodes.each do |postcode|
url = "https://www.ukcrimestats.com/Postcode/#{postcode}"

html_file = open(url).read
html_doc = Nokogiri::HTML(html_file)

for num in 6..12 do
  p html_doc.search(".ranktable tr:nth-child(#{num})").text
end

p html_doc.search('.ranktable tr:nth-child(4)').text
# html_doc.search('.ranktable table table-responsive').each do |element|
#   p element.text.strip
#   puts element.attribute('href').value
#   end
end

