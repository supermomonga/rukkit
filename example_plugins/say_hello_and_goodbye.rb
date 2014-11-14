# encoding: utf-8

import 'org.bukkit.Bukkit'

module SayHelloAndGoodbye
  include_package 'org.bukkit.entity'
  include Util
  extend self

  def on_player_join(evt)
    player = evt.player
    broadcast "#{player.name}さんがログインしました"
  end

  def on_player_quit(evt)
    player = evt.player
    broadcast "#{player.name}さんがログアウトしました"
  end

end

SayHelloAndGoodbye
