import 'org.bukkit.Sound'
require_resource 'scripts/util'

module SuperJump
  extend self
  extend Rukkit::Util

  def on_player_toggle_sneak(evt)
    player = evt.player
    return unless %w[world world_nether].include?(player.location.world.name)

    name = player.name
    @crouching_counter ||= {}
    @crouching_counter[name] ||= 0
    @crouching_countingdown ||= false
    if evt.sneaking?
      # counting up
      @crouching_counter[name] += 1
      later sec(2.0) do
        @crouching_counter[name] -= 1
      end
      if @crouching_counter[name] == 4
        play_sound(add_loc(player.location, 0, 5, 0), Sound::BAT_TAKEOFF, 1.0, 0.0)
        # evt.player.send_message "superjump!"
        player.fall_distance = 0.0
        player.velocity = player.velocity.tap {|v| v.set_y jfloat(1.4) }
      end
    end
  end

    def add_loc(loc, x, y, z)
      l = loc.dup
      l.add(x, y, z)
      l
    end

    def play_sound(loc, sound, volume, pitch)
      loc.world.play_sound(loc, sound, jfloat(volume), jfloat(pitch))
    end

    def jfloat(rubyfloat)
      rubyfloat.to_java Java.float
    end
end