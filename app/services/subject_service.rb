require 'xmpp4r/muc'

class SubjectService < JabberService
  def set(room, subject)
    muc = Jabber::MUC::SimpleMUCClient.new(client)
    muc.join Jabber::JID.new(room.jid)
    muc.subject = subject
  end
end
