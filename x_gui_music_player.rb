require 'rubygems'
require 'gosu'

TOP_COLOR = Gosu::Color.new(0xFF1EB1FA)
BOTTOM_COLOR = Gosu::Color.new(0xFF1D4DB5)
LEFT = 300

SCREEN_WIDTH = 1280
SCREEN_HEIGHT = 720
SIDE_WIDTH = 162
ALBUM_WIDTH = 600


module ZOrder
  BACKGROUND, SIDE, PLAYER, UI = *0..3
end

module Genre
  POP, CLASSIC, JAZZ, ROCK = *1..4
end

GENRE_NAMES = ['Null', 'Pop', 'Classic', 'Jazz', 'Rock']

class ArtWork
	attr_accessor :bmp , :dim 

	def initialize (file, dim)
		@bmp = Gosu::Image.new(file)
		@dim = dim 
	end
end

class Album 
	attr_accessor :title,:artist,:artwork,:tracks 

	def initialize (title,artist,artwork,tracks)
		@title = title 
		@artist = artist 
		@artwork = artwork
		@tracks = tracks 
	end
# Put your record definitions here
end

class Dimension 
	attr_accessor :left , :right , :top , :bottom 

	def initialize (left,right,top,bottom)

		@left = left 
	 	@right = right 
	 	@top = top 
	 	@bottom = bottom 
	 end 
end 

class Track 
	attr_accessor :tname , :tlocation, :dim 

	def initialize (tname,tlocation, dim )
		@tname = tname 
		@tlocation = tlocation
		@dim = dim  
	end 
end 

class MusicPlayerMain < Gosu::Window

	def initialize
	    super SCREEN_WIDTH, SCREEN_HEIGHT
	    self.caption = "Music Player"
	    @track_font = Gosu::Font.new(25)
			@albums = read_albums()
			@track_playing = -1
			@album_playing = -1 
			@BACKGROUND_COLOR = Gosu::Color.new(255,255,255,255)
			@SIDE_COLOR = Gosu::Color.new(248,248,248,255)
			@ALBUM_COLOR = Gosu::Color.new(230,255,242)
	end

	def read_track(music_file , loc )

		track_name = music_file.gets.chomp
		track_location = music_file.gets.chomp
		le = LEFT 
		ri = LEFT + @track_font.text_width(track_name)
		to = 100 * loc + 50 
		bot = to + @track_font.height() 
		dim = Dimension.new(le,ri,to,bot)
		track = Track.new(track_name,track_location,dim)

		return track 
		
	end


  # Put in your code here to load albums and tracks
	def read_tracks(music_file)
		count = music_file.gets.to_i
		i = 0 
		tracks = []
		while i < count 
			track = read_track(music_file , i)
			tracks << track 
			i += 1 
		end 
		return tracks
	end

	def read_albums()
		a_file = File.new('albums.txt','r')
		albums = Array.new()
		album_num = a_file.gets.to_i()
		for i in 1 .. album_num 
			single_album = read_album(a_file, i-1)
			albums << single_album
		end 
		a_file.close()
		return albums
	end 

	def read_album(music_file, loc)
		album_title = music_file.gets.to_s 
		album_artist = music_file.gets.to_s
		if loc % 2 == 0 and loc != 0 
			le = 182 
			ri = 362
			to = 5 + 240*(loc/2)
			bot = to + 180  
		elsif loc % 2 == 1
			le = 402 
			ri = 582 
			to = 5 + 240*((loc-1)/2)
			bot = to + 180 
		elsif loc == 0 
			le = 182 
			ri = 362
			to = 5 
			bot = 185
		end  
		dim = Dimension.new(le,ri,to,bot)
		artwork = ArtWork.new(music_file.gets.chomp, dim)
		tracks = read_tracks(music_file)
		album = Album.new(album_title,album_artist,artwork,tracks)
		return album 
	end
  # Draws the artwork on the screen for all the albums
	def draw_artworks
		for i in 0 .. @albums.length - 1 
			@albums[i].artwork.bmp.draw(@albums[i].artwork.dim.left,@albums[i].artwork.dim.top,ZOrder::PLAYER,0.3,0.3)
		end 
	end 	

	def draw_playing_album(track_playing,album )
			draw_rect(@albums[album].tracks[track_playing].dim.left - 15, @albums[album].tracks[track_playing].dim.top , 10 ,@track_font.height , Gosu::Color::YELLOW , z = ZOrder::PLAYER)
	end 	

	def draw_album_track(albums)
	
		for i in 1 .. albums.tracks.length()
				display_track(albums.tracks[i-1])
		end 
	end

  # Detects if a 'mouse sensitive' area has been clicked on
  # i.e either an album or a track. returns true or false 	 
  
  def draw_hover_album 
  	for i in 1 .. @albums.length
	  	if mouse_x >= @albums[i-1].artwork.dim.left  && mouse_x <= @albums[i-1].artwork.dim.right && mouse_y >= @albums[i-1].artwork.dim.top && mouse_y <= @albums[i-1].artwork.dim.bottom 
	  		draw_rect(@albums[i-1].artwork.dim.left,@albums[i-1].artwork.dim.top, 190, 190, Gosu::Color::BLACK, ZOrder::BACKGROUND)
	  	end
  	end 
  end		

	def area_clicked(left, right, top, bottom)
		# complete this code
		if mouse_x > left && mouse_x < right && mouse_y > top && mouse_y < bottom  
			return true 
		end

			return false 

	end


  # Takes a String title and an Integer ypos
  # You may want to use the following:
	def display_track(track)
		@track_font.draw(track.tname, track.dim.left, track.dim.top, ZOrder::PLAYER, 1.0, 1.0, Gosu::Color::BLACK)
	end


  # Takes a track index and an Album and plays the Track from the Album

 	 def playTrack(track, album)
		@song = Gosu::Song.new(album.tracks[track].tlocation)
		@song.play(false)
 	 end

