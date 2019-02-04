module PiiSafeSchema::Annotations
  COLUMNS = {
    email: {
      comment: {
        pii: { obfuscate: "email_obfuscator" }
      },
      regexp: /email/
    },
    phone: {
      comment: {
        pii: { obfuscate: "phone_obfuscator" }
      },
      regexp: /phone/
    },
    ip_address: {
      comment: {
        pii: { obfuscate: "ip_obfuscator" }
      },
      regexp: /ip_address/
    },
    geolocation: {
      comment: {
        pii: { obfuscate: "geo_obfuscator" }
      },
      regexp: /lat|long/
    },
    name: {
      comment: {
        pii: { obfuscate: "name_obfuscator" }
      }
    }
  }.freeze

  def recommended_comment(column)
    COLUMNS.each do |pii_type|
      return pii_type[:comment] if apply_recommendation?(column, pii)
    end
  end

  def apply_recommendation?(column, pii_type)
    pii_type[:regexp].match(column.name) && 
      comment.column != pii_type[:comment].to_json
  end
end
