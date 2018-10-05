require "test_helper"

class PanelSpec < Rubyongo::Spec

  it "works" do
    visit "/panel"
    page.must_have_content 'Guru Panel'
    page.must_have_content 'Tune in'
  end

  it "tunes a guru in and out" do
    tunein
    tuneout
  end

  private

    def tunein
      visit "/panel"

      click_on 'Tune in'
      page.must_have_content 'Name'
      page.must_have_content 'Pass'
      fill_in 'guru[username]', :with => 'rubyongo'
      fill_in 'guru[password]', :with => '3shop6shop9'
      find('button[type="submit"]').click
      page.must_have_content 'Successfully tuned in'
    end

    def tuneout
      click_on 'Drop out'
      page.must_have_content 'Successfully tuned out'
    end
end