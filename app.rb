require 'fox16'
include Fox

require_relative 'views/playlistView'
require_relative 'views/songView'

require_relative "app/models/playlist"
require_relative "app/models/playlistManager"
require_relative "app/models/song"
require_relative "app/utils/formatLength"


class MusicPlaylistManagerApp < FXMainWindow

    include PlaylistManager

    def initialize(app)
        super(app, "Music Playlist Manager", width: 800, height: 600)

        begin
            @playlists = ucitajSvePlayliste
        rescue StandardError => e
            puts "Greška prilikom učitavanja playlista: #{e.message}"
        end


        customFont = FXFont.new(app, "Arial", 14) 

        
        verticalFrame = FXVerticalFrame.new(self, opts: LAYOUT_FILL_X | LAYOUT_FILL_Y | LAYOUT_CENTER_Y, padTop: 20, padBottom: 20)

        label = FXLabel.new(verticalFrame, "Dobrodošli na Music Playlist Manager!", opts: LAYOUT_CENTER_X, padBottom: 20)
        label.font = customFont

        buttonFrame = FXHorizontalFrame.new(verticalFrame, opts: LAYOUT_CENTER_X, padLeft: 10, padRight: 10)



        # | CREATE PLAYLISTS BUTTON |

        playlistFeaturesButton = FXButton.new(buttonFrame, "Stvori Novu Playlistu", opts: BUTTON_NORMAL, width: 150, height: 50, padTop: 15, padBottom: 15, padLeft: 10, padRight: 10)
        playlistFeaturesButton.font = customFont
        playlistFeaturesButton.connect(SEL_COMMAND) do
            puts "Button Clicked!"

            # | STVORI NOVU PLAYLISTU |

            createPlaylistDialog = FXInputDialog.new(self, "Stvori Novu Playlistu", "Unesite naziv playliste:")
            createPlaylistDialog.execute
            nazivPlayliste = createPlaylistDialog.text

            if !nazivPlayliste.nil? && !nazivPlayliste.empty?
                existing_playlists = ucitajSvePlayliste
                if existing_playlists.any? { |playlist| playlist.naziv == nazivPlayliste }
                    FXMessageBox.error(self, MBOX_OK, "Greška", "Playlista '#{nazivPlayliste}' već postoji!")
                else
                    begin
                        stvoriNovuPlaylistu(nazivPlayliste)
                        FXMessageBox.information(self, MBOX_OK, "Uspjeh", "Playlista uspješno stvorena!")
                    rescue ArgumentError => e
                        FXMessageBox.error(self, MBOX_OK, "Greška", e.message)
                    end
                end
            end
        end
    
        # | MANAGE PLAYLISTS BUTTON |

        playlistFeaturesButton = FXButton.new(buttonFrame, "Upravljaj playlistama", opts: BUTTON_NORMAL, width: 150, height: 50, padTop: 15, padBottom: 15, padLeft: 10, padRight: 10)
        playlistFeaturesButton.font = customFont
        playlistFeaturesButton.connect(SEL_COMMAND) do
            puts "Button Clicked!"
            
            PlaylistView.new(app, @playlists).show
        end


        # | CREATE PLAYLISTS BUTTON |

        songFeaturesButton = FXButton.new(buttonFrame, "Upravljaj pjesmama", opts: BUTTON_NORMAL, width: 150, height: 50, padTop: 15, padBottom: 15, padLeft: 10, padRight: 10)
        songFeaturesButton.font = customFont
        songFeaturesButton.connect(SEL_COMMAND) do
            puts "Button Clicked!"
            SongView.new(app, @playlists).show
        end
    end

    def create
        super
        show(PLACEMENT_SCREEN)
    end
end

if __FILE__ == $0
    FXApp.new do |app|
        MusicPlaylistManagerApp.new(app)
        app.create
        app.run
    end
end
