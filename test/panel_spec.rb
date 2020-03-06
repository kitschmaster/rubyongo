require "test_helper"

class PanelSpec < Rubyongo::Spec

  it "works" do
    visit "/panel"
    expect(page).must_have_content 'rubyongo'.upcase
    expect(page).must_have_content 'Tune in'
  end

  it "tunes a guru in and out" do
    tunein
    tuneout
  end

  it "has a test" do
    tunein
    visit "/test"
    tuneout
  end
end
