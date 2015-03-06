module ChatHelper
  def candy_autojoin_rooms
    current_user.rooms.collect(&:jid).to_json
  end

  def candy_room_panel_user_rooms
    current_user.rooms.collect do |room|
      { name: room.name, jid: room.jid }
    end.to_json
  end
end
