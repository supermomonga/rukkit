# encoding: utf-8

require_resource 'scripts/util'

module SayHelloAndGoodbye
  include_package 'org.bukkit.entity'
  extend self

  def on_player_join(evt)
    player = evt.player

    msg = "#{player.name}さんがログインしました"
    Rukkit::Util.broadcast msg
    Lingr.post msg if defined? Lingr
  end

  def on_player_quit(evt)
    player = evt.player
    msg = "#{player.name}さんがログアウトしました"
    Rukkit::Util.broadcast msg
    Lingr.post msg if defined? Lingr
  end
end