# Draw a coloured background using TOP_COLOR and BOTTOM_COLOR

	def draw_background
		  draw_quad(0,0, @SIDE_COLOR, 0, SCREEN_WIDTH, @SIDE_COLOR, SIDE_WIDTH, 0, @SIDE_COLOR, SIDE_WIDTH, SCREEN_WIDTH, @SIDE_COLOR, z = ZOrder::SIDE)
		  draw_quad(0,0, @BACKGROUND_COLOR, 0, SCREEN_WIDTH, @BACKGROUND_COLOR, SCREEN_WIDTH, 0, @BACKGROUND_COLOR, SCREEN_WIDTH, SCREEN_HEIGHT, @BACKGROUND_COLOR, z = ZOrder::BACKGROUND)
		  draw_quad(SIDE_WIDTH,0, @ALBUM_COLOR, ALBUM_WIDTH, 0 , @ALBUM_COLOR, ALBUM_WIDTH, SCREEN_HEIGHT, @ALBUM_COLOR, SIDE_WIDTH, SCREEN_HEIGHT, @ALBUM_COLOR, z = ZOrder::BACKGROUND)
	end

# Not used? Everything depends on mouse actions.

	def update
		
		if @album_playing >= 0 && @song == nil 
			@track_playing = 0 
			playTrack(0,@albums[@album_playing])
		end

		if @album_playing >= 0 && @song != nil && (not @song.playing?)
			@track_playing = (@track_playing + 1 ) % @albums[@album_playing].tracks.length()
			playTrack(@track_playing,@albums[@album_playing])
		end 
	end

 # Draws the album images and the track list for the selected album
	def draw
		# Complete the missing code
		
		draw_background
		draw_artworks
		draw_hover_album
		if @album_playing >= 0 
			draw_album_track(@albums[@album_playing])
			draw_playing_album(@track_playing , @album_playing)
		end

	end

 	def needs_cursor?; true; end

	def button_down(id)
		case id
	    when Gosu::MsLeft
	    	if @album_playing >= 0 
					for i in 1 .. @albums[@album_playing].tracks.length()
						if area_clicked(@albums[@album_playing].tracks[i-1].dim.left,@albums[@album_playing].tracks[i-1].dim.right,@albums[@album_playing].tracks[i-1].dim.top,@albums[@album_playing].tracks[i-1].dim.bottom)
							@track_playing = i-1 
							playTrack(@track_playing,@albums[@album_playing])

							break
						end 
					end
				end 

	    	for i in 1 .. @albums.length()
					if area_clicked(@albums[i-1].artwork.dim.left,@albums[i-1].artwork.dim.right,@albums[i-1].artwork.dim.top,@albums[i-1].artwork.dim.bottom)
						@album_playing = i - 1
						@song = nil 
						break
					end 
				end
		    
			end	
		end
	end

# Show is a method that loops through update and draw

MusicPlayerMain.new.show if __FILE__ == $0