require 'csv'
# Creating cities
puts "destroying existing activities"
Activity.destroy_all
array_of_cities = %w(Florence Rome Naples Bologne Bari Positano Anzio Piombino Lecce)
array_of_cities.each do |city|
  City.create!(country: "Italy", name: city)
end
# Cities created
puts "parsing csv activities"
csv_text = File.read(Rails.root.join('lib', 'seeds', 'activity_italy.csv'))
csv = CSV.parse(csv_text, :headers => true, :encoding => 'ISO-8859-1')
csv.each do |row|
  r = row
  Activity.create!({

    city_id: r["city_id"].to_i,
    address: r["address"],
    duration: r["duration"],
    activity_types: r["activity_types"],
    name: r["name"],
    ranking_interest: r["ranking_interest"],
    photo: r["photo"],
    description: r["description"],
    price: r["price"]
  })
end

puts "done"
