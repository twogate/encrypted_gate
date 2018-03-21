# ==============================================================================
# test - test helper
# ==============================================================================
require 'minitest/autorun'
require 'minitest/spec'
require 'mocha/minitest'
require 'mocha/test_unit'
require 'rails'
require 'config'

require 'encrypted_gate'

Config.setup do |config|
  config.const_name = 'Settings'
  config.use_env = true
end

Config.load_and_set_settings('test/settings.yml')

MiniTest::Spec.class_eval do
  def self.shared_examples
    @shared_examples ||= {}
  end
end

module MiniTest::Spec::SharedExamples
  def shared_examples_for(desc, &block)
    MiniTest::Spec.shared_examples[desc] = block
  end

  def it_behaves_like(desc, *args)
    self.instance_exec(*args, &MiniTest::Spec.shared_examples[desc])
  end
end

Object.class_eval { include(MiniTest::Spec::SharedExamples) }
