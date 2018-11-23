# ========================
# --- Scraping Methods ---
# ========================
def autocomplete_postcode(postcode)
  url = "http://api.postcodes.io/postcodes/#{postcode}/autocomplete"
  response = JSON.parse(open(url).read)

  return response["result"][0]
end

def scrape_crime(postcode)
  url = "https://www.ukcrimestats.com/Postcode/#{postcode}"
  html_file = open(url).read
  html_doc = Nokogiri::HTML(html_file)

  return html_doc.search('.ranktable tr:nth-child(4)').text.split("Detached").first.gsub(/All Crime & ASB/, '')
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
  avg_current_first = avg_current.search('td:nth-child(2)').text.split("£")

  avg_price_foot = avg_current.search('td:nth-child(3)').text.split("£")

  avg_paid = avg_current.search('td:nth-child(5)').text.split("£")

  avg_current_first -= [""]
  avg_price_foot -= [""]
  avg_paid -= [""]

  # This is the average price for an area postcode
  avg_area = html_doc.search('.price').text.strip.split("£")[1]

  # This is the fun facts for each postcode, highest valued streets
  table_facts = html_doc.search('.split2l tbody').text.delete("\n").split("  ")
  table_facts = table_facts.reject { |e| e.empty? }

  table_facts_keys = table_facts.select.with_index { |e, i| i.even? }
  table_facts_vals = table_facts.reject.with_index { |e, i| i.even? }

  table_facts = table_facts_keys.zip(table_facts_vals).to_h

  return {
    property_type: property_type,
    avg_current_first: avg_current_first,
    avg_price_foot: avg_price_foot,
    avg_paid: avg_paid,
    avg_area: avg_area,
    table_facts: table_facts
  }
end

def scrape_zoopla(location)
  properties = []

  endpoint = 'https://www.zoopla.co.uk/for-sale/property/london/'
  url = endpoint + location
  html_file = open(url).read
  html_doc = Nokogiri::HTML(html_file)

  html_doc.search('.listing-results-wrapper').each do |element|
    name = element.search('.listing-results-attr a').text
    address = element.search('.listing-results-address').text
    # postcode = address.split(',')[-1].split(' ')[-1]
    photo = element.search('.photo-hover img').attr('src').value
    description = element.search('.listing-results-attr + p').text
    price = element.search('.listing-results-price').text

    next if photo.include?('noimage')

    property = Property.new(name: name, address: address, price: price, description: description)
    property.remote_photo_url = photo
    properties << property
  end

  return properties
end

# =====================
# --- Begin Seeding ---
# =====================
puts "Clearing database.."
User.destroy_all
Postcode.destroy_all
Property.destroy_all

# ================================
# --- Create Instances of User ---
# ================================
puts
puts "Creating users..."
usernames = %w(Amine Chris James Natasha)

usernames.each do |user|
  puts "Creating user #{user}"
  User.create(name: user, email: "#{user.downcase}@gmail.com", password: "123456", admin: true)
end

# ====================================
# --- Create Instances of Postcode ---
# ====================================
puts
puts "Creating postcodes..."
postcodes = %w(E2 SW5 E14 W2 CB3 OX2)

postcodes.each do |postcode|
  puts "Creating instance for postcode #{postcode}..."
  postcode = autocomplete_postcode(postcode).split(' ')
  postcode_obj = Postcode.new(outcode: postcode[0], incode: postcode[1])
  postcode_obj.crime_rating = scrape_crime(postcode[0]+postcode[1])

  zoopla_details = zoopla_details(postcode[0]+postcode[1])

  postcode_obj.property_type = zoopla_details[:property_type].to_json
  postcode_obj.avg_current_first = zoopla_details[:avg_current_first].to_json
  postcode_obj.avg_price_foot = zoopla_details[:avg_price_foot].to_json
  postcode_obj.avg_paid = zoopla_details[:avg_paid].to_json
  postcode_obj.avg_area = zoopla_details[:avg_area].to_json
  postcode_obj.table_facts = zoopla_details[:table_facts].to_json

  postcode_obj.save
