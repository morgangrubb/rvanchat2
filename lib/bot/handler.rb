module Bot
  module Handler
    autoload :Base,     './lib/bot/handler/base'
    autoload :Control,  './lib/bot/handler/control'
    autoload :Facebook, './lib/bot/handler/facebook'
    autoload :Giphy,    './lib/bot/handler/giphy'
    autoload :Google,   './lib/bot/handler/google'
    autoload :Help,     './lib/bot/handler/help'
    autoload :Imgur,    './lib/bot/handler/imgur'
    autoload :Link,     './lib/bot/handler/link'
    autoload :Record,   './lib/bot/handler/record'
    autoload :Seen,     './lib/bot/handler/seen'
    autoload :Twitter,  './lib/bot/handler/twitter'
    autoload :Eliza,    './lib/bot/handler/eliza'
  end
end
