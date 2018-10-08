module SpecHelpers

  def visit_content_editor
    tunein
    visit "/content_editor"
    page.must_have_css 'div#tree'
  end

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