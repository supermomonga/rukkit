import 'org.bukkit.Sound'
import 'org.bukkit.entity.Player'
require_resource 'scripts/util'

module StrongBoots
  extend self
  extend Rukkit::Util

  def on_entity_damage_by_block(evt)
    log.info("on_entity_damage_by_block: #{evt}")

    case evt.entity
    when Player
      b = evt.entity.inventory.boots or return

      # just for now
      evt.entity.send_message("[DEBUG] you have #{b}")
    end
  end
end
