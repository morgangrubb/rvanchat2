require 'xmpp4r/muc/helper/mucclient'

# Keep it verbose so that we're not confused at all.
class ExtendedChatMessageNick < String
  def jabber_message_resource=(value)
    @jabber_message_resource = value
  end

  def jabber_message_resource
    @jabber_message_resource
  end
end

# We need to expose the user jid instead of just the nick. We'll do this by
# faking the user_nick string.
module Jabber
  module MUC
    class SimpleMUCClient < MUCClient

      private

      # def handle_message(msg)
      #   super

      #   # Message time (e.g. history)
      #   time = nil
      #   msg.each_element('x') { |x|
      #     if x.kind_of?(Delay::XDelay)
      #       time = x.stamp
      #     end
      #   }
      #   sender_nick = msg.from.resource


      #   if msg.subject
      #     @subject = msg.subject
      #     @subject_block.call(time, sender_nick, @subject) if @subject_block
      #   end

      #   if msg.body
      #     if sender_nick.nil?
      #       @room_message_block.call(time, msg.body) if @room_message_block
      #     else
      #       if msg.type == :chat
      #         @private_message_block.call(time, msg.from.resource, msg.body) if @private_message_block
      #       elsif msg.type == :groupchat
      #         @message_block.call(time, msg.from.resource, msg.body) if @message_block
      #       else
      #         # ...?
      #       end
      #     end
      #   end
      # end

      def handle_message(msg)
        super

        # Message time (e.g. history)
        time = nil
        msg.each_element('x') { |x|
          if x.kind_of?(Delay::XDelay)
            time = x.stamp
          end
        }
        sender_nick = msg.from.resource

        sender_nick = ExtendedChatMessageNick.new(sender_nick || '')
        sender_nick.jabber_message_resource = msg

        if msg.subject
          @subject = msg.subject
          @subject_block.call(time, sender_nick, @subject) if @subject_block
        end

        if msg.body
          if sender_nick.nil?
            @room_message_block.call(time, msg.body) if @room_message_block
          else
            if msg.type == :chat
              @private_message_block.call(time, msg.from.resource, msg.body) if @private_message_block
            elsif msg.type == :groupchat
              @message_block.call(time, msg.from.resource, msg.body) if @message_block
            else
              # ...?
            end
          end
        end
      end

    end
  end
end
