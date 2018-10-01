/* rubyongo panel UI */

TEXT_TYPE = [ 'txt',
              'md',
              'htaccess',
              'log',
              'sql',
              'php',
              'js',
              'json',
              'css',
              'html' ];
String.prototype.capitalize = function() {
  return this.charAt(0).toUpperCase() + this.slice(1);
}
Array.prototype.containsAnyOf = function(elements) {
  //console.log(this + ' !containsAnyOf ' + elements);
  for (var i = elements.length - 1; i >= 0; i--) {
    var el = elements[i];
    for (var j = this.length - 1; j >= 0; j--) {
      // console.log("comparing : " + this[j] + ' <> ' + el);
      if (this[j] === el) {
        // console.log('!containsAnyOf = true');
        return true;
      }
    }
  }
  return false;
}

function log_object(title, obj) {
  $.each( obj, function(i, n){
    console.log( title + "-? Name: " + i + ", Value: " + n );
  });
}

/* menu */
/* **** */
function setupMenu() {
  var menu = document.getElementById('menu'),
      WINDOW_CHANGE_EVENT = ('onorientationchange' in window) ? 'orientationchange':'resize';

  document.getElementById('toggle').addEventListener('click', function (e) {
      toggleMenu();
  });

  window.addEventListener(WINDOW_CHANGE_EVENT, closeMenu);
}

function toggleHorizontal() {
    [].forEach.call(
        document.getElementById('menu').querySelectorAll('.menu-can-transform'),
        function(el){
            el.classList.toggle('pure-menu-horizontal');
        }
    );
};

function toggleMenu() {
    // set timeout so that the panel has a chance to roll up
    // before the menu switches states
    if (menu.classList.contains('open')) {
        setTimeout(toggleHorizontal, 500);
    }
    else {
        toggleHorizontal();
    }
    menu.classList.toggle('open');
    document.getElementById('toggle').classList.toggle('x');
};

function closeMenu() {
    if (menu.classList.contains('open')) {
        toggleMenu();
    }
};

/* time ago */
/* ******** */
function time_ago(time){
  switch (typeof time) {
      case 'number': break;
      case 'string': time = +new Date(time); break;
      case 'object': if (time.constructor === Date) time = time.getTime(); break;
      default: time = +new Date();
  }
  var time_formats = [
      [60, 'seconds', 1], // 60
      [120, '1 minute ago', '1 minute from now'], // 60*2
      [3600, 'minutes', 60], // 60*60, 60
      [7200, '1 hour ago', '1 hour from now'], // 60*60*2
      [86400, 'hours', 3600], // 60*60*24, 60*60
      [172800, 'Yesterday', 'Tomorrow'], // 60*60*24*2
      [604800, 'days', 86400], // 60*60*24*7, 60*60*24
      [1209600, 'Last week', 'Next week'], // 60*60*24*7*4*2
      [2419200, 'weeks', 604800], // 60*60*24*7*4, 60*60*24*7
      [4838400, 'Last month', 'Next month'], // 60*60*24*7*4*2
      [29030400, 'months', 2419200], // 60*60*24*7*4*12, 60*60*24*7*4
      [58060800, 'Last year', 'Next year'], // 60*60*24*7*4*12*2
      [2903040000, 'years', 29030400], // 60*60*24*7*4*12*100, 60*60*24*7*4*12
      [5806080000, 'Last century', 'Next century'], // 60*60*24*7*4*12*100*2
      [58060800000, 'centuries', 2903040000] // 60*60*24*7*4*12*100*20, 60*60*24*7*4*12*100
  ];
  var seconds = (+new Date() - time) / 1000,
      token = 'ago', list_choice = 1;

  if (seconds == 0) {
      return 'Just now'
  }
  if (seconds < 0) {
      seconds = Math.abs(seconds);
      token = 'from now';
      list_choice = 2;
  }
  var i = 0, format;
  while (format = time_formats[i++])
      if (seconds < format[0]) {
          if (typeof format[2] == 'string')
              return format[list_choice];
          else
              return Math.floor(seconds / format[2]) + ' ' + format[1] + ' ' + token;
      }
  return time;
}