end

# ====================================
# --- Create Instances of Property ---
# ====================================
puts
puts "Creating properties..."
postcodes = Postcode.all

postcodes.each do |postcode|
  puts "Creating instances of property for #{postcode.outcode}..."
  properties = scrape_zoopla(postcode.outcode)

  properties.each do |property|
    property.postcode = postcode
    property.save
  end
end

puts
puts "Done seeding database..."

# puts "Creating Static Properties"
# properties_attributes = [
#   {
#     location:       'Chelsea',
#     address:        '37 Plont Place, SW3 1HD, London',
#     photo:          'https://lid.zoocdn.com/645/430/2720a3cd34acfc1bb5cd974dee61c2201f9a0032.jpg',
#     year:           '2002',
#     price:          '1.1 Million',
#     crime_rating:   '10%'
#   },
#
#   {
#     location:       'Greewich',
#     address:        '56 KingsLand, SE10 0AB, London',
#     photo:          'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQRZgZaMEf1lS9Yz8va4ntv87VyMpZ40LB9l3ob5tqzNwq2n1vUkg',
#     year:           '1997',
#     price:          '2.9 Million',
#     crime_rating:   '10%'
#   },
#
#   {
#     location:        'Hampstead',
#     address:         '6 HampHead, SAL0 0AB, London',
#     photo:           'http://www.brillowen.co.uk/wp-content/uploads/IMAGE-3-1200x797.jpg',
#     year:            '1987',
#     price:           '3.5 Million',
#     crime_rating:    '10%'
#   },
#
#   {
#     location:       'ChinaTown',
#     address:        '7 Beijing Road, SW45 0AB, London',
#     photo:          'https://i2-prod.liverpoolecho.co.uk/incoming/article14378418.ece/ALTERNATES/s615b/JS104068031.jpg',
#     year:           '2005',
#     price:          '1.5 Million',
#     crime_rating:   '10%'
#   },
#
#   {
#     location:        'Victoria',
#     address:         '19 Victoria Road, SO95 0AB, London',
#     photo:           'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQnTu9MNCzONB0jJbRxb1yKG0GQTYW7qn6avRKWURO2lO_nyPba',
#     year:            '2010',
#     price:           '7.8 Million',
#     crime_rating:    '10%'
#   },
#
#   {
#     location:       'Embankment',
#     address:        '22 John Road, LK90W 0AB, London',
#     photo:          'https://lid.zoocdn.com/645/430/299bffcebd3f3bbbc96276ad1f1568d9d49131b4.jpg',
#     year:           '2013',
#     price:          '10 Million',
#     crime_rating:   '10%'
#
#   },
#
#   {
#     location:       'Monument House',
#     address:        '1 Monument Road, SWH7 0AB, London',
#     photo:          'https://media.onthemarket.com/properties/2907250/471666171/image-0-1024x1024.jpg',
#     year:           '2007',
#     price:          '5.3 Million',
#     crime_rating:   '10%'
#   },
#
#
#   {
#     location:       'Pearson',
#     address:        '138 KingsLand Road, LK90W 0AB, London',
#     photo:          'https://lid.zoocdn.com/645/430/299bffcebd3f3bbbc96276ad1f1568d9d49131b4.jpg',
#     year:           '2013',
#     price:          '10 Million',
#     crime_rating:   '10%'
#   },
#
#   {
#     location:       'Burgingham',
#     address:        'Burgingham Palace, LK90W 0AB, London',
#     photo:          'https://www.royal.uk/sites/default/files/images/feature/buckingham-palace.jpg',
#     year:           '1950',
#     price:          '150 Million',
#     crime_rating:   '10%'
#   },
#
#   {
#     location:       'Shoreditch',
#     address:        '47 Shore Road, LK90W 0AB, London',
#     photo:          'https://secure.i.telegraph.co.uk/multimedia/archive/01899/escape-london-5_1899860b.jpg',
#     year:           '2013',
#     price:          '10 Million',
#     crime_rating:   '10%'
#   },
# ]
# Property.create!(properties_attributes)
