import 'org.bukkit.Sound'
require_resource 'scripts/util'

module Dummy
  extend self
  extend Rukkit::Util

  # def on_player_toggle_sneak(evt)
  #   player = evt.player
  #   if player.name == 'ujm'
  #     play_sound(add_loc(player.location, 0, 5, 0), Sound.values.to_a.sample, 1.0, 0.0)
  #   end
  # end

  def on_command(sender, command, label, args)
    args = args.to_a
    case [label, args.shift]
    when ['rukkit', 'update']
      unless args.empty?
        log.warn('rukkit update with argument is invalid')
        return
      end

      p :update, sender, command, args
    else
      p :else, sender, command, args
    end
  end
end
