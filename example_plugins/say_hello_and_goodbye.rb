# encoding: utf-8

require_resource 'scripts/util'

module SayHelloAndGoodbye
  include_package 'org.bukkit.entity'
  extend self

  def on_player_join(evt)
    player = evt.player
    Rukkit::Util.broadcast "#{player.name}さんがログインしました"
  end

  def on_player_quit(evt)
    player = evt.player
    Rukkit::Util.broadcast "#{player.name}さんがログアウトしました"
  end

end



