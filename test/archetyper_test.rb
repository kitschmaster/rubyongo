require "test_helper"

class ArchetyperTest < Minitest::Test

  def test_listing_archetypes
    assert_equal Rubyongo::Archetyper.archetypes.sort, ["item", "page", "post", "project"].sort
  end

  def test_create_with_image
    image = ['item/example.png', 'item/example-thumb.png']

    Rubyongo::Archetyper.create_with_image('./', 'item', image)

    file = "./content/item/example.md"
    file_exists = File.exists?(file)
    assert_equal true, file_exists, "#{file} file should exist"

    content = File.read(file)
    assert_equal true, (content =~ /\(\/item\/example.png\)/) != nil, "#{file} should contain image tag"

    if file_exists
      FileUtils.rm_r(file)
    end
  end
end