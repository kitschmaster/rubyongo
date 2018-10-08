require "test_helper"

class PanelSpec < Rubyongo::Spec

  it "works" do
    visit "/panel"
    page.must_have_content 'Guru Panel'.upcase
    page.must_have_content 'Tune in'
  end

  it "tunes a guru in and out" do
    tunein
    tuneout
  end
end
