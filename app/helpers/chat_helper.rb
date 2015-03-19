module ChatHelper
  def candy_bookmark_rooms
    bookmarks = []
    current_user.rooms.collect(&:jid).each do |jid|
      bookmarks << "CandyShop.Bookmark.add('#{jid}');"
    end
    bookmarks.join("\n")
  end

  def candy_autojoin_rooms
    current_user.rooms.collect(&:jid).to_json
  end

  def candy_room_panel_user_rooms
    current_user.rooms.collect do |room|
      { name: room.name, jid: room.jid }
    end.to_json
  end

  def reveal(field)
    content_tag(:code, "Click to reveal", class: "reveal-#{field}")
  end
end
