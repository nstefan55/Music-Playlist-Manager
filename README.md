
# Music Playlist Manager

Music Playlist Manager is a Ruby application with a graphical user interface (GUI) that allows users to manage their music playlists. The application provides functionalities to create, view, edit, and delete playlists, as well as filter songs by various criteria such as artist, album, and duration.

## Features

- **Create New Playlists**: Easily create new playlists and add songs to them.
- **View Playlist Details**: View detailed information about each playlist, including the number of songs and total duration.
- **Edit Playlists**: Modify existing playlists by adding or removing songs.
- **Delete Playlists**: Remove playlists that are no longer needed.
- **Filter Songs**: Filter songs within playlists by artist, album, or duration.
- **Save and Load Playlists**: Playlists are saved in a JSON file format and can be loaded upon application startup.


## Project Structure

- **app.rb**: The main application file that initializes the GUI and handles user interactions.
- **models/**: Contains the core classes for managing playlists and songs.
  - `playlist.rb`: Defines the `Playlist` class with methods for managing songs.
  - `song.rb`: Defines the `Song` class with attributes for song details.
- **utils/**: Utility scripts for additional functionalities.
  - `formatLength.rb`: Contains methods for formatting song durations.
- **data/**: Stores the `playlists.json` file where all playlists are saved.
- **views/**: Contains GUI components and views.
  - `playlistView.rb`: Handles the display and interaction of playlists.
  - `songView.rb`: Manages the display and interaction of songs within playlists.
