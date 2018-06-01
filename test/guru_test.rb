require "test_helper"

class GuruTest < Minitest::Test

  def test_guru_default_theme_is_present
    guru = Rubyongo::Guru.new
    assert_equal guru.themes, ["default"]
  end

  def test_create_default_guru
    Rubyongo::Guru.create_default_guru
    guru = Rubyongo::Guru.first(:username => 'rubyongo')

    assert guru
  end
end
