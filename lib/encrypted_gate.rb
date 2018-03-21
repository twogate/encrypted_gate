# ==============================================================================
# lib - encrypted gate
# ==============================================================================
require "encrypted_gate/version"

module EncryptedGate
  def self.extended(base)
    base.class_eval do
      include InstanceMethods
      @encrypted_attributes = {}
    end
  end

  def encrypted_column(attribute, options={})
    encrypted_attributes[attribute] = { attribute: attribute }.merge(options)

    define_method(attribute) do
      return instance_variable_get("@#{attribute}") if instance_variable_get("@#{attribute}")
      instance_variable_set("@#{attribute}", decrypt(attribute, send("encrypted_#{attribute}")))
    end

    define_method("#{attribute}=") do |value|
      send("encrypted_#{attribute}=", encrypt(attribute, value))
      instance_variable_set("@#{attribute}", value)
    end
  end

  def encrypted_attributes
    @encrypted_attributes
  end

  module InstanceMethods
    def encrypt(attribute, plain)
      encryptor(salt_of(attribute)).encrypt_and_sign(plain)
    end

    def decrypt(attribute, cypher)
      return cypher if cypher.nil?
      encryptor(salt_of(attribute)).decrypt_and_verify(cypher)
    end

    def encryptor(salt)
      cipher_key_len = ActiveSupport::MessageEncryptor.key_len(Settings.encryptor.cipher)
      key_generator = ActiveSupport::KeyGenerator.new(Settings.encryptor.key)
      key = key_generator.generate_key(salt, cipher_key_len)

      ActiveSupport::MessageEncryptor.new(
        key,
        cipher:     Settings.encryptor.cipher,
        serializer: Marshal,
      )
    end

    def salt_of(attribute)
      column = encrypted_attributes[attribute][:salt_column]
      return nil if column.nil?
      send(column).to_s
    end

    def encrypted_attributes
      @encrypted_attributes ||= self.class.encrypted_attributes.dup
    end
  end
end
