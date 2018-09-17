require "test_helper"

class GuruTest < Minitest::Test

  def test_guru_default_theme_is_present
    guru = Rubyongo::Guru.new
    assert_includes guru.themes, "default"
  end

  def test_create_default_guru
    Rubyongo::Guru.create_default_guru
    guru = Rubyongo::Guru.first(:username => 'rubyongo')

    assert guru
  end

  def test_listing_archetypes
    guru = Rubyongo::Guru.new
    assert_equal ['item', 'page', 'post', 'project'].sort, guru.archetypes.sort
  end

end
