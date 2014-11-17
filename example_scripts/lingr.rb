require 'digest/sha1'
require 'erb'
require 'open-uri'

module Lingr
  extend self

  def post_to_lingr(message)
    room = Rukkit::Util.plugin_config 'lingr.room'
    bot = Rukkit::Util.plugin_config 'lingr.bot'
    secret = Rukkit::Util.plugin_config 'lingr.secret'
    verifier = Digest::SHA1.hexdigest(bot + secret)

    params = {
      room: room,
      bot: bot,
      text: message,
      bot_verifier: verifier
    }

    query_string = params.map{|k,v|
      key = ERB::Util.url_encode k.to_s
      value = ERB::Util.url_encode v.to_s
      "#{key}=#{value}"
    }.join "&"

    Thread.start do
      open "http://lingr.com/api/room/say?#{query_string}"
    end
  end

end
