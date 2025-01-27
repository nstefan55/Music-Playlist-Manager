require 'json'

require 'fox16'
include Fox

require_relative "../app/models/playlist"
require_relative "../app/models/playlistManager"

class SongView < FXMainWindow

  include PlaylistManager
  def initialize(app, playlists)
    super(app, "Song Manager", width: 600, height: 600)
    @playlists = playlists


    customFont = FXFont.new(app, "Arial", 14)


    verticalFrame = FXVerticalFrame.new(self, opts: LAYOUT_FILL_X | LAYOUT_FILL_Y | LAYOUT_CENTER_Y, padTop: 20, padBottom: 20)

    label = FXLabel.new(verticalFrame, "Upravljaj pjesmama u playlisti", opts: LAYOUT_CENTER_X, padBottom: 20)
    label.font = customFont

    buttonFrame = FXHorizontalFrame.new(verticalFrame, opts: LAYOUT_CENTER_X, padLeft: 10, padRight: 10)



    # | DODAJ PJESMU U PLAYLISTU |

    addSongButton = FXButton.new(verticalFrame, "Dodaj pjesme u playlistu", opts: BUTTON_NORMAL, width: 150, height: 50, padTop: 15, padBottom: 15, padLeft: 10, padRight: 10)
    addSongButton.font = customFont
    addSongButton.connect(SEL_COMMAND) do
        playlistDialog = FXDialogBox.new(self, "Odaberite playlistu", DECOR_TITLE | DECOR_BORDER)
        playlistComboBox = FXComboBox.new(playlistDialog, 20, nil, 0, COMBOBOX_STATIC | FRAME_SUNKEN | FRAME_THICK)

        @playlists.each { |playlist| playlistComboBox.appendItem(playlist.naziv) }
        playlistComboBox.numVisible = [@playlists.size, 10].min

        buttonFrame = FXHorizontalFrame.new(playlistDialog, LAYOUT_FILL_X | PACK_UNIFORM_WIDTH)
        FXButton.new(buttonFrame, "OK", nil, playlistDialog, FXDialogBox::ID_ACCEPT, FRAME_RAISED | FRAME_THICK | LAYOUT_RIGHT)
        FXButton.new(buttonFrame, "Cancel", nil, playlistDialog, FXDialogBox::ID_CANCEL, FRAME_RAISED | FRAME_THICK | LAYOUT_RIGHT)

        if playlistDialog.execute != 0
            selected_playlist_index = playlistComboBox.currentItem
            nazivPlayliste = @playlists[selected_playlist_index].naziv if selected_playlist_index >= 0

            songNameDialog = FXInputDialog.new(self, "Dodaj pjesme u playlistu", "Unesite naziv pjesme:")
            songNameDialog.execute
            nazivPjesme = songNameDialog.text.strip

            artistNameDialog = FXInputDialog.new(self, "Dodaj pjesme u playlistu", "Unesite ime izvođača:")
            artistNameDialog.execute
            izvodac = artistNameDialog.text.strip

            albumDialog = FXDialogBox.new(self, "Odaberite opciju", DECOR_TITLE | DECOR_BORDER, width: 300, height: 200)
            albumFrame = FXVerticalFrame.new(albumDialog, LAYOUT_FILL_X | LAYOUT_FILL_Y)

            headlineFont = FXFont.new(app, "Arial", 10, FONTWEIGHT_BOLD)
            headlineLabel = FXLabel.new(albumFrame, "Pripada li pjesma određenom albumu?")
            headlineLabel.font = headlineFont

            albumCheckbox = FXCheckButton.new(albumFrame, "DA")
            singleCheckbox = FXCheckButton.new(albumFrame, "Ne")
            albumCheckbox.checkState = true # Default to album

            albumCheckbox.connect(SEL_COMMAND) do
                singleCheckbox.checkState = false if albumCheckbox.checked?
            end

            singleCheckbox.connect(SEL_COMMAND) do
                albumCheckbox.checkState = false if singleCheckbox.checked?
            end

            buttonFrame = FXHorizontalFrame.new(albumFrame, LAYOUT_FILL_X | PACK_UNIFORM_WIDTH)
            FXButton.new(buttonFrame, "OK", nil, albumDialog, FXDialogBox::ID_ACCEPT, FRAME_RAISED | FRAME_THICK | LAYOUT_RIGHT)
            FXButton.new(buttonFrame, "Cancel", nil, albumDialog, FXDialogBox::ID_CANCEL, FRAME_RAISED | FRAME_THICK | LAYOUT_RIGHT)

            album = "/"
            if albumDialog.execute != 0
                if albumCheckbox.checked?
                    albumNameDialog = FXInputDialog.new(self, "Dodaj pjesme u playlistu", "Unesite naziv Albuma:")
                    albumNameDialog.execute
                    album = albumNameDialog.text.strip
                end
            end

            lengthDialog = FXInputDialog.new(self, "Dodaj pjesme u playlistu", "Unesite duljinu trajanja pjesme (u minutama): ")
            lengthDialog.execute
            trajanje_input = lengthDialog.text.strip.to_f

            begin
                trajanje = validDurationFormat(trajanje_input)
            rescue ArgumentError => e
                FXMessageBox.error(self, MBOX_OK, "Greška", e.message)
                next
            end

            if !nazivPlayliste.nil? && !nazivPlayliste.empty? && !nazivPjesme.empty? && !izvodac.empty? && !album.empty? && trajanje > 0
                begin
                    playlist = @playlists.find { |p| p.naziv == nazivPlayliste }
                    if playlist
                        song = Song.new(nazivPjesme, izvodac, album, trajanje)
                        result = playlist.dodajPjesmu(song)
                        spremiPlaylistu(playlist)
                        FXMessageBox.information(self, MBOX_OK, "Uspjeh", result)
                    else
                        FXMessageBox.error(self, MBOX_OK, "Greška", "Playlista pod nazivom:  '#{nazivPlayliste}'  ne postoji!")
                    end
                rescue ArgumentError => e
                    FXMessageBox.error(self, MBOX_OK, "Greška", e.message)
                end
            else
                FXMessageBox.error(self, MBOX_OK, "Greška", "Molim vas odaberite i unesite sve tražene parametre!")
            end
        end
    end







    # | IZBRISI PJESMU IZ PLAYLISTE |

    deleteSongButton = FXButton.new(verticalFrame, "Izbriši pjesme iz playliste", opts: BUTTON_NORMAL, width: 150, height: 50, padTop: 15, padBottom: 15, padLeft: 10, padRight: 10)
    deleteSongButton.font = customFont
    deleteSongButton.connect(SEL_COMMAND) do
        existing_playlists = ucitajSvePlayliste

        playlist_names = existing_playlists.map { |p| p.naziv }

        playlistDialog = FXDialogBox.new(self, "Odaberite playlistu", DECOR_TITLE | DECOR_BORDER)
        playlistComboBox = FXComboBox.new(playlistDialog, 20, nil, 0, COMBOBOX_STATIC | FRAME_SUNKEN | FRAME_THICK)
        playlist_names.each { |name| playlistComboBox.appendItem(name) }
        playlistComboBox.numVisible = [playlist_names.size, 10].min

        buttonFrame = FXHorizontalFrame.new(playlistDialog, LAYOUT_FILL_X | PACK_UNIFORM_WIDTH)
        FXButton.new(buttonFrame, "OK", nil, playlistDialog, FXDialogBox::ID_ACCEPT, FRAME_RAISED | FRAME_THICK | LAYOUT_RIGHT)
        FXButton.new(buttonFrame, "Cancel", nil, playlistDialog, FXDialogBox::ID_CANCEL, FRAME_RAISED | FRAME_THICK | LAYOUT_RIGHT)

        if playlistDialog.execute != 0
            selected_playlist_index = playlistComboBox.currentItem
            nazivPlayliste = playlist_names[selected_playlist_index] if selected_playlist_index >= 0

            if nazivPlayliste
                selected_playlist = existing_playlists.find { |p| p.naziv == nazivPlayliste }

                if selected_playlist.pjesme.empty?
                    FXMessageBox.error(self, MBOX_OK, "Greška", "Odabrana playlista: '#{nazivPlayliste}' je prazna!")
                    next
                end

                song_names = selected_playlist.pjesme.map { |s| s.naziv }

                songDialog = FXDialogBox.new(self, "Odaberite pjesmu koju želite pobrisati iz playliste", DECOR_TITLE | DECOR_BORDER)
                songComboBox = FXComboBox.new(songDialog, 20, nil, 0, COMBOBOX_STATIC | FRAME_SUNKEN | FRAME_THICK)
                song_names.each { |name| songComboBox.appendItem(name) }
                songComboBox.numVisible = [song_names.size, 10].min

                buttonFrame = FXHorizontalFrame.new(songDialog, LAYOUT_FILL_X | PACK_UNIFORM_WIDTH)
                FXButton.new(buttonFrame, "OK", nil, songDialog, FXDialogBox::ID_ACCEPT, FRAME_RAISED | FRAME_THICK | LAYOUT_RIGHT)
                FXButton.new(buttonFrame, "Cancel", nil, songDialog, FXDialogBox::ID_CANCEL, FRAME_RAISED | FRAME_THICK | LAYOUT_RIGHT)

                if songDialog.execute != 0
                    selected_song_index = songComboBox.currentItem
                    nazivPjesme = song_names[selected_song_index] if selected_song_index >= 0

                    if nazivPjesme
                        selected_playlist.obrisiPjesmu(nazivPjesme)
                        spremiPlaylistu(selected_playlist)
                        FXMessageBox.information(self, MBOX_OK, "Uspjeh", "Pjesma '#{nazivPjesme}' uspješno obrisana iz playliste '#{nazivPlayliste}'.")
                    else
                        FXMessageBox.error(self, MBOX_OK, "Greška", "Niste odabrali pjesmu!")
                    end
                end
            else
                FXMessageBox.error(self, MBOX_OK, "Greška", "Niste odabrali playlistu.")
            end
        end
    end





    # | FILTER: IZVODAC |

    filterByArtistButton = FXButton.new(verticalFrame, "Filtriraj pjesme prema izvođaču", opts: BUTTON_NORMAL, width: 150, height: 50, padTop: 15, padBottom: 15, padLeft: 10, padRight: 10)
    filterByArtistButton.font = customFont
    filterByArtistButton.connect(SEL_COMMAND) do
        filterArtistDialog = FXInputDialog.new(self, "Filter by Artist", "Unesite ime izvođača:")
        filterArtistDialog.execute
        artistName = filterArtistDialog.text.strip

        if !artistName.nil? && !artistName.empty?
            begin
                existing_playlists = ucitajSvePlayliste

                ordrNum = 1
                filteredSongs = existing_playlists.flat_map do |playlist|
                    playlist.pjesme.select { |song| song.izvodac == artistName }.map do |song|
                        displayFilteredSongs = "##{ordrNum} |  Playlist: #{playlist.naziv}  |  Naziv: #{song.naziv}  |  Album: #{song.album}  |  Trajanje: #{song.trajanje} min"
                        ordrNum += 1
                        displayFilteredSongs
                    end
                end

                if filteredSongs.empty?
                    FXMessageBox.information(self, MBOX_OK, "Pjesme nisu pronađene!", "Ne postoje pjesme od sljedećeg izvođača: '#{artistName}'.")
                else
                    songListWindow = FXMainWindow.new(app, "Filtrirane pjesme prema izvođaču:  '#{artistName}' ", width: 400, height: 300)
                    songListFrame = FXVerticalFrame.new(songListWindow, opts: LAYOUT_FILL_X | LAYOUT_FILL_Y)

                    headlineFont = FXFont.new(app, "Arial", 12, FONTWEIGHT_BOLD)
                    headlineLabel = FXLabel.new(songListFrame, "Ukupan broj pjesama: #{filteredSongs.size}")
                    headlineLabel.font = headlineFont

                    songList = FXList.new(songListFrame, opts: LAYOUT_FILL_X | LAYOUT_FILL_Y)
                    filteredSongs.each do |song|
                        songList.appendItem(song)
                    end

                    songListWindow.create
                    songListWindow.show(PLACEMENT_SCREEN)
                end
            rescue StandardError => e
                FXMessageBox.error(self, MBOX_OK, "Greška", "Pojavila se greška: #{e.message}")
            end
        else
            FXMessageBox.error(self, MBOX_OK, "Greška", "Molim vas unesite ime izvođača.")
        end
    end





    # | FILTER: ALBUM |

    filterByAlbumButton = FXButton.new(verticalFrame, "Filtriraj pjesme prema albumu", opts: BUTTON_NORMAL, width: 150, height: 50, padTop: 15, padBottom: 15, padLeft: 10, padRight: 10)
    filterByAlbumButton.font = customFont
    filterByAlbumButton.connect(SEL_COMMAND) do
        filterAlbumDialog = FXInputDialog.new(self, "Filter by Album", "Unesite ime albuma:")
        filterAlbumDialog.execute
        albumName = filterAlbumDialog.text.strip

        if !albumName.nil? && !albumName.empty?
            begin
                existing_playlists = ucitajSvePlayliste

                ordrNum = 1
                filteredSongs = existing_playlists.flat_map do |playlist|
                    playlist.pjesme.select { |song| song.album == albumName }.map do |song|
                        displayFilteredSongs = "##{ordrNum} |  Playlist: #{playlist.naziv}  |  Naziv: #{song.naziv}  |  Izvođač: #{song.izvodac}  |  Trajanje: #{song.trajanje} min"
                        ordrNum += 1
                        displayFilteredSongs
                    end
                end

                if filteredSongs.empty?
                    FXMessageBox.information(self, MBOX_OK, "Pjesme nisu pronađene!", "Ne postoje pjesme iz sljedećeg albuma: '#{albumName}'.")
                else
                    songListWindow = FXMainWindow.new(app, "Filtrirane pjesme prema albumu:  '#{albumName}' ", width: 400, height: 300)
                    songListFrame = FXVerticalFrame.new(songListWindow, opts: LAYOUT_FILL_X | LAYOUT_FILL_Y)

                    headlineFont = FXFont.new(app, "Arial", 12, FONTWEIGHT_BOLD)
                    headlineLabel = FXLabel.new(songListFrame, "Ukupan broj pjesama: #{filteredSongs.size}")
                    headlineLabel.font = headlineFont

                    songList = FXList.new(songListFrame, opts: LAYOUT_FILL_X | LAYOUT_FILL_Y)
                    filteredSongs.each do |song|
                        songList.appendItem(song)
                    end

                    songListWindow.create
                    songListWindow.show(PLACEMENT_SCREEN)
                end
            rescue StandardError => e
                FXMessageBox.error(self, MBOX_OK, "Greška", "Pojavila se greška: #{e.message}")
            end
        else
            FXMessageBox.error(self, MBOX_OK, "Greška", "Molim vas unesite ime albuma.")
        end
    end


    # | FILTER: TRAJANJE |

    filterByDurationButton = FXButton.new(verticalFrame, "Filtriraj pjesme prema duljini trajanja", opts: BUTTON_NORMAL, width: 150, height: 50, padTop: 15, padBottom: 15, padLeft: 10, padRight: 10)
    filterByDurationButton.font = customFont
    filterByDurationButton.connect(SEL_COMMAND) do
        filterDurationDialog = FXInputDialog.new(self, "Filter by Duration", "Unesite duljinu trajanja:")
        filterDurationDialog.execute
        duration_input = filterDurationDialog.text.strip

        if !duration_input.nil? && !duration_input.empty?
            begin
                duration = duration_input.to_f
                min_duration = duration
                max_duration = duration + 0.59

                existing_playlists = ucitajSvePlayliste

                ordrNum = 1
                filteredSongs = existing_playlists.flat_map do |playlist|
                    playlist.pjesme.select { |song| song.trajanje.between?(min_duration, max_duration) }.map do |song|
                        displayFilteredSongs = "##{ordrNum} |  Playlist: #{playlist.naziv}  |  Naziv: #{song.naziv}  |  Izvođač: #{song.izvodac}  |  Album: #{song.album}  |  Trajanje: #{song.trajanje} min"
                        ordrNum += 1
                        displayFilteredSongs
                    end
                end

                if filteredSongs.empty?
                    FXMessageBox.information(self, MBOX_OK, "Pjesme nisu pronađene!", "Ne postoje pjesme prema trajanju od #{duration_input} min.")
                else
                    songListWindow = FXMainWindow.new(app, "Filtrirane pjesme prema trajanju od: #{duration_input} min ", width: 400, height: 300)
                    songListFrame = FXVerticalFrame.new(songListWindow, opts: LAYOUT_FILL_X | LAYOUT_FILL_Y)

                    headlineFont = FXFont.new(app, "Arial", 12, FONTWEIGHT_BOLD)
                    headlineLabel = FXLabel.new(songListFrame, "Ukupan broj pjesama: #{filteredSongs.size}")
                    headlineLabel.font = headlineFont

                    songList = FXList.new(songListFrame, opts: LAYOUT_FILL_X | LAYOUT_FILL_Y)
                    filteredSongs.each do |song|
                        songList.appendItem(song)
                    end

                    songListWindow.create
                    songListWindow.show(PLACEMENT_SCREEN)
                end
            rescue StandardError => e
                FXMessageBox.error(self, MBOX_OK, "Greška", "Pojavila se greška: #{e.message}")
            end
        else
            FXMessageBox.error(self, MBOX_OK, "Greška", "Molim vas unesite duljinu trajanja za filter.")
        end
    end



    def show
        create
        super(PLACEMENT_SCREEN)
    end
  end
end
