require 'bundler'
Bundler.require
require 'sqlite3'
require 'json'
require 'time'

db = SQLite3::Database.new 'db/weather.db'
['temp', 'rain', 'humidity'].each do |type|
  Dir.glob("#{type}/*.json").each do |f|
    json = JSON.parse(open(f).read)
    puts "#{f}"

    json['metadata']['stations'].each do |s|
      sql =<<-SQL
        insert OR replace into station(station_id, name, latitude, longitude)
        values (?, ?, ?, ?)
      SQL
      p s
      db.execute(sql, s['id'], s['name'], s['location']['latitude'].to_f, s['location']['longitude'].to_f)
    end
=begin
    timestamp = Time.parse(json['items'].first['timestamp'])

    json['items'].first['readings'].each do |r|
#      puts [r['station_id'], r['value']].join("\t")
      sql =<<-SQL
        insert into weather_log(type, ts, station_id, value)
        values (?, ?, ?, ?)
      SQL
      db.execute(sql, type, timestamp.to_s, r['station_id'], r['value'])
    end
=end
  end
end
