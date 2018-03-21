# ==============================================================================
# test - active record test
# ==============================================================================
require 'test_helper'
require 'active_record'

db = :sqlite3

silence_warnings do
  ActiveRecord::Migration.verbose = false
  ActiveRecord::Base.logger = Logger.new(nil)
  ActiveRecord::Base.configurations = {
    'sqlite3' => {
      'adapter' => 'sqlite3',
      'database' => ':memory:'
    },
  }

  ActiveRecord::Base.establish_connection(db)
end

ActiveRecord::Base.connection.instance_eval do
  create_table :users do |t|
    t.string :name
    t.string :encrypted_email
    t.text   :encrypted_phrase
  end
end

class User < ActiveRecord::Base
  extend EncryptedGate

  encrypted_column :email,  salt_column: :name
  encrypted_column :phrase, salt_column: :name
end

describe EncryptedGate do
  shared_examples_for 'An Adapter' do
    it "uses #{@cipher_mode}" do
      assert_equal Settings.encryptor.cipher, @cipher_mode
    end

    it 'stores values as cipher and decrypt it' do
      @name = 'John Doe'
      @email = 'email@example.com'
      @phrase = 'Hello, World!'

      user = User.new(name: @name, email: @email, phrase: @phrase)
      user.save!

      user = User.find(user.id)

      assert_equal user.email, @email
      assert_equal user.phrase, @phrase

      refute_equal user.encrypted_email, nil
      refute_equal user.encrypted_phrase, nil
    end

    it 'return nil if nothins is set to the attribute' do
      user = User.new()

      assert_nil user.email
      assert_nil user.phrase
    end
  end

  describe 'aes-256-gcm' do
    before do
      @cipher_mode = 'aes-256-gcm'
      encryptor = Config::Options
      encryptor.stubs(:cipher).returns(@cipher_mode)
      encryptor.stubs(:digest).returns('SHA512')
      encryptor.stubs(:key).returns('this_is_key')
      Settings.stubs(:encryptor).returns(encryptor)
    end

    it_behaves_like 'An Adapter'

    describe 'gcm works without digest' do
      before do
        @cipher_mode = 'aes-256-gcm'
        encryptor = Config::Options
        encryptor.stubs(:cipher).returns(@cipher_mode)
        encryptor.stubs(:digest).returns(nil)
        encryptor.stubs(:key).returns('this_is_key')
        Settings.stubs(:encryptor).returns(encryptor)
      end

      it_behaves_like 'An Adapter'
    end
  end

  describe 'aes-256-cbc' do
    before do
      @cipher_mode = 'aes-256-cbc'
      encryptor = Config::Options
      encryptor.stubs(:cipher).returns(@cipher_mode)
      encryptor.stubs(:digest).returns('SHA512')
      encryptor.stubs(:key).returns('this_is_key')
      Settings.stubs(:encryptor).returns(encryptor)
    end

    it_behaves_like 'An Adapter'
  end
end
