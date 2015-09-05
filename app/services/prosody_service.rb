class ProsodyService
  class << self

    def register(user)
      %x(sudo prosodyctl register #{user.xmpp_username} #{XMPP_HOST} #{user.xmpp_password})
      true
    end

    def publish
      write_admins
      write_groups
      write_group_bookmarks
    end

    def reload
      %x(sudo prosodyctl reload)
      true
    end

    def generate_groups
      output = ""
      Group.all.each do |group|
        output << "[#{group.name}]\n"
        group.users.each do |user|
          if user.name.present?
            output << "#{user.jid}=#{user.name}\n"
          else
            output << "#{user.jid}\n"
          end
        end
        output << "\n"
      end
      output
    end

    def write_groups
      Rails.root.join('prosody/groups').open('w') do |file|
        file.write generate_groups
      end
    end

    def generate_group_bookmarks
      output = ""
      Room.all.each do |room|
        output << "[#{room.jid}]\n"
        room.users.each do |user|
          if user.name.present?
            output << "#{user.jid}=#{user.name}\n"
          else
            output << "#{user.jid}\n"
          end
        end
        output << "\n"
      end
      output
    end

    def write_group_bookmarks
      Rails.root.join('prosody/group_bookmarks').open('w') do |file|
        file.write generate_group_bookmarks
      end
    end

    def generate_admins
      output = ""
      output << "admins = {\n"
      User.where(admin: true).each do |user|
        output << %(  "#{user.jid}";\n)
      end
      output << "}\n"
      output
    end

    def write_admins
      Rails.root.join('prosody/admins').open('w') do |file|
        file.write generate_admins
      end
    end

  end
end
