require 'rest-client'
require 'addressable/uri'
require 'json'
require 'set'

address = Addressable::URI.new(
   :scheme => "http",
   :host => "maps.googleapis.com",
   :path => "maps/api/geocode/json",
   :query_values => {:address => "770 broadway, New York, ny",
     sensor: false}
 ).to_s

response = RestClient.get(address)
result = JSON.parse(response)
#p result
# p result["results"][0]["geometry"]["location"]
latitude = result["results"][0]["geometry"]["location"]["lat"]
longitude = result["results"][0]["geometry"]["location"]["lng"]

# api key: AIzaSyApjk1EQRLKvHnzy5mm-db28zfXpRy4eaU
address = Addressable::URI.new(
# https://maps.googleapis.com/maps/api/place/nearbysearch/output?key=AIzaSyApjk1EQRLKvHnzy5mm-db28zfXpRy4eaU&location=40.7308443,-73.99136419999999&rankby=distance&keyword=ice+cream&sensor=false
#
#
  scheme: "https",
  host: "maps.googleapis.com",
  path: "maps/api/place/nearbysearch/json",
  query_values: {key: "AIzaSyApjk1EQRLKvHnzy5mm-db28zfXpRy4eaU",
                  location: "#{latitude},#{longitude}",
                  rankby: "distance",
                  keyword: "ice cream",
                  sensor: false }
).to_s

response = RestClient.get(address)
results = JSON.parse(response)
p results["results"][0]["geometry"]["location"]["lng"]
p results["results"][0]["geometry"]["location"]["lat"]
p results["results"][0]["name"]

stores_array = []
results["results"].each do |r|
  hash = {lng: r["geometry"]["location"]["lng"],
  lat: r["geometry"]["location"]["lat"],
  name: r["name"]}
  # calculate distance and add to hash


  stores_array << hash
end

# request URL: http://maps.googleapis.com/maps/api/directions/output?parameters

address = Addressable::URI.new(
  scheme: "http",
  host: "maps.googleapis.com",
  path: "maps/api/directions/json",
  query_values: {origin: "#{latitude},#{longitude}",
                destination: "#{stores_array[0][:lat]},#{stores_array[0][:lng]}",
                  sensor: false }
                  #change travel mode
                  #html_instructions
).to_s



def get_directions(address)
  response = RestClient.get(address)
  results = JSON.parse(response)

  #results["routes"][0]["legs"][0]["distance"]
  #p results["routes"][0]["legs"][0]["distance"]["text"]
  #
  p results["routes"][0]["legs"][0]["steps"][0]
  puts "puts steps"
  results["routes"][0]["legs"][0]["steps"].each do |step|
    p step["html_instructions"]
  end
end


