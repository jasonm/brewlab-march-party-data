require 'csv'
require 'ostruct'

rows = CSV.parse(open('drinks.csv').read)[1..-1]

drinks = rows.map { |row|
  OpenStruct.new({
    rfid_tag_id: row[0],
    reader_id: row[1],
    timestamp: Date.parse(row[2]),
    beer_id:   row[3],
    beer_name: row[4],
    tap_name:  row[5]
  })
}

drinks = drinks.reject { |drink|
  drink.rfid_tag_id == ''
}

puts drinks.length

# Structure:
# rfid_tag_id,reader_id,timestamp,beer_id,beer_name,tap_name
# 0008820996,c9f9b211f41398cb73a2e3e41ad8da00,2013-03-09 23:37:52 -0800,c9f9b211f41398cb73a2e3e41afa5b27,Todd Rungren Rye-Saison,Indoor Tap 3

# 1. Going back for seconds (and thirds, and fourths, and fifths)

personal_favorites = drinks.map { |drink| [drink.rfid_tag_id, drink.beer_name] }.inject({}) { |hash, pair| hash[pair] ||= 0 ; hash[pair] += 1 ; hash }

# The long tail of personal favorites:
require 'pp'
pp personal_favorites.sort_by { |pair, count| -count }.select { |pair, count| count > 1 }

# Aggregate personal favories:
# 1. Belgian Trippel - One Belgian afficionado went back 5 times 
# 2. Troglodyte ESBrown - 4 times and a couple of folks came back 3 times
# 3. The Skeptic Red IPA - 4 times
#
# Andrew's Rye Bock, Love Potion #4, Cyclhops, and the Best One Red Ale were our personal-fave runners-up, each with a few people going back not just for seconds, but thirds.

#Detailed few:
#  [["0009411932", "Belgian Trippel"], 5],
#  [["0008820372", "The Skeptic Red IPA"], 4],
#  [["0006546271", "Troglodyte ESBrown"], 4],
#  [["0008821823", "Troglodyte ESBrown"], 3],
#  [["0006545849", "Troglodyte ESBrown"], 3],
#  [["0009412831", "Andrew's Rye Bock"], 3],
#  [["0013327177", "Andrew's Rye Bock"], 3],
#  [["0008820504", "Andrew's Rye Bock"], 3],
#  [["0013330083", "Love Potion #4 Oyster Stout"], 3],
#  [["0013326498", "Love Potion #4 Oyster Stout"], 3],
#  [["0008820005", "The Cyclhops Imperial IPA"], 3],
#  [["0006541764", "The Cyclhops Imperial IPA"], 3],
#  [["0008821398", "Belgian Trippel"], 3],
#  [["0008822110", "Belgian Trippel"], 3],
#  [["0008820540", "Belgian Trippel"], 3],
#  [["0008822025", "The Best One Red Ale"], 3],

# 2. Pour velocity over time
# Choose a window size and offset size
# For each beer, bucket pours
#
# see analyze.R
