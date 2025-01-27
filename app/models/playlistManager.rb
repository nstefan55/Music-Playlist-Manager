require 'json'
require 'fox16'
include Fox
require_relative 'playlist'
require_relative 'song'


module PlaylistManager
    def stvoriNovuPlaylistu(naziv)
        playlist = Playlist.new(naziv)
        spremiPlaylistu(playlist)
        playlist
    end

    def prikaziSvePlayliste(playliste)
        playliste.each {|playlist| puts "#{playlist.naziv} - #{playlist.pjesme.size} pjesama"}
    end

    def obrisiPlaylistu(playliste, naziv)
        playliste.delete_if {|playlist| playlist.naziv == naziv}
    end

    def filtrirajPoIzvodacu(playlist, izvodac)
        playlist.pjesme.select {|p| p.izvodac == izvodac}
    end

    def filtrirajPoAlbumu(playlist, album)
        playlist.pjesme.select {|p| p.album == album}
    end

    def filtrirajPoTrajanju(playlist, min, max)
        playlist.pjesme.select {|p| p.trajanje.between?(min, max)}
    end


    private

    def spremiPlaylistu(playlist)
        file_path = 'data/playlists.json'

        # Read existing playlists from the file
        existingPlaylists = []
        if File.exist?(file_path) && !File.zero?(file_path)
            jsonData = File.read(file_path)
            existingPlaylists = JSON.parse(jsonData)
        end

        begin
            # Check if the playlist already exists
            existing_playlist = existingPlaylists.find { |p| p['naziv'] == playlist.naziv }
            if existing_playlist
                # Update the existing playlist with the current songs
                existing_playlist['pjesme'] = playlist.pjesme.map do |pjesma|
                    {
                        naziv: pjesma.naziv,
                        izvodac: pjesma.izvodac,
                        album: pjesma.album,
                        trajanje: pjesma.trajanje
                    }
                end
            else
                # Create a new playlist with an empty list of songs
                playlistData = {
                    'naziv' => playlist.naziv,
                    'pjesme' => [] # Empty list of songs
                }
                existingPlaylists << playlistData
            end

            # Write back to the file
            jsonData = JSON.generate(existingPlaylists)
            File.write(file_path, jsonData)
            puts "Playlista pod nazivom:  '#{playlist.naziv}'  je uspješno spremljena u datoteku."

        rescue StandardError => e
            puts "Greška:  #{e.message}"
            FXMessageBox.error(self, MBOX_OK, "Error", "Pojavila se greška prilikom spremanja playliste!")
        end
    end



    def ucitajSvePlayliste
        file_path = 'data/playlists.json'

        if File.exist?(file_path) && !File.zero?(file_path)
            jsonData = File.read(file_path)
            playlistsData = JSON.parse(jsonData)

            playlists = playlistsData.map do |playlistData|
                playlist = Playlist.new(playlistData['naziv'])
                playlistData['pjesme'].each do |pjesmaData|
                    pjesma = Song.new(
                    pjesmaData['naziv'],
                    pjesmaData['izvodac'],
                    pjesmaData['album'],
                    pjesmaData['trajanje']
                    )
                    playlist.dodajPjesmu(pjesma)
                end
                playlist
            end
        end
        playlists
    end
end