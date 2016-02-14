require 'audite'

class Player
  attr_reader :length, :position, :p

  def initialize
    @length = 0
    @end_offset = 1
    reload_lib
  end

  def reload_lib
    @p = Audite.new
    @p.events.on(:position_change) do |position|
      @position = position
      if (@length>0) && (@length - position) <= @end_offset
        # puts "\nCOMPLETE\n"
        @p.thread.kill
      end
    end
  end

  def play(name, paused=false)
    @p.thread.kill if @p.thread && @p.thread.alive?
    reload_lib
    @p.load(File.join(Dir.pwd, 'out', name))
    @p.thread.abort_on_exception = false
    @length = @p.length_in_seconds
    @end_offset = @p.time_per_frame * 10
    @p.start_stream unless paused
  end

  def skip(seconds = 10)
    if @p.thread && @p.thread.alive?
      @p.seek(@p.position + seconds)
    else
      @last_pos += seconds
    end
  end

  def toggle
    if @p.thread && @p.thread.alive?
      @last_pos = @p.position
      @file = @p.current_song_name
      @p.thread.kill
    elsif @last_pos && @file
      play @file, true
      skip @last_pos
      @p.start_stream
      @last_pos = 0
    end
  end

end

# p = Player.new
# p.play('sample.mp3')
# puts p.length
# p.skip p.length-10
# sleep 5
# p.play('sample2.mp3')
# sleep 1