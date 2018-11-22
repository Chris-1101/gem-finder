class ScrapePropertiesJob < ApplicationJob
  queue_as :default

  def perform(current_user_id)
    @user = User.find(current_user_id)

    url = "https://www.zoopla.co.uk/for-sale/property/london/?q=London&results_sort=newest_listings&search_source=home"
    html_file = open(url).read
    html_doc = Nokogiri::HTML(html_file)

    html_doc.search('.listing-results-wrapper').each do |element|
      name = element.search('.listing-results-attr a').text
      address = element.search('.listing-results-address').text
      photo = element.search('.photo-hover img').attr('src').value
      description = element.search('.listing-results-attr + p').text
      price = element.search('.listing-results-price').text
      property = Property.new(name: name, address: address, price: price, description: description)
      property.remote_photo_url = photo
      property.save!
    end
  end
end
