require "test_helper"

class PanelSpec < Rubyongo::Spec

  def test_it_works
    visit "/panel"
    assert page.has_content?('GURU PANEL')
  end
end