require 'digest/sha1'
require 'erb'
require 'open-uri'
require 'json'

require_resource 'scripts/util'

module Lingr
  ROMAJI_CONVERSION_TABLE = {
    ttya: 'っちゃ',
    ttyu: 'っちゅ',
    ttyo: 'っちょ',
    ttsu: 'っつ',
    ccho: 'っちょ',
    cchu: 'っちゅ',
    ccha: 'っちゃ',
    cchi: 'っち',
    ddya: 'っぢゃ',
    ddyu: 'っぢゅ',
    ddyo: 'っぢょ',
    hhya: 'っひゃ',
    sshu: 'っしゅ',
    ssha: 'っしゃ',
    sshi: 'っし',
    xtsu: 'っ',
    hhyu: 'っひゅ',
    hhyo: 'っひょ',
    bbya: 'っびゃ',
    bbyu: 'っびゅ',
    bbyo: 'っびょ',
    ppya: 'っぴゃ',
    ppyu: 'っぴゅ',
    ppyo: 'っぴょ',
    rrya: 'っりゃ',
    rryu: 'っりゅ',
    rryo: 'っりょ',
    zzyo: 'っじょ',
    zzyu: 'っじゅ',
    ttye: 'っちぇ',
    zzya: 'っじゃ',
    ssho: 'っしょ',
    ssyu: 'っしゅ',
    ssya: 'っしゃ',
    ggyo: 'っぎょ',
    ggyu: 'っぎゅ',
    ggya: 'っぎゃ',
    kkyo: 'っきょ',
    kkyu: 'っきゅ',
    kkya: 'っきゃ',
    zyu: 'じゅ',
    tya: 'ちゃ',
    ryo: 'りょ',
    ryu: 'りゅ',
    rya: 'りゃ',
    tyu: 'ちゅ',
    tyo: 'ちょ',
    dya: 'ぢゃ',
    xyo: 'ょ',
    dyu: 'ぢゅ',
    xyu: 'ゅ',
    dyo: 'ぢょ',
    xya: 'ゃ',
    xtu: 'っ',
    vvu: 'っう゛',
    vva: 'っう゛ぁ',
    myo: 'みょ',
    myu: 'みゅ',
    mya: 'みゃ',
    vvi: 'っう゛ぃ',
    vve: 'っう゛ぇ',
    vvo: 'っう゛ぉ',
    kka: 'っか',
    gga: 'っが',
    kki: 'っき',
    zyo: 'じょ',
    xwa: 'ゎ',
    zya: 'じゃ',
    ggi: 'っぎ',
    syo: 'しょ',
    syu: 'しゅ',
    sya: 'しゃ',
    kku: 'っく',
    ggu: 'っぐ',
    pyo: 'ぴょ',
    pyu: 'ぴゅ',
    pya: 'ぴゃ',
    kke: 'っけ',
    byo: 'びょ',
    byu: 'びゅ',
    bya: 'びゃ',
    gge: 'っげ',
    hyo: 'ひょ',
    hyu: 'ひゅ',
    hya: 'ひゃ',
    kko: 'っこ',
    ggo: 'っご',
    ssa: 'っさ',
    zza: 'っざ',
    ssi: 'っし',
    gyo: 'ぎょ',
    dyi: 'でぃ',
    nyo: 'にょ',
    nyu: 'にゅ',
    nya: 'にゃ',
    tye: 'ちぇ',
    zzi: 'っじ',
    gyu: 'ぎゅ',
    zye: 'じぇ',
    shi: 'し',
    ssu: 'っす',
    zzu: 'っず',
    sse: 'っせ',
    rro: 'っろ',
    rre: 'っれ',
    rru: 'っる',
    sha: 'しゃ',
    shu: 'しゅ',
    sho: 'しょ',
    rri: 'っり',
    rra: 'っら',
    yyo: 'っよ',
    yyu: 'っゆ',
    yya: 'っや',
    ppo: 'っぽ',
    bbo: 'っぼ',
    hho: 'っほ',
    ppe: 'っぺ',
    bbe: 'っべ',
    hhe: 'っへ',
    ppu: 'っぷ',
    bbu: 'っぶ',
    ffo: 'っふぉ',
    ffe: 'っふぇ',
    ffi: 'っふぃ',
    ffa: 'っふぁ',
    zze: 'っぜ',
    gya: 'ぎゃ',
    kyo: 'きょ',
    kyu: 'きゅ',
    ppi: 'っぴ',
    kya: 'きゃ',
    chi: 'ち',
    cha: 'ちゃ',
    bbi: 'っび',
    chu: 'ちゅ',
    cho: 'ちょ',
    jji: 'っじ',
    hhi: 'っひ',
    ppa: 'っぱ',
    bba: 'っば',
    hha: 'っは',
    ddo: 'っど',
    tto: 'っと',
    dde: 'っで',
    tte: 'って',
    ddu: 'っづ',
    ttu: 'っつ',
    jja: 'っじゃ',
    jju: 'っじゅ',
    jjo: 'っじょ',
    ddi: 'っぢ',
    ffu: 'っふ',
    tsu: 'つ',
    hhu: 'っふ',
    tti: 'っち',
    dda: 'っだ',
    tta: 'った',
    zzo: 'っぞ',
    sso: 'っそ',
    fu: 'ふ',
    tu: 'つ',
    du: 'づ',
    te: 'て',
    de: 'で',
    to: 'と',
    do: 'ど',
    na: 'な',
    ni: 'に',
    nu: 'ぬ',
    ne: 'ね',
    no: 'の',
    ha: 'は',
    ba: 'ば',
    pa: 'ぱ',
    hi: 'ひ',
    bi: 'び',
    pi: 'ぴ',
    hu: 'ふ',
    fa: 'ふぁ',
    fi: 'ふぃ',
    fe: 'ふぇ',
    fo: 'ふぉ',
    va: 'ヴぁ',
    pu: 'ぷ',
    he: 'へ',
    be: 'べ',
    pe: 'ぺ',
    ho: 'ほ',
    bo: 'ぼ',
    po: 'ぽ',
    ma: 'ま',
    mi: 'み',
    mu: 'む',
    me: 'め',
    mo: 'も',
    ya: 'や',
    yu: 'ゆ',
    yo: 'よ',
    di: 'ぢ',
    ra: 'ら',
    ri: 'り',
    ru: 'る',
    ti: 'ち',
    da: 'だ',
    ta: 'た',
    zo: 'ぞ',
    so: 'そ',
    ze: 'ぜ',
    se: 'せ',
    zu: 'ず',
    su: 'す',
    re: 'れ',
    ro: 'ろ',
    wa: 'わ',
    zi: 'じ',
    wi: 'ゐ',
    we: 'ゑ',
    wo: 'を',
    si: 'し',
    za: 'ざ',
    sa: 'さ',
    go: 'ご',
    ko: 'こ',
    ge: 'げ',
    ke: 'け',
    gu: 'ぐ',
    ku: 'く',
    xa: 'ぁ',
    xi: 'ぃ',
    ji: 'じ',
    gi: 'ぎ',
    ja: 'じゃ',
    ju: 'じゅ',
    jo: 'じょ',
    ki: 'き',
    ga: 'が',
    ka: 'か',
    xu: 'ぅ',
    xo: 'ぉ',
    vu: 'ヴ',
    xe: 'ぇ',
    vo: 'ヴォ',
    ve: 'ヴぇ',
    vi: 'ヴぃ',
    bu: 'ぶ',
    e: 'え',
    u: 'う',
    o: 'お',
    i: 'い',
    :'-' => 'ー',
    n: 'ん',
    a: 'あ',
  }
  CONVERSION_TABLE = {
    /べんり/ => '便利',
    /ふべん/ => '不便',
    /^ひ$/ => 'hi',
    /^い$/ => 'I',
    /^あ$/ => 'a',
    /^べ$/ => 'be',
    /^ちめ$/ => 'time',
    /^thx/ => '誠にありがたく想い存じあげます',
    /^yw/ => 'いえいえ、情けは人のためならず、という諺がありますゆえ'}

  class Message
    attr_reader :name, :message

    def initialize(name, message)
      @name = name
      @message = message
    end
  end

  extend self

  def post_to_lingr(channel, message)
    bot = Rukkit::Util.plugin_config 'lingr.bot'
    secret = Rukkit::Util.plugin_config 'lingr.secret'
    verifier = Digest::SHA1.hexdigest(bot + secret)

    params = {
      room: channel,
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

    channel = Rukkit::Util.plugin_config 'lingr.channel'
    post_to_lingr channel, text

  end
end
