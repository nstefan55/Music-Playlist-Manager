require 'json'

def generate_random_playlists(num_playlists, num_songs_per_playlist)
  playlists = []

  num_playlists.times do |i|
    playlist_name = "Playlist#{i + 1}"
    songs = []

    num_songs_per_playlist.times do
      song_name = "Song#{rand(100..999)}"
      artist = "Artist#{rand(1..50)}"
      album = ["Album#{rand(1..20)}", "/"].sample
      duration = rand(1.0..10.0).round(2)

      song = {
        "naziv" => song_name,
        "izvodac" => artist,
        "album" => album,
        "trajanje" => duration
      }
      songs << song
    end

    playlist = {
      "naziv" => playlist_name,
      "pjesme" => songs
    }
    playlists << playlist
  end

  playlists
end

# Generate 5 playlists with 10 songs each
random_playlists = generate_random_playlists(5, 10)

# Write to a JSON file
File.open("playlists.json", "w") do |file|
  file.write(JSON.pretty_generate(random_playlists))
end

puts "Random playlists JSON file has been created successfully."
