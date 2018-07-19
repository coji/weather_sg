require 'bundler'
Bundler.require
require 'sqlite3'
require 'open-uri'
require 'json'
require 'time'

db = SQLite3::Database.new 'db/weather.db'

def insert(db, type, json)
  timestamp = Time.parse(json['items'].first['timestamp'])
  sql =<<-SQL
    insert into weather_log(type, ts, station_id, value)
    values (?, ?, ?, ?)
  SQL

  if(type == 'psi')
    db.execute(sql, type, timestamp.to_s, 'S108', json['items'].first['readings']['psi_twenty_four_hourly']['central'])
  else
    json['items'].first['readings'].each do |r|
      db.execute(sql, type, timestamp.to_s, r['station_id'], r['value'])
    end
  end
end

# PSI
psi = JSON.parse(open('https://api.data.gov.sg/v1/environment/psi').read)
insert(db, 'psi', psi)
# temp
temp = JSON.parse(open('https://api.data.gov.sg/v1/environment/air-temperature').read)
insert(db, 'temp',temp)
# rain
rain = JSON.parse(open('https://api.data.gov.sg/v1/environment/rainfall').read)
insert(db, 'rain', rain)
# humidity
humidity = JSON.parse(open('https://api.data.gov.sg/v1/environment/relative-humidity').read)
insert(db, 'humidity', humidity)

timestamp = Time.now.strftime("%Y%m%d_%H%M")
open("temp/temp_#{timestamp}.json", "w") do |out|
  out.print JSON.pretty_generate(temp)
end
open("rain/rain_#{timestamp}.json", "w") do |out|
  out.print JSON.pretty_generate(rain)
end
open("humidity/humidity_#{timestamp}.json", "w") do |out|
  out.print JSON.pretty_generate(humidity)
end
open("psi/psi_#{timestamp}.json", "w") do |out|
  out.print JSON.pretty_generate(psi)
end

