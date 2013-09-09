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
  set = Set.new [r["geometry"]["location"]["lng"],
  r["geometry"]["location"]["lat"],
  r["name"]]
  stores_array << set
end

p stores_array



