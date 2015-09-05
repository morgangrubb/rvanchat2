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
class VCardUpdaterService < JabberService
  def update
    perform do
      vcard = vcard_helper.get

      vcard['FN']       = user.name
      vcard['NICKNAME'] = user.name

      if user.image_url.present?
        file = Tempfile.new "user_#{user.id}", encoding: 'ascii-8bit'

        begin
          file.write open(user.image_url, allow_unsafe_redirects: true).read
          file.close
          pn = Pathname.new(file.path)
          vcard['PHOTO/TYPE']   = %x(file -bi #{pn.to_s}).split(';').first
          vcard['PHOTO/BINVAL'] = Base64.encode64(pn.read)
        ensure
          file.close
          file.unlink
        end
      end

      vcard_helper.set vcard
    end
  end
end
