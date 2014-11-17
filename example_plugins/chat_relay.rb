require 'digest/sha1'
require 'erb'
require 'open-uri'
require 'json'

require_resource 'scripts/util'
import 'org.bukkit.entity.Player'
import 'org.bukkit.ChatColor'

module ChatRelay
  ROMAJI_CONVERSION_TABLE = { # {{{
    # four charcters
    xtsu: 'っ',
    kkyo: 'っきょ', kkyu: 'っきゅ', kkya: 'っきゃ',
    ggyo: 'っぎょ', ggyu: 'っぎゅ', ggya: 'っぎゃ',
    ssyu: 'っしゅ', ssya: 'っしゃ',
    ssha: 'っしゃ', sshi: 'っし', sshu: 'っしゅ', ssho: 'っしょ',
    zzya: 'っじゃ', zzyu: 'っじゅ', zzyo: 'っじょ',
    ttya: 'っちゃ', ttyu: 'っちゅ', ttye: 'っちぇ', ttyo: 'っちょ', ttsu: 'っつ',
    ccho: 'っちょ', cchu: 'っちゅ', ccha: 'っちゃ', cchi: 'っち',
    ddya: 'っぢゃ', ddyu: 'っぢゅ', ddyo: 'っぢょ',
    hhya: 'っひゃ', hhyu: 'っひゅ', hhyo: 'っひょ',
    bbya: 'っびゃ', bbyu: 'っびゅ', bbyo: 'っびょ',
    ppya: 'っぴゃ', ppyu: 'っぴゅ', ppyo: 'っぴょ',
    rrya: 'っりゃ', rryu: 'っりゅ', rryo: 'っりょ',
    # three charcters
    xtu: 'っ',
    xya: 'ゃ', xyu: 'ゅ', xyo: 'ょ', xwa: 'ゎ',
    vva: 'っう゛ぁ', vvi: 'っう゛ぃ', vvu: 'っう゛', vve: 'っう゛ぇ', vvo: 'っう゛ぉ',
    kka: 'っか', kki: 'っき', kku: 'っく', kke: 'っけ', kko: 'っこ',
    gga: 'っが', ggi: 'っぎ', ggu: 'っぐ', gge: 'っげ', ggo: 'っご',
    ssa: 'っさ', ssi: 'っし', ssu: 'っす', sse: 'っせ', sso: 'っそ',
    zza: 'っざ', zzi: 'っじ', zzu: 'っず', zze: 'っぜ', zzo: 'っぞ',
    jji: 'っじ', jja: 'っじゃ', jju: 'っじゅ', jjo: 'っじょ',
    rra: 'っら', rri: 'っり', rru: 'っる', rre: 'っれ', rro: 'っろ',
    yya: 'っや', yyu: 'っゆ', yyo: 'っよ',
    hha: 'っは', hhi: 'っひ', hhu: 'っふ', ffu: 'っふ', hhe: 'っへ', hho: 'っほ',
    bba: 'っば', bbi: 'っび', bbu: 'っぶ', bbe: 'っべ', bbo: 'っぼ',
    ppa: 'っぱ', ppi: 'っぴ', ppu: 'っぷ', ppe: 'っぺ', ppo: 'っぽ',
    ffa: 'っふぁ', ffi: 'っふぃ', ffe: 'っふぇ', ffo: 'っふぉ',
    dda: 'っだ', ddi: 'っぢ', ddu: 'っづ', dde: 'っで', ddo: 'っど',
    tta: 'った', tti: 'っち', ttu: 'っつ', tte: 'って', tto: 'っと',
    kya: 'きゃ', kyu: 'きゅ', kyo: 'きょ',
    gya: 'ぎゃ', gyu: 'ぎゅ', gyo: 'ぎょ',
    sya: 'しゃ', syu: 'しゅ', syo: 'しょ',
    sha: 'しゃ', shu: 'しゅ', sho: 'しょ',
    zya: 'じゃ', zyu: 'じゅ', zye: 'じぇ', zyo: 'じょ',
    cha: 'ちゃ', chu: 'ちゅ', cho: 'ちょ',
    tya: 'ちゃ', tyu: 'ちゅ', tye: 'ちぇ', tyo: 'ちょ',
    nya: 'にゃ', nyu: 'にゅ', nyo: 'にょ',
    hya: 'ひゃ', hyu: 'ひゅ', hyo: 'ひょ',
    pya: 'ぴゃ', pyu: 'ぴゅ', pyo: 'ぴょ',
    bya: 'びゃ', byu: 'びゅ', byo: 'びょ',
    rya: 'りゃ', ryu: 'りゅ', ryo: 'りょ',
    dya: 'ぢゃ', dyi: 'でぃ', dyu: 'ぢゅ', dyo: 'ぢょ',
    mya: 'みゃ', myu: 'みゅ', myo: 'みょ',
    # two characters
    ta: 'た', ti: 'ち', chi: 'ち', tu: 'つ', tsu: 'つ', te: 'て', to: 'と',
    da: 'だ', di: 'ぢ', du: 'づ', de: 'で', do: 'ど',
    na: 'な', ni: 'に', nu: 'ぬ', ne: 'ね', no: 'の',
    ha: 'は', hi: 'ひ', hu: 'ふ', fu: 'ふ', he: 'へ', ho: 'ほ',
    ba: 'ば', bi: 'び', bu: 'ぶ', be: 'べ', bo: 'ぼ',
    pa: 'ぱ', pi: 'ぴ', pu: 'ぷ', pe: 'ぺ', po: 'ぽ',
    fa: 'ふぁ', fi: 'ふぃ', fe: 'ふぇ', fo: 'ふぉ',
    ma: 'ま', mi: 'み', mu: 'む', me: 'め', mo: 'も',
    ya: 'や', yu: 'ゆ', yo: 'よ',
    ra: 'ら', ri: 'り', ru: 'る', re: 'れ', ro: 'ろ',
    ka: 'か', ki: 'き', ku: 'く', ke: 'け', ko: 'こ',
    ga: 'が', gi: 'ぎ', gu: 'ぐ', ge: 'げ', go: 'ご',
    sa: 'さ', si: 'し', shi: 'し', su: 'す', se: 'せ', so: 'そ',
    za: 'ざ', zi: 'じ', ji: 'じ', zu: 'ず', ze: 'ぜ', zo: 'ぞ',
    ja: 'じゃ', ju: 'じゅ', jo: 'じょ',
    xa: 'ぁ', xi: 'ぃ', xu: 'ぅ', xe: 'ぇ', xo: 'ぉ',
    wa: 'わ', wi: 'ゐ', we: 'ゑ', wo: 'を',
    va: 'ヴぁ', vi: 'ヴぃ', vu: 'ヴ', ve: 'ヴぇ', vo: 'ヴォ',
    # one character
    a: 'あ', i: 'い', u: 'う', e: 'え', o: 'お',
    :'-' => 'ー',
    n: 'ん',
  } # }}}
  CONVERSION_TABLE = { # {{{
    /べんり/ => '便利',
    /ふべん/ => '不便',
    /^ひ$/ => 'hi',
    /^い$/ => 'I',
    /^あ$/ => 'a',
    /^べ$/ => 'be',
    /^ちめ$/ => 'time',
    /^thx[.!]*$/ => '誠にありがたく想い存じあげます',
    /^y[.!]*$/ => 'いえいえ、情けは人のためならず、という諺がありますゆえ',
    /^pl[zs]/ => 'お手数おかけいたしますが、よろしくお願いいたします',
    /wa-+i/ => 'わーい[^。^]',
    /^kawaisou$/ => 'かわいそう。・°°・(((p(≧□≦)q)))・°°・。ｳﾜｰﾝ!!',
    /dropper|ドロッパ/ => '泥(・ω・)ﾉ■ ｯﾊﾟ',
    /hopper|ホッパ/ => '穂(・ω・)ﾉ■ ｯﾊﾟ',
    /\bkiken/ => '危険',
    /\banzen/ => '安全',
    /\bwk[wt]k\b/ => '((o(´∀｀)o))ﾜｸﾜｸ',
    /^unko[.!]$/ => %`unko大量生産!ブリブリo(-"-;)o~{ChatColor/DARK_RED}⌒ξ~ξ~ξ~ξ~ξ~ξ~ξ~ξ~~{ChatColor/RESET}`,
    /\bdks\b/ => '溺((o(´o｀)o))死',
    /\btkm\b/ => "#{ChatColor::MAGIC}匠#{ChatColor::RESET}",
    /^!\?$/ => '!? な、なんだってーΩ ΩΩ'
  } # }}}

  class Message
    attr_reader :name, :message

    def initialize(name, message)
      @name = name
      @message = message
    end
  end

  extend self
  extend Rukkit::Util

  def post_to_lingr(room, message)
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

  def on_async_player_chat(evt)
    player = evt.player

    message_texts = evt.message.split
    evt.message = message_texts.map{|message_text|
      converted_text = ROMAJI_CONVERSION_TABLE.each_with_object(message_text.dup) {|(k, v), acc|
        acc.gsub! /wa$/, 'ha'
        acc.gsub! /nn$/, 'n'
        acc.gsub! /m([bmp])/, 'n\1'
        acc.gsub! k.to_s, v
      }
      if converted_text =~ /\w/
        message_text
      else
        converted_text
      end
    }.map{|message_text|
      CONVERSION_TABLE.inject(message_text) {|acc, (k, v)| acc.gsub(k, v) }
    }.join ' '
    message = Message.new player.name, evt.message

    text = "[#{message.name}] #{message.message}"

    room = Rukkit::Util.plugin_config 'lingr.room'
    post_to_lingr room, text
  end

  def on_entity_death(evt)
    entity = evt.entity
    player = entity.killer

    case player
    when Player
      room = Rukkit::Util.plugin_config 'lingr.room'
      msg = "#{player.name} killed a #{entity.type ? entity.type.name.downcase : entity.inspect}"
      post_to_lingr room, msg
      broadcast msg
    end
  end
end
# vim:foldmethod=marker
