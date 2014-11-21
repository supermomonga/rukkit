# encoding: utf-8

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
    sha: 'しゃ', shi: 'し', shu: 'しゅ', sho: 'しょ',
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
    sa: 'さ', si: 'し', su: 'す', se: 'せ', so: 'そ',
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
    /^と$/ => 'to',
    /^いん$/ => 'in',
    /^よう$/ => 'you',
    /^あれ$/ => 'are',
    /^ちめ$/ => 'time',
    /^ほうせ$/ => 'house',
    /^pl[zs]/ => 'お手数おかけしますが、よろしくお願い致します。',
    /wa-+i/ => 'わーい[^。^]',
    /^kawaisou$/ => 'かわいそう。・°°・(((p(≧□≦)q)))・°°・。ｳﾜｰﾝ!!',
    /dropper/ => '泥(・ω・)ﾉ■ ｯﾊﾟ',
    /hopper/ => '穂(・ω・)ﾉ■ ｯﾊﾟ',
    /\bきけん/ => '危険',
    /\bあんぜん/ => '安全',
    /\bwk[wt]k\b/ => '((o(´∀｀)o))ﾜｸﾜｸ',
    /^うんこ[.!]$/ => %`unko大量生産!ブリブリo(-"-;)o~#{Rukkit::Util.colorize '⌒ξ~ξ~ξ~ξ~ξ~ξ~ξ~ξ~~', :dark_red}`,
    /\bdks\b/ => '溺((o(´o｀)o))死',
    /\btkm\b/ => Rukkit::Util.colorize('匠', :magic),
    /^!\?$/ => '!? な、なんだってーΩ ΩΩ'
  } # }}}
  RANDOM_CONVERSION_TABLE = { # {{{
    /^thx[.!]*$/ => [
      '誠にありがたく想い存じあげます',
      'いつもお引き立ていただき、ありがとうございます',
      '格別のご愛顧を賜り心よりお礼申し上げます',
      'お互いに胸襟を開いて語り合う貴重な時間を下さった、今回の粋なお取り計らいに心から感謝申し上げます',
      'ここまで出来たのも、ひとえにあなた様にご助力いただいたお陰です',
      'これもひとえに皆々様のご支援・ご協力あってのことと心より感謝しております',
      '皆様方の温かなご支援とご指導のお陰様をもちまして重責を勤めることができましたこと、忘れることなく心に銘じておく所存であります'],
    /^yw(?:\.|!+)?$/ => [
      'いえいえ、情けは人のためならず、という諺がありますゆえ'],
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

  def on_async_player_chat(evt)
    # Convert
    evt.message = evt.message.split.map{|message_text|
      # Covert to HIRAGANA
      message_text.tap{|text|
        converted_text = ROMAJI_CONVERSION_TABLE.each_with_object(text.dup) {|(k, v), acc|
          acc.gsub! /wa$/, 'ha'
          acc.gsub! /nn$/, 'n'
          acc.gsub! /m([bmp])/, 'n\1'
          acc.gsub! k.to_s, v
        }
        break converted_text unless converted_text =~ /\w/
      }
    }.map{|message_text|
      # Convert by dictionary
      message_text = CONVERSION_TABLE.inject(message_text) {|acc, (k, v)| acc.gsub(k, v) }
      RANDOM_CONVERSION_TABLE.inject(message_text) {|acc, (k, vs)| acc.gsub(k, vs.sample) }
    }.join ' '

    # Post
    message = Message.new evt.player.name, evt.message
    Lingr.post "[#{message.name}] #{message.message}"
  end
end
# vim:foldmethod=marker
