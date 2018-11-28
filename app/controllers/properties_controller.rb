require 'open-uri'
require 'nokogiri'
require 'json'
require 'csv'

class PropertiesController < ApplicationController
  def new
    @property = Property.new
  end

  def create
    @property = Property.new(property_params)
    if @property.save!
      redirect_to property_path(@property)
    else
      render :new
    end
  end

  def index
      @properties = Property.all.includes(:postcode)
    if params[:location].present?
      p params[:location]
      search_query = params[:location]
      radius = (search_query.include?('City of London')) ? 10 : 3
      @properties = @properties.near(search_query, radius)
    end

    if params[:bedrooms].present?
      @properties = @properties.where(bedrooms: params[:bedrooms].to_i)
    end

    bedrooms = @properties.map do |property|
      property.bedrooms
    end

    if params[:price].present?
      @properties = @properties.where("price <= ?", params[:price].to_i)
    end

    @max_bedrooms = bedrooms.max
    @property = Property.new
    # @properties = search_house
    # @properties = Property.all
    # search_house

    # Had to comment this out:
    # It overwrites the variable holding scraped results and doesn't actually
    # return anything since the DB doesn't have saved instances of Property yet
    # search_house uses .new and doesn't .save --> in memory, never saved to DB
#
    # @properties2 = Property.where.not(latitude: nil, longitude: nil)

    @markers = @properties.map do |property|
      {
        lng: property.longitude,
        lat: property.latitude
      }
    end
  end

  def show
    postcodes = ['E26FG','SW50NU','W1A0AA','W1W5AL','W1W5AP','W60AT','W60DE','W60HR','W84BA','W84BH',
              'W84HL','W84QY','N20AA','N20ND','NW10BJ','SE10BD','SE10EY','SE10QB','SW31NU','B11JX',
              'B375AE','B495AA','HG11HQ','HG11PW','L10AA','L250LA','NE311AD','NE697AD','SO206AA','SO531DA',
              'YO322AA','YO624ED','YO624NA','WA95NQ','DT11QQ','DT96SX','CH339BZ','CH630EB','PO91AN','PO191HD',
              'SR81DS','SR31HU','SR13NE','SP12NW','WN67TB','WN68PA','IP11PH','BH63RE','BH220AN','BH241AX',
              'BH11AQ','BH37HG','BA140AE','BA151ET','GL91AL','GL205AE','GL80AN','BS140AG','BS394BB','BS273QW',
              'CB223AJ','CB74AF','CB80GQ','CB244TE','WR51AL','WR101AS','WR141EF','WR991YU','WR158HR','TQ110AE',
              'E20QQ','SY100AH','SY30AT','SY998AJ','M445AG','M320AT','M90PG','M250GR','M991BT','M380DD',
              'LA94AD','LA184AL','LA231AL','LA31BF','BN150AL','BN529BR','BN211DY','BN443GQ','CT154AR','CT201FH',
              'CT45GA','SW75NR','OX41DQ','CM131AB','CM186DT','CM210EP','CM981AR','CM20DG','CM164BT','CM11BW',
              'EH331BN','EH11BS','EH458AD','KW136YT','LL197DB','CF30AW','CF355AQ','DG125BA','G36DZ','G811BN',
              'BT119BS','BT118LU','BT118QU','BT274HF','BT440JB','AB101AF','AB510AG','N101AG','N31AJ','SA20AH']

    @property = Property.find(params[:id])
    @markers = [{lng: @property.longitude, lat: @property.latitude}]

    crime_rating = @property.postcode.crime_rating
    avg_area = JSON.parse(@property.postcode.avg_area).gsub(/[,.]/, '').to_i

    property_value = ( (@property.price.to_f)) / avg_area * 100

    national_crime = crime_rating.to_f / 57.8 * 100


    @national_crime = 0
    if national_crime < 51
      @national_crime = 5
    elsif national_crime < 86
      @national_crime = 4
    elsif national_crime < 100
      @national_crime = 3
    elsif national_crime < 130
      @national_crime = 2
    else
      @national_crime = 1
    end

    @property_rating = 0
    if property_value < 50
      @property_rating = 5
    elsif property_value < 75
      @property_rating = 4
    elsif property_value <= 100
      @property_rating = 3
    elsif property_value < 120
      @property_rating = 2
    else
      @property_rating = 1
    end

    @opportunity_rating = ((@property_rating + @national_crime).to_f / 2).ceil


    # @crime_rates = []
    # @postcodes = postcodes.sample(10)
    # @postcodes.each { |postcode| @crime_rates << scrape_crime(postcode).gsub(/All Crime & ASB/, '') }
    @property_details = zoopla_details(@property.postcode.outcode + @property.postcode.incode)
    @avg_prices = @property_details[:avg_current_first_column]
    # @hometrack_details = hometrack_details
  end

  private

  def scrape_crime(postcode)
    url = "https://www.ukcrimestats.com/Postcode/#{postcode}"
    html_file = open(url).read
    html_doc = Nokogiri::HTML(html_file)

    return html_doc.search('.ranktable tr:nth-child(4)').text.split("Detached").first
  end

  def search_house
    # ScrapePropertiesJob.perform_later(current_user.id)
    properties = []

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

      properties << property
      properties.take(10)
    end

    return properties
  end

  def hometrack_details
    url = "https://www.hometrack.com/uk/insight/uk-cities-house-price-index/"

    html_file = open(url).read
    html_doc = Nokogiri::HTML(html_file)

    cities = html_doc.search('tr[data-bind="click:selectCity"] td:nth-child(1)').to_a.join(" ").split(" ")
    average_price = html_doc.search('tr[data-bind="click:selectCity"] td:nth-child(2)').text.split("£")
    twelve_months = html_doc.search('tr[data-bind="click:selectCity"] td:nth-child(5)').text.strip.split("%")
    last_month = html_doc.search('tr[data-bind="click:selectCity"] td:nth-child(7)').text.strip.split("%")

    average_price -= [""]

    return {
      cities: cities,
      average_price: average_price,
      twelve_months: twelve_months,
      last_month: last_month
    }
  end

  def zoopla_details(postcode)
    url = "https://www.zoopla.co.uk/market/#{postcode}/"

    html_file = open(url).read
    html_doc = Nokogiri::HTML(html_file)

    # This is the property type and the first column in the table
    property_type = html_doc.search('.stripe.property-table td:nth-child(1)').to_a.join(" ").to_s.delete("\n")
    property_type = property_type.split(" ")[0..3]

    # This is the second column of the first table (Average current value)
    avg_current = html_doc.search('.stripe.property-table').first
    avg_current_first_column = avg_current.search('td:nth-child(2)').text.split("£")

    avg_price_foot = avg_current.search('td:nth-child(3)').text.split("£")

    avg_paid = avg_current.search('td:nth-child(5)').text.split("£")

    avg_current_first_column -= [""]
    avg_price_foot -= [""]
    avg_paid -= [""]

    # This is the average price for an area postcode
    area_average = html_doc.search('.price').text.strip.split("£")[1]

    # This is the fun facts for each postcode, highest valued streets
    table_facts = html_doc.search('.split2l tbody').text.delete("\n").split("  ")
    table_facts = table_facts.reject { |e| e.empty? }

    return {
      property_type: property_type,
      avg_current_first_column: avg_current_first_column,
      avg_price_foot: avg_price_foot,
      avg_paid: avg_paid,
      area_average: area_average,
      table_facts: table_facts
    }
  end

  def property_params
    params.require(:property).permit(:name, :address, :price, :photo)
  end
end
