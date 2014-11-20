# encoding: utf-8

module SayHelloAndGoodbye
  include_package 'org.bukkit.entity'
  extend self

  def on_player_join(evt)
    player = evt.player

    msg = "#{player.name}さんが現実世界に帰ってきました"
    Rukkit::Util.broadcast msg
    Lingr.post msg if defined? Lingr
  end

  def on_player_quit(evt)
    player = evt.player

    msg = "#{player.name}さんが仮想世界に旅立ちました"
    Rukkit::Util.broadcast msg
    Lingr.post msg if defined? Lingr
  end
end
