require 'rest-client'
require 'addressable/uri'
require 'json'
require 'nokogiri'

class GeoLocating
  attr_reader :stores_array
  attr_accessor :latitude, :longitude

  def initialize
    @stores_array = []
  end

  # updates stores_array to contain dirs and distances
  def get_directions(address, store_index)
    response = RestClient.get(address)
    results = JSON.parse(response)

    directions = []


    if results["routes"][0].nil?
      sleep(1)
      return get_directions(address, store_index)

    end

    results["routes"][0]["legs"][0]["steps"].each do |step|
      directions << step["html_instructions"]
    end
    directions_string = directions.join("\n")
    directions_string = directions_string.gsub("<div style=\"font-size:0.9em\">", "\n")
    directions_string = directions_string.gsub("</div>", "")
    self.stores_array[store_index][:directions] = directions_string
    distance_string = results["routes"][0]["legs"][0]["distance"]["text"]
    self.stores_array[store_index][:distance] = distance_string


  end


  def get_source_coordinates(address)
    address = Addressable::URI.new(
       :scheme => "http",
       :host => "maps.googleapis.com",
       :path => "maps/api/geocode/json",
       :query_values => {:address => "#{address}",
         sensor: false}
     ).to_s

    response = RestClient.get(address)
    result = JSON.parse(response)
    #p result
    # p result["results"][0]["geometry"]["location"]
    self.latitude = result["results"][0]["geometry"]["location"]["lat"]
    self.longitude = result["results"][0]["geometry"]["location"]["lng"]

  end

  # api key: AIzaSyApjk1EQRLKvHnzy5mm-db28zfXpRy4eaU
  def get_nearby_places
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
  # p results["results"][0]["geometry"]["location"]["lng"]
  # p results["results"][0]["geometry"]["location"]["lat"]
  # p results["results"][0]["name"]


    results["results"].each do |r|
      hash = {lng: r["geometry"]["location"]["lng"],
      lat: r["geometry"]["location"]["lat"],
      name: r["name"]}
      # calculate distance and add to hash


      self.stores_array << hash
    end

  end

  # request URL: http://maps.googleapis.com/maps/api/directions/output?parameters

  def populates_direction_value
    self.stores_array.each_index do |store_index|
      address = Addressable::URI.new(
        scheme: "http",
        host: "maps.googleapis.com",
        path: "maps/api/directions/json",
        query_values: {origin: "#{latitude},#{longitude}",
                      destination:
                      "#{self.stores_array[store_index][:lat]},#{self.stores_array[store_index][:lng]}",
                        sensor: false }
                        #change travel mode
                        #html_instructions
      ).to_s


      get_directions(address, store_index)
    end

  end


  # stores_array.each do |store|
  #   puts "#{store[:name]}, #{store[:distance]}"
  # end


  def user_prompt_choice

    self.stores_array.each_with_index do |store, i|
      puts "(#{i+1}): #{store[:name]}, #{store[:distance]}"
    end

    puts "Choice the number of the place you want directions to"
    input = gets.chomp.to_i
    input-1
  end

  def print_directions(input)
    puts Nokogiri::HTML(self.stores_array[input][:directions]).text
  end

  def user_prompt_starting_location
    puts "What's your starting location? (Street address, City, State)"
    address = gets.chomp
    address
  end

  def run
    address = user_prompt_starting_location
    get_source_coordinates(address)

    get_nearby_places
    populates_direction_value

    input = user_prompt_choice
    print_directions(input)
  end

end