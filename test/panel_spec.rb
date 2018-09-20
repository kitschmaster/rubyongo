require "test_helper"

class PanelSpec < Rubyongo::Spec

  it "works" do
    visit "/panel"
    page.must_have_content 'GURU PANEL'
    page.must_have_content 'Tune in'
  end
end