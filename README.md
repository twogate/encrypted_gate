# EncryptedGate

Encrypt attributes.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'encrypted_gate'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install encrypted_gate

## Usage

EncryptGate require [config](https://github.com/railsconfig/config).
If you have changed config's `const_name`, EncrypteGate is not available for now.

Set `cipher`, `key`, `digest` like this.
If you use AEAD cipher, `digest` is not required.

```
encryptor:
  cipher: 'aes-256-gcm'
  key: 'this_is_a_secret_key'
  digest: 'SHA512'
```

The target column should start from `encrypted_`.

```
create_table :users do |t|
  t.string :name
  t.string :encrypted_email
  t.text   :encrypted_phrase
end
```

Then you can use like this.
`salt_column` should be set.

```
class User < ActiveRecord::Base
  extend EncryptedGate

  encrypted_column :email,  salt_column: :name
  encrypted_column :phrase, salt_column: :name
end
```
