import 'org.bukkit.Sound'
import 'org.bukkit.entity.Player'
import 'org.bukkit.event.entity.EntityDamageEvent'

module StrongBoots
  extend self
  extend Rukkit::Util

  def on_entity_damage(evt)
    # log.info("on_entity_damage: #{evt}")

    case evt.entity
    when Player
      case evt.cause
      when EntityDamageEvent::DamageCause::FALL
        b = evt.entity.inventory.boots or return

        # just for now
        # evt.entity.send_message("[DEBUG] you have #{b}")
        evt.cancelled = true
        play_sound(
          add_loc(evt.entity.location, 0, 5, 0), Sound::BAT_HURT, 0.5, 0.0)
      end
    end
  end
end
