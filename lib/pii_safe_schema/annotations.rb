module PiiSafeSchema
  module Annotations
    SENSITIVE_DATA_NAMES = %w[
      sin social_insurance_number ssn social_security_number
      tin tax_idenfification_number national_insurance_number mifid
    ].freeze
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
      address: {
        comment: {
          pii: { obfuscate: 'null_obfuscator' },
        },
        regexp: /(^street|apt|apartment|unit_n)/,
      },
      postal_code: {
        comment: {
          pii: { obfuscate: 'postal_code_obfuscator' },
        },
        regexp: /(postal|zip)_code/,
      },
      name: {
        comment: {
          pii: { obfuscate: 'name_obfuscator' },
        },
        regexp: /(last|sur|full|^)_?(name)/,
      },
      sensitive_data: {
        comment: {
          pii: { tokenize: 'sha256_tokenizer' },
        },
        regexp: /(^|_)(#{SENSITIVE_DATA_NAMES.join("|")})(_|$)/,
      },
      encrypted_data: {
        comment: {
          pii: { obfuscate: 'null_obfuscator' },
        },
        regexp: /encrypted/,
      },
    }.freeze

    def recommended_comment(column)
      return COLUMNS[:encrypted_data][:comment] if apply_encrypted_recommendation?(column)

      COLUMNS.each do |_type, info|
        return info[:comment] if apply_recommendation?(column, info)
      end
      nil
    end

    def self.comment(annotation_type)
      COLUMNS.dig(annotation_type.to_sym, :comment)
    end

    def apply_recommendation?(column, pii_info)
      !encrypted?(column) &&
        pii_info[:regexp].match?(column.name) &&
        column.comment != pii_info[:comment].to_json
    end

    def encrypted?(column)
      COLUMNS[:encrypted_data][:regexp].match?(column.name)
    end

    def apply_encrypted_recommendation?(column)
      encrypted?(column) && column.comment != COLUMNS[:encrypted_data][:comment].to_json
    end
  end
end
