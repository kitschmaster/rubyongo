require "test_helper"

class ContentEditorSpec < Rubyongo::Spec

  it "uploads from context menu" do
    visit_content_editor

    # get the 'content' node, and open it
    content_node = find_by_id_and_open_node('./content_anchor')

    # right click on the 'content' node in the jstree
    content_node.right_click

    # select from the context menu
    click_link('Upload')

    # the input#upload_path should now be set to "./content"
    assert find_field('path', visible: false).value, './content'

    # attaching a file does not work well when the file input is hidden
    # so making the form visible first
    page.driver.execute_script("$('form.upload-form').removeClass('hidden')")

    # then attaching and upload begins automatically
    attach_file('files[]', './static/img/rog_logo.png', visible: false)

    page.must_have_content "Uploaded"
    # checking for the filenames appear in the jsTree seems to result in intermittent failures
    # an issue with jsTree?
    # page.must_have_content "rog_logo.png"
    # page.must_have_content "rog_logo-thumb.png"

    file_exists = File.exists?("./content/rog_logo.png")

    assert_equal true, file_exists, "uploaded file should exist"

    # cleanup
    if file_exists
      FileUtils.rm_r("./content/rog_logo-thumb.png")
      FileUtils.rm_r("./content/rog_logo.png")
    end
  end

  it "creating a new node" do
    visit_content_editor

  end

end