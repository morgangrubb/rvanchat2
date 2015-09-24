module Bot
  module Handler
    autoload :Admin,      './lib/bot/handler/admin'
    autoload :Base,       './lib/bot/handler/base'
    autoload :Control,    './lib/bot/handler/control'
    autoload :Facebook,   './lib/bot/handler/facebook'
    autoload :Giphy,      './lib/bot/handler/giphy'
    autoload :Google,     './lib/bot/handler/google'
    autoload :Help,       './lib/bot/handler/help'
    autoload :Imgur,      './lib/bot/handler/imgur'
    autoload :Link,       './lib/bot/handler/link'
    autoload :Record,     './lib/bot/handler/record'
    autoload :Seen,       './lib/bot/handler/seen'
    autoload :Twitter,    './lib/bot/handler/twitter'
    autoload :Eliza,      './lib/bot/handler/eliza'
    autoload :Youtube,    './lib/bot/handler/youtube'
    autoload :Background, './lib/bot/handler/background'
    autoload :Say,        './lib/bot/handler/say'
    autoload :EightBall,  './lib/bot/handler/eight_ball'
    autoload :Roll,       './lib/bot/handler/roll'
    autoload :Whois,      './lib/bot/handler/whois'
    # autoload :Zork,       './lib/bot/handler/zork'
  end
end
