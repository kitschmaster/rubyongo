require "test_helper"

class ContentEditorSpec < Rubyongo::Spec

  it "uploads from context menu" do
    visit_content_editor

    # right click on the "content" in the jstree
    find_by_id('./content_anchor').right_click
    click_link('Upload')
    # the input#upload_path should now be set to "./content"
    assert find_field('path', visible: false).value, './content'

    # attaching a file is hard if the file input is hidden, so how do we test this?
    # making the form visible first!
    page.driver.execute_script("$('form.upload-form').removeClass('hidden')")
    # then attaching and upload begins automatically
    attach_file('files[]', './public/img/rog_logo.png', visible: false)

    assert_equal true, File.exists?("./content/rog_logo.png"), "uploaded file should exist"
  end

end