require 'gruesome'

# Now monkey patch it to accept save file names
module GruesomeSaveFilePatch
  # file = File.open(game_file, "rb")

  # # I. Create memory space

  # memory_size = File.size(game_file)
  # save_file_name = File.basename(file, File.extname(file)) + ".sav"
  # @memory = Memory.new(file.read(memory_size), save_file_name)

  # # Set flags
  # flags = @memory.force_readb(0x01)
  # flags &= ~(0b1110000)
  # @memory.force_writeb(0x01, flags)

  # # Set flags 2
  # flags = @memory.force_readb(0x10)
  # flags &= ~(0b11111100)
  # @memory.force_writeb(0x10, flags)

  # # II. Read header (at address 0x0000) and associated tables
  # @header = Header.new(@memory.contents)
  # @object_table = ObjectTable.new(@memory)

  # # III. Instantiate CPU
  # @decoder = Decoder.new(@memory)
  # @processor = Processor.new(@memory)
  def initialize(game_file, options = {})
    file = File.open(game_file, "rb")

    # I. Create memory space

    memory_size = File.size(game_file)

    save_file_name =
      options[:save_path] ? options[:save_path] : File.basename(file, File.extname(file)) + ".sav"

    @memory = Memory.new(file.read(memory_size), save_file_name)

    # Set flags
    flags = @memory.force_readb(0x01)
    flags &= ~(0b1110000)
    @memory.force_writeb(0x01, flags)

    # Set flags 2
    flags = @memory.force_readb(0x10)
    flags &= ~(0b11111100)
    @memory.force_writeb(0x10, flags)

    # II. Read header (at address 0x0000) and associated tables
    @header = Header.new(@memory.contents)
    @object_table = ObjectTable.new(@memory)

    # III. Instantiate CPU
    @decoder = Decoder.new(@memory)
    @processor = Processor.new(@memory)
  end
end

Gruesome::Z::Machine.send(:include, GruesomeSaveFilePatch)

module Bot
  module Handler
    class Zork < Bot::Handler::Base

      def initialize(*args)
        @loaded_interpreters = {}
      end

      def private_message(message, params)
        case message.text
        when /^!zork$/
          message.processed!
          say_instructions(message)
        when /^!zork reset$/
          message.processed!
          @loaded_interpreters.delete save_file_name(message)
          save_file_path(message).unlink
          say "Save game deleted.", user_name: message.user_name
        end
      end

      def describe_commands(message)
        "Play a game of Zork with\n!zork\nOnly works in private chats with wopr"
      end

      def say_instructions(message)
        instructions = [
          "!zork start",
          "!zork resume",
          "!zork reset"
        ]

        say instructions.join("\n"), user_name: user_name
      end

      def save_file_name(message)
        "zork1_" + Digest::MD5.hexdigest(message.user_name) + ".sav"
      end

      def save_file_path(message)
        Rails.root.join("saves", save_file_name(message))
      end

      def interpreter(message)
        @loaded_interpreters[save_file_name(message)] ||=
          Gruesome::Z::Machine.new(
            Rails.root.join("vendor", "zork1.z3"),
            save_path: save_file_path(message).to_s
          )
      end

    end
  end
end
