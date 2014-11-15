import 'org.bukkit.Bukkit'
import 'org.bukkit.entity.Squid'
import 'org.bukkit.Material'

module FastDash
  extend self

  def on_player_toggle_sprint(evt)
    return if evt.player.passenger && Squid === evt.player.passenger
    if evt.sprinting? && !evt.player.passenger
      if evt.player.location.clone.add(0, -1, 0).block.type == Material::SAND
        evt.cancelled = true
      else
        evt.player.walk_speed = 0.4
      end
    else
      evt.player.walk_speed = 0.2
    end
  end
end
