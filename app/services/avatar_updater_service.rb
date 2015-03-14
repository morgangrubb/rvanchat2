# http://www.xmpp.org/extensions/xep-0153.html
#
# <vCard xmlns='vcard-temp'>
#   <BDAY>1476-06-09</BDAY>
#   <ADR>
#     <CTRY>Italy</CTRY>
#     <LOCALITY>Verona</LOCALITY>
#     <HOME/>
#   </ADR>
#   <NICKNAME/>
#   <N><GIVEN>Juliet</GIVEN><FAMILY>Capulet</FAMILY></N>
#   <EMAIL>jcapulet@shakespeare.lit</EMAIL>
#   <PHOTO>
#     <TYPE>image/jpeg</TYPE>
#     <BINVAL>
#       Base64-encoded-avatar-file-here!
#     </BINVAL>
#   </PHOTO>
# </vCard>
#
class AvatarUpdaterService < JabberService
  def update
    if user.image_url.present?
      file = Tempfile.new "user_#{user.id}", encoding: 'ascii-8bit'

      begin
        file.write open(user.image_url).read
        file.close
        set(Pathname.new(file.path))
      ensure
        file.close
        file.unlink
      end
    end
  end

  def set(file)
    vcard = vcard_helper.get
    vcard['PHOTO/TYPE'] = %x(file -bi #{file.to_s}).split(';').first
    vcard['PHOTO/BINVAL'] = Base64.encode64(file.read)
    vcard_helper.set vcard
  end
end
