module SpecHelpers

  def visit_content_editor
    tunein
    visit "/content_editor"
    expect(page).must_have_css 'div#tree'
  end

  def tunein
    visit "/panel"
    click_on 'Tune in'
    expect(page).must_have_content 'Name'
    expect(page).must_have_content 'Pass'
    fill_in 'guru[username]', :with => 'rubyongo'
    fill_in 'guru[password]', :with => '3shop6shop9'
    find('button[type="submit"]').click
    expect(page).must_have_content 'Successfully tuned in'
  end

  def tuneout
    click_on 'Drop out'
    expect(page).must_have_content 'Successfully tuned out'
  end

  def find_by_id_and_open_node(html_id)
    # locate the node
    content_node = find_by_id(html_id)

    # open the 'content' node subtree
    content_node.sibling("i").click

    # return node for further manipulation
    content_node
  end
end