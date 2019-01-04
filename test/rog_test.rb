require "test_helper"

class RogTest < Minitest::Test

  def setup
    Dir.mkdir('tmp', 0700)
  end

  def teardown
    FileUtils.rm_rf('tmp') if Dir.exist?('tmp')
  end

  def test_rog_new
    r = `cd tmp; ../exe/rog new spin`
    assert_match 'Success', r
    settings_file = File.join('tmp', 'spin', 'panel.yml')
    assert_equal true, File.exist?(settings_file)
    settings = YAML.load_file(settings_file)
    assert_equal 'spin', settings['development']['usr']
    assert_equal 'spin.shop', settings['development']['host']
  end

  def test_rog_new_with_default_settings
    r = `cd tmp; ../exe/rog new spin.org`
    assert_match 'Success', r
    settings_file = File.join('tmp', 'spin.org', 'panel.yml')
    assert_equal true, File.exist?(settings_file)
    settings = YAML.load_file(settings_file)
    assert_equal 'spin', settings['development']['usr']
    assert_equal 'spin.org', settings['development']['host']
  end

  def test_rog_new_with_settings
    r = `cd tmp; ../exe/rog new spin.io spin_usr spin_host.com`
    assert_match 'Success', r
    settings_file = File.join('tmp', 'spin.io', 'panel.yml')
    assert_equal true, File.exist?(settings_file)
    settings = YAML.load_file(settings_file)
    assert_equal 'spin_usr', settings['development']['usr']
    assert_equal 'spin_host.com', settings['development']['host']
  end

  # This command returns the gem version used at creation time, >rog new< and >rog upgrade< both write the version out into a file named VERSION, >rog version< will read this file and present it.
  def test_rog_version
    r = `cd tmp; ../exe/rog new spin`
    assert_match 'Success', r

    r = `cd tmp; ../exe/rog version`
    refute_nil r
    assert_match ::Rubyongo.version, r
  end
end
