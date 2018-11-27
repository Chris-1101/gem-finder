Geocoder.configure(
  lookup: :google,
  units: :km,
  api_key:   ENV['GOOGLE_API_SERVER_KEY'],
  use_https: true,
)
