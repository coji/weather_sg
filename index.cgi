#!/home/coji/.rbenv/shims/ruby

require 'bundler'
Bundler.require
require 'sqlite3'

db = SQLite3::Database.new 'db/weather.db'
db.results_as_hash = true

sql = <<EOQ
  select
    substr(ts, 0, 14) as ts, 
    round(avg(case when type = 'temp' then value else null end),1) as temp,
    round(avg(case when type = 'humidity' then value else null end),1) as humidity,
    round(sum(case when type = 'rain' then value else null end), 1) as rain,
    max(case when type = 'psi' then value else null end) as psi
  from
    weather_log where station_id = 'S108'
  group by
    substr(ts, 0, 14)
  order by ts desc
  limit 168
EOQ
ret = db.execute(sql)

puts 'Content-Type: text/html'
puts
puts '<!DOCTYPE html><html lang="en"><head><meta name="viewport" content="width=device-width, initial-scale=1"><link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap.min.css" integrity="sha384-BVYiiSIFeK1dGmJRAkycuHAHRg32OmUcww7on3RYdg4Va+PmSTsz/K68vbdEjh4u" crossorigin="anonymous">
<title>Singapore Temp, Rain, Humidityi</title></head><body>'
puts '<div class="container"><div class="row"><h1>Singapore Realtime Weather Readings</h1><p>source: <a href="https://data.gov.sg/dataset/realtime-weather-readings">Goverment of Singapore</a></p><p>weather station: <a href="https://www.google.com/maps?q=1.31055,103.8365">Scotts Road</a></p></div><div class="row"><div class="col-md-8">'
puts '<table class="table">'
puts '<thead><th>Hour (SGT)</th><th><a target="_blank" href="https://api.data.gov.sg/v1/environment/air-temperature">Temperature</a></th><th><a target="_blank" href="https://api.data.gov.sg/v1/environment/relative-humidity">Humidity</a></th><th><a target="_blank" href="https://api.data.gov.sg/v1/environment/rainfall">RainFall</a></th><th><a target="_blank" href="https://api.data.gov.sg/v1/environment/psi">Air Quality (PSI)</a></th></thead>'
ret.each do |r|
  puts "<tr>"
  puts "<td>#{r['ts'][0..15]}</td>"
  puts "<td>#{r['temp']}</td>"
  puts "<td>#{r['humidity']}</td>"
  puts "<td>#{r['rain']}</td>"
  puts "<td>#{r['psi']}</td>"
  puts "</tr>"
end
puts "</table></div></div></div></body></html>"