/* markdown live preview editing */
/* ***************************** */
var Editor = (function(){
  TRIGGER_CONTENT_CHANGE = true;
  DEFAULT_ARCHETYPES     = ['post', 'project', 'item', 'page'];
  DEFAULT_THEME          = 'default';
  var editor = {},
      editor_preview     = '#editor_preview',
      editor_content     = '#editor_content',
      editor_save_button = '#editor_save',
      editor_refresh_preview_button = '#editor_refresh_preview',
      editor_auto_preview_checkbox  = '#auto_preview',
      editor_auto_preview = true;
      tree               = '#tree';
      converter          = new showdown.Converter(),
      editing            = false,
      originalContent    = null,
      currentContent     = null,
      currentPreview     = null,
      currentType        = null,
      currentId          = null,
      currentContentChanged = false,
      theme      = DEFAULT_THEME,
      archetypes = DEFAULT_ARCHETYPES;

  var create_folder_callback = function(node, status, cancelled){
    //console.log("create folder node "+node + " status " + status + " cancelled " + cancelled );
  };
  var create_file_callback = function(node, status, cancelled){
    //console.log("create file node "+node + " status " + status + " cancelled " + cancelled );
  };
  var contextmenu_items_callback = function(node) {
    log_object("contextmenu node", node);

    var current_archetype = 'File';
    var tmp = $.jstree.defaults.contextmenu.items();


    tmp.remove.icon = "fa fa-trash-o";
    tmp.rename.icon = "fa fa-recycle";

    //when right clicking the top level, hide remove and rename
    if (node.parent === '#') {
      delete tmp.remove;
      delete tmp.rename;
    }
    //when right clicking an archetype or second level, hide remove and rename
    if (node.parent === './content' && node.type === 'default') {
      delete tmp.remove;
      delete tmp.rename;
    }

    var isArchetyped = node.parents.containsAnyOf(archetypes.map(function(a){
      return './content/'+a;
    })) || archetypes.containsAnyOf([node.text]);
    if (isArchetyped === true) {
      current_archetype = node.id.split('/')[2].capitalize();//hardcoded array position here!
    }

    //remove cut&copy
    delete tmp.ccp;

    //redefine the create actions, new file/folder
    delete tmp.create.action;
    tmp.create.label = "New";
    tmp.create.icon = "fa fa-file-text";
    tmp.create.submenu = {
        "create_folder" : {
          "separator_after" : true,
          "icon" : "fa fa-file-o",
          "label"       : "Folder",
          "action"      : function (data) {
            var inst = $.jstree.reference(data.reference),
              obj = inst.get_node(data.reference);
            inst.create_node(obj, { type : "default", text: "path" }, "last", function (new_node) {
              setTimeout(function () { inst.edit(new_node, "path", create_folder_callback); },0);
            });
          }
        },
        "create_file" : {
          "label"       : current_archetype,
          "icon" : "fa fa-file-text-o",
          "action"      : function (data) {
            var inst = $.jstree.reference(data.reference),
              obj = inst.get_node(data.reference);
            inst.create_node(obj, { type : "file", text: "new.md" }, "last", function (new_node) {
              setTimeout(function () { inst.edit(new_node, "new.md", create_file_callback); },0);
            });
          }
        }
      };
    //when right clicking a file, hide create menu
    if(this.get_type(node) === 'file') {
      delete tmp.create;
    }

    tmp.copi = {
              "separator_before"  : true,
              "icon"        : 'fa fa-clipboard',
              "separator_after" : false,
              "label"       : "Copy",
              "action"      : function (data) {
                var inst = $.jstree.reference(data.reference),
                obj = inst.get_node(data.reference);
                $.get('/content_editor/node', { ids: obj.id }, function (d) {
                  //console.log('copi');
                  $(editor_content).val(function(index, value) {
                    return value + d.content;
                  });
                });
              }
            }
    return tmp;
  };
  var conditionalselect_callback = function(node, event) {
    //console.log("conditionalselect " + event.which);
    return ( event.which === 1 //only left clicks select
      && (node.parent !== '#')
      && (node.text !== 'item')
      && (node.text !== 'post')
      && (node.text !== 'page')
      && (node.text !== 'project')
      && (node.text !== 'atejas')
      && (node.text !== 'default')
      && currentContentChanged !== true);
  };

  //public

  editor.init = function(data){
    clear();
    initTree();
    $("textarea.editor_content").keyup(function(e) {
      //console.log("type: "+ $(this).val());
      setCurrentContent($(this).val(), TRIGGER_CONTENT_CHANGE);
      updatePreview();
    });
    $('.editor_content').on('changed', function(e){
      //console.log('editor content changed '+ e);
      showSaveMenu();
    });
    $(editor_save_button).on('click', function(e){
      //console.log('editor save button clicked!');
      doSave();
    });
    $('.editor_cancel').on('click', function(e){
      //console.log('editor cancel button clicked!');
      cancelSave();
    });
    $('.editor_config').on('click', function(e){
      //console.log('editor config clicked!');
      $.get('/content_editor/node', { ids: 'config' }, function (d) {
        //console.log('editing site config');
        Editor.load(d);
        $(tree).jstree('deselect_all');
        $('#tree_selection').html('Editing config');
        $('#tree_selection').removeClass('hidden');
      });
    });
    $('.editor_transend').on('click', function(e){
      //console.log('editor transend clicked!');
      doTransend();
    });
    $(editor_auto_preview_checkbox).on('click', function(e){
        if($(this).is(':checked')){
          //console.log("auto preview ON");
          editor_auto_preview = true;
          $(editor_refresh_preview_button).addClass('hidden');
        } else {
          //console.log("auto preview OFF");
          editor_auto_preview = false;
          $(editor_refresh_preview_button).removeClass('hidden');
        }
    });
    $(editor_refresh_preview_button).on('click', function(e){
      //console.log('refresh button');
      setCurrentContent($('textarea.editor_content').val());
      updatePreview(true);
      $(this).removeClass('button-warning');
    });
    if (data && data.content_published !== undefined) {
      archetypes = data.archetypes;
      theme = data.theme;
      refreshInfo(data);
    }
  };
  editor.unload = function(data){
    clear();
    editing         = false;
    originalContent = null;
    currentContent  = null;
    currentPreview  = null;
    currentType     = null;
    currentId       = null;
    archetypes = DEFAULT_ARCHETYPES;
    theme = DEFAULT_THEME;

  };
  editor.load = function(data){
    editing         = true;
    originalContent = data.content;
    currentContent  = originalContent;
    currentPreview  = data.preview;
    currentType     = data.type;
    currentId       = data.id;
    archetypes      = data.archetypes;
    theme           = data.theme;
    update();
  };

  //private
  function doTransend() {
    hideSaveMenu();
    //send publish request
    $.ajax({url: '/panel/transend', type: 'POST', success: function(data){
      if (data.error && data.error.length > 0) {
        doError(data);
      } else {
        //console.log('doTransend success! ' + data.content_published_at);
        refreshPublishButton(data);
      }
    }});
  }
  function showSaveMenu() {
    $('.editor_cancel').removeClass('hidden');
    $('.editor_save').removeClass('hidden');
    $(editor_refresh_preview_button).addClass('button-warning');
  }
  function hideSaveMenu() {
    $('.editor_cancel').addClass('hidden');
    $('.editor_save').addClass('hidden');
  }
  function cancelSave() {
    restoreOriginalContent();
    hideSaveMenu();
    update();
  }
  function doError(data) {
    alert("Error: " + data.error);
  }
  function doSave() {
    hideSaveMenu();
    if (currentContentChanged && $.inArray( currentType, TEXT_TYPE ) ) {
      //send save request
      $.ajax({url: '/content_editor/node', type: 'POST', data: {id: currentId, content: currentContent}, success: function(data){
        if (data.error && data.error.length > 0) {
          doError(data);
        } else {
          currentContentChanged = false;
          refreshPublishButton(data);
        }
      }});
    }
  }
  function updatePreview(preview) {
    if (editor_auto_preview === true || (preview && preview === true)) {
      if ( currentPreview && currentPreview.length > 0 ) {
        //console.log('updatePreview from preview');
        $(editor_preview).html(currentPreview).removeClass('hidden');
      } else {
        //console.log('updatePreview from content');
        $(editor_preview).html(converter.makeHtml(currentContent.replace( /\+\+\+(.|\n)*?\+\+\+/g, '' ).replace( /\-\-\-(.|\n)*?\-\-\-/g, '' ))).removeClass('hidden');
      }
    }
  }
  function updateContent(){
    //console.log('updateContent ' + currentContent.length + ' ' + editor_content);
    $(editor_content).val(currentContent);
    $(editor_content).removeClass('hidden');
  }
  function update(){
    updateContent();
    if (currentType === 'toml') {
      $(editor_preview).addClass('hidden');
    } else {
      $(editor_preview).addClass('hidden');
      updatePreview();
    }
  }
  function clear(){
    $(editor_content).val('');
    $(editor_preview).empty();
  }
  function setCurrentContent(content, trigger_content_changed) {
    currentContent = content;
    if (trigger_content_changed && trigger_content_changed === true) {
      currentContentChanged = true;
      $(".editor_content").trigger( "changed", [ currentContent ] );
    }
  }
  function restoreOriginalContent(){
    currentContent = originalContent;
    currentContentChanged = false;
  }
  function refreshTreeSelection(data){
    if (data && data.selected.length>1) {
      var i, j, r = [];
      for(i = 0, j = data.selected.length; i < j; i++) {
        r.push(data.instance.get_node(data.selected[i]).text);
      }
      $('#tree_selection').html(data.selected.length + ' selected: ' + r.join(', '));
      $('#tree_selection').removeClass('hidden');
    } else if (data && data.selected.length===1){
      $('#tree_selection').html(data.instance.get_node(data.selected[0]).text);
      $('#tree_selection').removeClass('hidden');
    } else {
      $('#tree_selection').addClass('hidden');
    }
  }
  function refreshInfo(data){
    if (data.content_published === true) {
      $('.content_changed_at').html('');
      $('.content_published_at').html('Published: '+ data.content_published_at);
    } else {
      $('.content_changed_at').html('Changed: ' + data.content_published_at);
      $('.content_published_at').html('');
    }
    $('.content_theme').html('Theme: ' + data.theme);
  }
  function refreshPublishButton(data){
    refreshInfo(data);
    if (data.content_published === true) {
      $('a.editor_transend').removeClass('button-warning');
      $('a.editor_transend').addClass('button-primary');
    } else {
      $('a.editor_transend').addClass('button-warning');
      $('a.editor_transend').removeClass('button-primary');
    }
  }
  function initTree(){
    $(tree).jstree({
      'core' : {
        'themes' : {
          'variant' : 'large'
        },
        'data' : {
          "url" : "/content_editor/data",
          "dataType" : "json", // needed only if you do not supply JSON headers
          'data' : function (node) {
            //console.log("calliing data "+ node);
            //log_object("node", node);
            return { 'id' : node.id };
          }
        },

        'check_callback' : true // so that create works
      },
      'state' : { "key" : "atejas" },
      'contextmenu' : {
        'items' : contextmenu_items_callback
      },
      'conditionalselect' : conditionalselect_callback,
      'types' : {
        'default' : { 'icon' : 'jstree-folder' },
        'file' : { 'valid_children' : [], 'icon' : 'jstree-file' }
      },
      'plugins' : [
          //"checkbox",
          "contextmenu",
          "dnd",
          //"massload",
          "search",
          //"sort",
          "state",
          "types",
          "unique",
          //"wholerow",
          //"changed",
          "conditionalselect"
      ]
    })
    .on('changed.jstree', function (e, data) {
      refreshTreeSelection(data);
      //console.log('changed.jstree !');
      //log_object("changed.jstree event ", e);
      if(data && data.selected && data.selected.length) {
        $.get('/content_editor/node', { ids: data.selected.join(':') }, function (d) {
          //console.log('changed.jstree ' + d.type);
          if(d && typeof d.type !== 'undefined') {
            //console.log('hiding editor.content')
            $(editor_content).addClass('hidden');
            $(editor_preview).addClass('hidden');
            switch(d.type) {
              case 'text':
              case 'txt':
              case 'md':
                Editor.load(d);
                //$('.editor_preview').html(converter.makeHtml(d.content).replace( /\+\+\+(.|\n)*?\+\+\+/g, '' )).removeClass('hidden');
                break;
              case 'htaccess':
              case 'log':
              case 'sql':
              case 'php':
                Editor.load(d);
                break;
              case 'js':
              case 'json':
              case 'css':
              case 'html':
                Editor.load(d);
                break;
              case 'png':
              case 'jpg':
              case 'jpeg':
              case 'bmp':
                Editor.load(d);
                break;
              case 'gif':
                //$('#data .image img').one('load', function () { $(this).css({'marginTop':'-' + $(this).height()/2 + 'px','marginLeft':'-' + $(this).width()/2 + 'px'}); }).attr('src',d.content);
                //$('#data .image').removeClass('hidden');
                Editor.load(d);
                break;
              case 'multiple':
                Editor.unload();
                break;
              case 'folder':
                Editor.unload();
                break;
              default:
                Editor.load(d);
                break;
            }
          } else {
            $(editor_content).html('Undefined');
          }
          $(editor_content).removeClass('hidden');
        });
      } else {
        //console.log('hiding content editor else')
        //$(editor_content).addClass('hidden');
      }
    })
    .on('delete_node.jstree', function (e, data) {
      $.post('/content_editor/delete_node', { 'id' : data.node.id })
        .done(function(d){
          refreshPublishButton(d);
        })
        .fail(function () {
              data.instance.refresh();
        });
    })
    .on('create_node.jstree', function (e, data) {
      $.post('/content_editor/create_node', { 'type' : data.node.type, 'id' : data.node.parent, 'text' : data.node.text })
        .done(function (d) {
          if (d.error) {
            alert("Error: " + d.error);
          } else {
            data.instance.set_id(data.node, d.id);
            refreshPublishButton(d);
          }
        })
        .fail(function () {
          data.instance.refresh();
        });
    })
    .on('move_node.jstree', function (e, data) {
      $.post('/content_editor/move_node', { 'id' : data.node.id, 'parent' : data.parent })
        .done(function (d) {
          //data.instance.load_node(data.parent);
          data.instance.refresh();
          refreshPublishButton(d);
        })
        .fail(function () {
          data.instance.refresh();
        });
        log_object('move node data', data);
    })
    .on('rename_node.jstree', function (e, data) {
            $.post('/content_editor/rename_node', { 'id' : data.node.id, 'text' : data.text })
              .done(function (d) {
                if (d.error) {
                  data.instance.refresh();
                  alert(d.error);
                } else {
                  data.instance.set_id(data.node, d.id);
                  refreshPublishButton(d);
                }
              })
              .fail(function () {
                data.instance.refresh();
              });
    });

    $(document).on('dnd_move.vakata', function (e, data) {
      //console.log("moving " + data + " event: " + e);
    })
    .on('dnd_stop.vakata', function (e, data) {
      //console.log("stop " + data + " event: " + e);
    });

    var to = false;
    $('#tree_q').keyup(function () {
      if(to) { clearTimeout(to); }
      to = setTimeout(function () {
        var v = $('#tree_q').val();
        $('#tree').jstree(true).search(v);
      }, 250);
    });
  }//initTree

  return editor;
})();

