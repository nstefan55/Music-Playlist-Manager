require 'fox16'
include Fox

require_relative "../app/models/playlist"
require_relative '../app/models/playlistManager'

class PlaylistView < FXMainWindow
  def initialize(app, playlists)
    super(app, "Playlist Manager", width: 800, height: 600)
    @playlists = playlists

    verticalFrame = FXVerticalFrame.new(self, opts: LAYOUT_FILL_X | LAYOUT_FILL_Y)

    # | PRIKAZI DETALJE PLAYLISTE |

    showPlaylistsDetailsButton = FXButton.new(verticalFrame, "Prikaži detalje playliste")
    showPlaylistsDetailsButton.connect(SEL_COMMAND) do
        showPlaylistDetailsDialog = FXInputDialog.new(self, "Show Playlist Details", "Unesite naziv playliste:")
        showPlaylistDetailsDialog.execute
        nazivPlayliste = showPlaylistDetailsDialog.text
        if !nazivPlayliste.nil? && !nazivPlayliste.empty?
            begin
                playlist = @playlists.find { |p| p.naziv == nazivPlayliste }
                details = playlist.detaljiPlayliste if playlist
                FXMessageBox.information(self, MBOX_OK, "Success", details)
            rescue ArgumentError => e
                FXMessageBox.error(self, MBOX_OK, "Error", e.message)
            end
        end
    end

    # | UREDI NAZIV PLAYLISTE |

    editPaylistNameButton = FXButton.new(verticalFrame, "Uredite naziv Playliste")
    editPaylistNameButton.connect(SEL_COMMAND) do
        editPlaylistNameDialog = FXInputDialog.new(self, "Edit Playlist Name", "Enter the name of the playlist and the new name:")
        editPlaylistNameDialog.execute
        
        nazivPlayliste, noviNaziv = editPlaylistNameDialog.text.split(",")
        if !nazivPlayliste.nil? && !nazivPlayliste.empty? && !noviNaziv.nil? && !noviNaziv.empty?
            begin
                playlist = @playlists.find { |p| p.naziv == nazivPlayliste }
                playlist.urediNaziv(noviNaziv) if playlist
                FXMessageBox.information(self, MBOX_OK, "Success", "Playlist name edited successfully!")
            rescue ArgumentError => e
                FXMessageBox.error(self, MBOX_OK, "Error", e.message)
            end
        end
    end

# | PRIKAZI SVE PLAYLISTE |

    showPlaylistsButton = FXButton.new(verticalFrame, "Show All Playlists")
    showPlaylistsButton.connect(SEL_COMMAND) do
        playliste = prikaziSvePlayliste(@playlists)
        if playliste.empty?
            FXMessageBox.information(self, MBOX_OK, "Info", "No playlists found.")
        else
            FXMessageBox.information(self, MBOX_OK, "Playlists", playliste.join("\n"))
        end
    end

    # | IZBRISI PLAYLISTU |

    deletePlaylistButton = FXButton.new(verticalFrame, "Delete Playlist")
    deletePlaylistButton.connect(SEL_COMMAND) do
        deletePlaylistDialog = FXInputDialog.new(self, "Delete Playlist", "Enter the name of the playlist:")
        deletePlaylistDialog.execute
        nazivPlayliste = deletePlaylistDialog.text
        if !nazivPlayliste.nil? && !nazivPlayliste.empty?
            begin
                obrisiPlaylistu(@playlists, nazivPlayliste)
                FXMessageBox.information(self, MBOX_OK, "Success", "Playlist deleted successfully!")
            rescue ArgumentError => e
                FXMessageBox.error(self, MBOX_OK, "Error", e.message)
            end 
        end
    end

    # | SPREMI PLAYLISTU | 

    savePlaylistButton = FXButton.new(verticalFrame, "Save Playlist")
    savePlaylistButton.connect(SEL_COMMAND) do
        savePlaylistDialog = FXInputDialog.new(self, "Save Playlist", "Enter the name of the playlist to save:")
        savePlaylistDialog.execute
        nazivPlayliste = savePlaylistDialog.text
        if !nazivPlayliste.nil? && !nazivPlayliste.empty?
            begin
                playlist = @playlists.find { |p| p.naziv == nazivPlayliste }
                spremiPlaylistu(playlist) if playlist
                FXMessageBox.information(self, MBOX_OK, "Success", "Playlist saved successfully!")
            rescue ArgumentError => e
                FXMessageBox.error(self, MBOX_OK, "Error", e.message)
            end
        end
    end

    # | UCITAJ PLAYLISTU | 

    loadPlaylistButton = FXButton.new(verticalFrame, "Load Playlist")
    loadPlaylistButton.connect(SEL_COMMAND) do
        loadPlaylistDialog = FXInputDialog.new(self, "Load Playlist", "Enter the name of the playlist to load:")
        loadPlaylistDialog.execute
        nazivPlayliste = loadPlaylistDialog.text
        if !nazivPlayliste.nil? && !nazivPlayliste.empty?
            begin
                playlist = ucitajPlaylistu
                @playlists << playlist if playlist.naziv == nazivPlayliste
                FXMessageBox.information(self, MBOX_OK, "Success", "Playlist loaded successfully!")
            rescue ArgumentError => e
                FXMessageBox.error(self, MBOX_OK, "Error", e.message)
            end
        end
    end
    
    def show
        create
        super(PLACEMENT_SCREEN)
    end
  end
end
