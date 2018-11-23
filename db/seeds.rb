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

User.create!(email: "donald@lewagon.com", password: "1234567")
User.create!(email: "poutine@lewagon.com", password: "1234567")
User.create!(email: "therock@lewagon.com", password: "1234567")
User.create!(email: "phelim@lewagon.com", password: "1234567")
User.create!(email: "jessica@lewagon.com", password: "1234567")
User.create!(email: "mcgregor@lewagon.com", password: "1234567")
User.create!(email: "lebron@lewagon.com", password: "1234567")
User.create!(email: "ronaldo@lewagon.com", password: "1234567")
User.create!(email: "musk@lewagon.com", password: "1234567")
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

