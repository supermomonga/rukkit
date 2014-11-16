import 'org.bukkit.Sound'
require_resource 'scripts/util'

module Dummy
  extend self
  extend Rukkit::Util

  def on_player_toggle_sneak(evt)
    player = evt.player
    if player.name == 'ujm'
      play_sound(add_loc(player.location, 0, 5, 0), Sound.values.sample, 1.0, 0.0)
    end
  end
end
