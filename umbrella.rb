# Write your soltuion here!
require "http"
require "dotenv/load"
require "ascii_charts"
require "json"

pirate_key = ENV.fetch("PIRATE_WEATHER_KEY")
gmaps_key = ENV.fetch("GMAPS_KEY")

puts "Where are you located?"
userloc = gets
puts "Checking the weather at #{userloc}"

#gmaps set up
gmaps_url = "https://maps.googleapis.com/maps/api/geocode/json?address=" + userloc + "&key=" + gmaps_key 
gmaps_raw = HTTP.get(gmaps_url)
gmaps_parsed = JSON.parse(gmaps_raw)
#gmaps getting lat long
userloc_results = gmaps_parsed.fetch("results")
userloc_firstresult = userloc_results.at(0)
userloc_geometry = userloc_firstresult.fetch("geometry")
userloc_location = userloc_geometry.fetch("location")
userloc_lat=userloc_location.fetch("lat")
userloc_lng= userloc_location.fetch("lng")
userloc_latlong = "/#{userloc_lat},#{userloc_lng}"

puts "\n"
puts "Your coordinates are #{userloc_lat}, #{userloc_lng}"

#pirate set up
pirate_url = "https://api.pirateweather.net/forecast/" + pirate_key + userloc_latlong
pirate_raw = HTTP.get(pirate_url)
pirate_parsed = JSON.parse(pirate_raw)
#pirate getting summary and temp
currently_hash = pirate_parsed.fetch("currently")
current_temp = currently_hash.fetch("temperature")
current_summ = currently_hash.fetch("summary")
puts "Current Weather Summary: #{current_summ}"
puts "Current Tempearature: #{current_temp} degrees"
puts "\n"

#pirate getting precip
hourly_hash = pirate_parsed.fetch("hourly")
hourly_data = hourly_hash.fetch("data")
count = 1
raincount = 0 
rain_data = []
12.times do |hourlyraincheck|
  precipProb = ((hourly_data.at(count).fetch("precipProbability"))*100).to_i
  rain_data.push([count,precipProb])
  if precipProb > 10
      if count == 1
        puts "In #{count} hour: #{precipProb}% chance of rain"
      else
        puts "In #{count} hours: #{precipProb}% chance of rain"
      end
      raincount +=1
    end
  count+=1
end

puts "\n"

if raincount > 0
  puts "You might want to carry an umbrella!"
else 
  puts "You probably won't need an umbrella today."
end

puts "\n"
puts "Hours from now vs. Precipitation proabability"
puts AsciiCharts::Cartesian.new(rain_data).draw
