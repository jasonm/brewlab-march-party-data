# curl http://localhost:5984/_replicate -H 'Content-Type: application/json' -d '{ "source": "https://jasonmorrison:sofapizza@jasonmorrison.cloudant.com/radiobeer1", "target": "radiobeer1_local" }'
# 

# _ extend times to next day
# _ retap the belgian porter as per ~/dev/tastywheel/TODO.md

`spark` rescue raise("Install https://github.com/holman/spark for sparklines; brew install spark on OSX")

require 'couchrest'
require 'json'
require 'time'
require 'pry'

docs = []
if ENV['FETCH']
  db = CouchRest.database("https://jasonmorrison:sofapizza@jasonmorrison.cloudant.com/radiobeer1")

  docs = db.
    all_docs(include_docs: true)['rows'].
    map { |r| r['doc'] }.
    select { |d| d['type'] }

  open("documents.json", "a") do |f|
    f.puts docs.to_json
  end
else
  docs = JSON.parse(open("documents.json").read)
end

rating_headers = %w(beer_id beer_name timestamp liked hoppy sweet creamy fruity roasty bitter citrus floral)
rating_rows = []

docs.select { |d| d['type'] == 'beer' }.each do |beer_doc|
  next if beer_doc['ratings'].nil?

  beer_doc['ratings'].each do |rating_doc|
    rating_rows << [
      beer_doc['_id'],
      beer_doc['name'],
      rating_doc['created_at'],
      rating_doc['liked'],
      rating_doc['values']['Hoppy'],
      rating_doc['values']['Sweet'],
      rating_doc['values']['Creamy'],
      rating_doc['values']['Fruity'],
      rating_doc['values']['Roasty'],
      rating_doc['values']['Bitter'],
      rating_doc['values']['Citrus'],
      rating_doc['values']['Floral']
    ]
  end
end

taps = docs.select { |d| d['type'] == 'tap' }
beers = docs.select { |d| d['type'] == 'beer' }

scans = docs.select { |d| d['type'] == 'rfid-scan' }
puts "Scans all time: #{scans.count}"
scans = scans.select { |d| Time.parse(d['created_at']) > Time.parse("March 9, 2013 19:00:00") }
puts "Scans that night: #{scans.count}"

drinks_headers = %w(rfid_tag_id reader_id timestamp beer_id beer_name tap_name)
drink_rows = []
scans.each do |scan_doc|
  scan_created_at = Time.parse(scan_doc['created_at'])
  tap_doc = taps.detect { |t| t['reader_id'] == scan_doc['reader_id'] } || next
  tap_doc['tappings'].each do |tapping_doc|
    tapping_started_at = Time.parse(tapping_doc['started_at'])
    tapping_finished_at = Time.parse(tapping_doc['finished_at'])

    if (tapping_started_at < scan_created_at) && (scan_created_at < tapping_finished_at)
      beer_doc = beers.detect { |b| b['_id'] == tapping_doc['beer_id'] }
      drink_rows << [
        scan_doc['tag_id'],
        scan_doc['reader_id'],
        scan_doc['created_at'],
        beer_doc['_id'],
        beer_doc['name'],
        tap_doc['name']
      ]
    end
  end
end

rating_scan_headers = %w(reader_id rfid_tag_id timestamp)
rating_scan_rows = []
scans.each do |scan_doc|
end

puts "#{taps.count} taps"
puts "#{beers.count} beers"
puts "#{rating_rows.count} ratings"
puts "#{drink_rows.count} drinks"

beer_popularity = beers.map { |beer_doc|
  drink_count = drink_rows.select { |d| d[3] == beer_doc['_id'] }.count
  [drink_count, beer_doc['name']]
}.sort.reverse

puts
puts "="*20
puts

columns = 60

drink_times = drink_rows.map { |d| Time.parse(d[2]) }.sort
timespan = drink_times.last.to_i - drink_times.first.to_i

puts "drinking time: #{timespan}"

slice_length = timespan / columns.to_f

beer_popularity.each do |count, name|
  drinks_per_slice = (0..columns-1).map { |column|
    slice_start = Time.at(drink_times.first + (slice_length * column))
    slice_end   = Time.at(slice_start + slice_length)

    drink_rows.select { |d|
      drank_at = Time.parse(d[2])
      (d[4] == name) && (slice_start < drank_at) && (drank_at < slice_end)
    }.count
  }

  spark = `spark #{drinks_per_slice.join(' ')}`
  header = "#{count} drinks: #{name}"
  puts "#{header.ljust(50)} #{spark}"
end
