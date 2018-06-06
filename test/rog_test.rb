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
  end
end
