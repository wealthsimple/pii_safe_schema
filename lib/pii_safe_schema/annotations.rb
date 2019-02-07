module PiiSafeSchema::Annotations
  COLUMNS = {
    email: {
      comment: {
        pii: { obfuscate: 'email_obfuscator' },
      },
      regexp: /email/,
    },
    phone: {
      comment: {
        pii: { obfuscate: 'phone_obfuscator' },
      },
      regexp: /phone/,
    },
    ip_address: {
      comment: {
        pii: { obfuscate: 'ip_obfuscator' },
      },
      regexp: /ip_address/,
    },
    geolocation: {
      comment: {
        pii: { obfuscate: 'geo_obfuscator' },
      },
      regexp: /latitude|longitude/,
    },
    name: {
      comment: {
        pii: { obfuscate: 'name_obfuscator' },
      },
      regexp: /name/,
    },
  }.freeze

  def recommended_comment(column)
    COLUMNS.each do |_type, info|
      return info[:comment] if apply_recommendation?(column, info)
    end
    nil
  end

  def apply_recommendation?(column, pii_info)
    pii_info[:regexp].match(column.name) &&
      column.comment != pii_info[:comment].to_json
  end
end
