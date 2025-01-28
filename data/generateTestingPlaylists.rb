require 'json'

def generateRandomPlaylistsJSON(numPlaylists, numSongsPerPlaylist)
  playlists = []

  numPlaylists.times do |i|
    playlist_name = "Playlist#{i + 1}"
    songs = []

    numSongsPerPlaylist.times do
      songName = "Song#{rand(100..999)}"
      artist = "Artist#{rand(1..50)}"
      album = ["Album#{rand(1..20)}", "/"].sample
      duration = rand(1.0..10.0).round(2)

      song = {
        "naziv" => songName,
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

randomPlaylists = generateRandomPlaylistsJSON(5, 10)

File.open("playlists.json", "w") do |file|
  file.write(JSON.pretty_generate(random_playlists))
end

puts "Random playlists JSON file has been created successfully."
