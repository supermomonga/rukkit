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
end

module Rukkit
  module Util

    extend self

    def broadcast(*messages)
      Bukkit.server.broadcast_message messages.join
    end

    def sec(n)
      (n * 20).to_i
    end

    def later(tick, &block)
      plugin = Bukkit.plugin_manager.get_plugin("rukkit")
      Bukkit.scheduler.schedule_sync_delayed_task(plugin, block, tick)
    end

    def block_below(block)
      add_loc(block.location, 0, -1, 0).block
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

    def plugin_config(key, type = :string)
      config_path = "rukkit.plugin_config.#{key}"
      method = "get_#{type}"
      config = Bukkit.plugin_manager.get_plugin('rukkit').config
      config.send method, config_path
    end
  end
end