/* onload  */
/* ******  */

$(document).ready(function(){

  //setup global ajax error handling
  $(document).ajaxStart(function( event, jqxhr, settings, exception ) {
    $('#spinner').removeClass('hidden');
    $('body').addClass('s');
  });
  $(document).ajaxStop(function( event, jqxhr, settings, exception ) {
    $('#spinner').addClass('hidden');
    $('body').removeClass('s');
  });
  $(document).ajaxError(function( event, jqxhr, settings, exception ) {
    if ( jqxhr.status == 401 ) {
      alert('Session expired, please login before continuing.');
      //redirect
      window.location.href = "/";
    } else if (jqxhr.status == 422) {
      //this happens on unprocessable entity, validation failing
    } else if (jqxhr.status == 403) {
      alert('Forbidden');
    } else if (jqxhr.status === 0 && settings.url.indexOf("google") != -1) {
      alert("Oops!");
    } else if ( jqxhr.status === 0 && (exception==="canceled" || exception==="abort") ) {
      //do nothin, this happens on file upload, but does not need to be reported
    } else if ( jqxhr.status === 0 && ( exception.length < 1 )) {
      //do nothing, this happens when reloading page while AJAX still working...
      //console.log('jqxhr ERROR:' + jqxhr.status+"\nException: " + exception + "\n" + "URL: " + settings.url);
    } else {
      alert("Oops! Something went wrong: " + jqxhr.status+"\nException: " + exception + "\n" + "URL: " + settings.url);
    }
  });

  //don't let disabled links function
  $('body').on('click', 'a.disabled', function(event) {
    event.preventDefault();
  });

  setupMenu();
});
