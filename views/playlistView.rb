require 'json'
require 'fox16'
include Fox

require_relative "../app/models/playlist"
require_relative '../app/models/playlistManager'

class PlaylistView < FXMainWindow
  include PlaylistManager
  def initialize(app, playlists)
    super(app, "Playlist Manager", width: 800, height: 600)
    @playlists = playlists

    customFont = FXFont.new(app, "Arial", 14)

    verticalFrame = FXVerticalFrame.new(self, opts: LAYOUT_FILL_X | LAYOUT_FILL_Y | LAYOUT_CENTER_Y, padTop: 20, padBottom: 20)

    label = FXLabel.new(verticalFrame, "Upravljaj playlistama", opts: LAYOUT_CENTER_X, padBottom: 20)
    label.font = customFont

    buttonFrame = FXHorizontalFrame.new(verticalFrame, opts: LAYOUT_CENTER_X, padLeft: 10, padRight: 10)

    # | PRIKAZI DETALJE PLAYLISTE |
    showPlaylistsDetailsButton = FXButton.new(verticalFrame, "Prikaži detalje playliste", opts: BUTTON_NORMAL, width: 150, height: 50, padTop: 15, padBottom: 15, padLeft: 10, padRight: 10)
    showPlaylistsDetailsButton.font = customFont
    showPlaylistsDetailsButton.connect(SEL_COMMAND) do
        existing_playlists = ucitajSvePlayliste

        playlistDialog = FXDialogBox.new(self, "Odaberite playlistu", DECOR_TITLE | DECOR_BORDER)
        playlistComboBox = FXComboBox.new(playlistDialog, 20, nil, 0, COMBOBOX_STATIC | FRAME_SUNKEN | FRAME_THICK)
        
        existing_playlists.each { |playlist| playlistComboBox.appendItem(playlist.naziv) }
        playlistComboBox.numVisible = [existing_playlists.size, 10].min

        buttonFrame = FXHorizontalFrame.new(playlistDialog, LAYOUT_FILL_X | PACK_UNIFORM_WIDTH)
        FXButton.new(buttonFrame, "OK", nil, playlistDialog, FXDialogBox::ID_ACCEPT, FRAME_RAISED | FRAME_THICK | LAYOUT_RIGHT)
        FXButton.new(buttonFrame, "Cancel", nil, playlistDialog, FXDialogBox::ID_CANCEL, FRAME_RAISED | FRAME_THICK | LAYOUT_RIGHT)

        if playlistDialog.execute != 0
            selected_playlist_index = playlistComboBox.currentItem
            nazivPlayliste = existing_playlists[selected_playlist_index].naziv if selected_playlist_index >= 0

            if !nazivPlayliste.nil? && !nazivPlayliste.empty?
                begin
                    playlist = existing_playlists.find { |p| p.naziv == nazivPlayliste }
                    if playlist
                        detailsWindow = FXMainWindow.new(app, "Detalji Playliste: #{nazivPlayliste.upcase}", width: 400, height: 400)
                        detailsFrame = FXVerticalFrame.new(detailsWindow, opts: LAYOUT_FILL_X | LAYOUT_FILL_Y)

                        boldFont14 = FXFont.new(app, "Arial", 14, FONTWEIGHT_BOLD)
                        boldFont12 = FXFont.new(app, "Arial", 12, FONTWEIGHT_BOLD)
                        normalFont = FXFont.new(app, "Arial", 12)

                        nazivLabel = FXLabel.new(detailsFrame, "Naziv Playliste: #{playlist.naziv}", opts: LAYOUT_LEFT)
                        nazivLabel.font = boldFont14

                        brojPjesamaLabel = FXLabel.new(detailsFrame, "Broj pjesama: #{playlist.pjesme.size}", opts: LAYOUT_LEFT)
                        brojPjesamaLabel.font = boldFont12

                        ukupnoTrajanje = playlist.pjesme.sum(&:trajanje)
                        formatiranoTrajanje = formatTrajanje(ukupnoTrajanje)
                        trajanjeLabel = FXLabel.new(detailsFrame, "Ukupno trajanje: #{formatiranoTrajanje}", opts: LAYOUT_LEFT)
                        trajanjeLabel.font = boldFont12

                        songListLabel = FXLabel.new(detailsFrame, "Popis pjesama:", opts: LAYOUT_LEFT)
                        songListLabel.font = boldFont12

                        playlist.pjesme.each do |song|
                            songDetails = "Naziv: #{song.naziv}  |  Album: #{song.album}  |  Trajanje: #{song.trajanje} min"
                            songLabel = FXLabel.new(detailsFrame, songDetails, opts: LAYOUT_LEFT)
                            songLabel.font = normalFont
                            
                            # Add a separator or padding for spacing
                            FXHorizontalSeparator.new(detailsFrame, opts: LAYOUT_FILL_X | SEPARATOR_GROOVE)
                        end

                        detailsWindow.create
                        detailsWindow.show(PLACEMENT_SCREEN)
                    else
                        FXMessageBox.error(self, MBOX_OK, "Greška", "Playlista nije pronađena!")
                    end
                rescue ArgumentError => e
                    FXMessageBox.error(self, MBOX_OK, "Greška", e.message)
                end
            end
        end
    end



    # | UREDI NAZIV PLAYLISTE |
    editPaylistNameButton = FXButton.new(verticalFrame, "Uredite naziv playliste", opts: BUTTON_NORMAL, width: 150, height: 50, padTop: 15, padBottom: 15, padLeft: 10, padRight: 10)
    editPaylistNameButton.font = customFont
    editPaylistNameButton.connect(SEL_COMMAND) do
    existing_playlists = ucitajSvePlayliste

    playlistDialog = FXDialogBox.new(self, "Odaberite playlistu", DECOR_TITLE | DECOR_BORDER)
    playlistComboBox = FXComboBox.new(playlistDialog, 20, nil, 0, COMBOBOX_STATIC | FRAME_SUNKEN | FRAME_THICK)
    
    existing_playlists.each { |playlist| playlistComboBox.appendItem(playlist.naziv) }
    playlistComboBox.numVisible = [existing_playlists.size, 10].min

    buttonFrame = FXHorizontalFrame.new(playlistDialog, LAYOUT_FILL_X | PACK_UNIFORM_WIDTH)
    FXButton.new(buttonFrame, "OK", nil, playlistDialog, FXDialogBox::ID_ACCEPT, FRAME_RAISED | FRAME_THICK | LAYOUT_RIGHT)
    FXButton.new(buttonFrame, "Cancel", nil, playlistDialog, FXDialogBox::ID_CANCEL, FRAME_RAISED | FRAME_THICK | LAYOUT_RIGHT)

    if playlistDialog.execute != 0
        selected_playlist_index = playlistComboBox.currentItem
        nazivPlayliste = existing_playlists[selected_playlist_index].naziv if selected_playlist_index >= 0

        if !nazivPlayliste.nil? && !nazivPlayliste.empty?
            newNameDialog = FXInputDialog.new(self, "Uredite naziv playliste", "Unesite novi naziv za playlistu:")
            newNameDialog.execute
            noviNaziv = newNameDialog.text.strip

            if !noviNaziv.nil? && !noviNaziv.empty?
                begin
                    playlist = existing_playlists.find { |p| p.naziv == nazivPlayliste }
                    if playlist
                        old_name = playlist.naziv
                        playlist.urediNaziv(noviNaziv)
                        spremiPlaylistu(playlist, old_name)
                        FXMessageBox.information(self, MBOX_OK, "Uspjeh", "Naziv playliste uspješno promijenjen!")
                    else
                        FXMessageBox.error(self, MBOX_OK, "Greška", "Playlista nije pronađena!")
                    end
                rescue ArgumentError => e
                    FXMessageBox.error(self, MBOX_OK, "Greška", e.message)
                end
            else
                FXMessageBox.error(self, MBOX_OK, "Greška", "Novi naziv ne može biti prazan!")
                end
            end
        end
    end



    # | PRIKAZI SVE PLAYLISTE |
    showPlaylistsButton = FXButton.new(verticalFrame, "Prikazi popis svih playlista", opts: BUTTON_NORMAL, width: 150, height: 50, padTop: 15, padBottom: 15, padLeft: 10, padRight: 10)
    showPlaylistsButton.font = customFont
    showPlaylistsButton.connect(SEL_COMMAND) do
        existing_playlists = ucitajSvePlayliste

        if existing_playlists.empty?
            FXMessageBox.information(self, MBOX_OK, "Info", "Nisu pronađene playliste.")
        else
            playlistsWindow = FXMainWindow.new(app, "Sve Playliste", width: 400, height: 300)
            playlistsFrame = FXVerticalFrame.new(playlistsWindow, opts: LAYOUT_FILL_X | LAYOUT_FILL_Y)

            boldFont14 = FXFont.new(app, "Arial", 14, FONTWEIGHT_BOLD)
            boldFont12 = FXFont.new(app, "Arial", 12, FONTWEIGHT_BOLD)
            normalFont = FXFont.new(app, "Arial", 12)

            totalPlaylistsLabel = FXLabel.new(playlistsFrame, "Broj učitanih playlista: #{existing_playlists.size}", opts: LAYOUT_CENTER_X, padBottom: 15)
            totalPlaylistsLabel.font = boldFont14

            FXHorizontalSeparator.new(playlistsFrame, opts: LAYOUT_FILL_X | SEPARATOR_GROOVE)

            existing_playlists.each do |playlist|
                nazivLabel = FXLabel.new(playlistsFrame, "Naziv Playliste: #{playlist.naziv}", opts: LAYOUT_LEFT)
                nazivLabel.font = boldFont12

                brojPjesamaLabel = FXLabel.new(playlistsFrame, "Broj Pjesama: #{playlist.pjesme.size}", opts: LAYOUT_LEFT)
                brojPjesamaLabel.font = boldFont12

                FXHorizontalSeparator.new(playlistsFrame, opts: LAYOUT_FILL_X | SEPARATOR_GROOVE)
            end

            playlistsWindow.create
            playlistsWindow.show(PLACEMENT_SCREEN)
        end
    end




    # | IZBRISI PLAYLISTU |
    deletePlaylistButton = FXButton.new(verticalFrame, "Obriši playliste", opts: BUTTON_NORMAL, width: 150, height: 50, padTop: 15, padBottom: 15, padLeft: 10, padRight: 10)
    deletePlaylistButton.font = customFont
    deletePlaylistButton.connect(SEL_COMMAND) do
        existing_playlists = ucitajSvePlayliste

        playlistDialog = FXDialogBox.new(self, "Obriši playliste", DECOR_TITLE | DECOR_BORDER)

        headlineFont = FXFont.new(app, "Arial", 10, FONTWEIGHT_BOLD)
            headlineLabel = FXLabel.new(playlistDialog, "Odaberite playlistu ili napišite naziv playliste koju želite obrisati")
            headlineLabel.font = headlineFont


        playlistComboBox = FXComboBox.new(playlistDialog, 20, nil, 0, COMBOBOX_STATIC | FRAME_SUNKEN | FRAME_THICK)

        
        existing_playlists.each { |playlist| playlistComboBox.appendItem(playlist.naziv) }
        playlistComboBox.numVisible = [existing_playlists.size, 10].min

        manualEntryField = FXTextField.new(playlistDialog, 20, nil, 0, TEXTFIELD_NORMAL)

        buttonFrame = FXHorizontalFrame.new(playlistDialog, LAYOUT_FILL_X | PACK_UNIFORM_WIDTH)
        FXButton.new(buttonFrame, "OK", nil, playlistDialog, FXDialogBox::ID_ACCEPT, FRAME_RAISED | FRAME_THICK | LAYOUT_RIGHT)
        FXButton.new(buttonFrame, "Cancel", nil, playlistDialog, FXDialogBox::ID_CANCEL, FRAME_RAISED | FRAME_THICK | LAYOUT_RIGHT)

        if playlistDialog.execute != 0
            selected_playlist_index = playlistComboBox.currentItem
            nazivPlayliste = if selected_playlist_index >= 0
                            existing_playlists[selected_playlist_index].naziv
                            else
                            manualEntryField.text.strip
                            end

            if !nazivPlayliste.nil? && !nazivPlayliste.empty?
                begin
                    obrisiPlaylistu(existing_playlists, nazivPlayliste)

                    file_path = 'data/playlists.json'
                    jsonData = JSON.generate(existing_playlists.map { |playlist| { 'naziv' => playlist.naziv, 'pjesme' => playlist.pjesme.map { |song| { 'naziv' => song.naziv, 'izvodac' => song.izvodac, 'album' => song.album, 'trajanje' => song.trajanje } } } })
                    File.write(file_path, jsonData)

                    FXMessageBox.information(self, MBOX_OK, "Uspjeh", "Playlista pod nazivom '#{nazivPlayliste}' je uspješno obrisana!")
                rescue ArgumentError => e
                    FXMessageBox.error(self, MBOX_OK, "Greška", e.message)
                end
            else
                FXMessageBox.error(self, MBOX_OK, "Greška", "Molim vas unesite ispravan naziv playliste.")
            end
        end
    end


    
    def show
        create
        super(PLACEMENT_SCREEN)
    end
  end
end
