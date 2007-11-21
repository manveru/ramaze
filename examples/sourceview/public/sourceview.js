var curfile = null;

function setup() {
  $('ul.filetree').treeview({
    persist: 'location',
    animated: 'fast',
    unique: true
  });

  $("span.file").click(function(){
    file = $('a:eq(0)', this).attr('href').substr(1);
    if (curfile != file) {
      curfile = file;
      $('a.selected').removeClass('selected');
      $('#file_contents').load('/source', { file: curfile });
      $('a',this).eq(0).addClass('selected');
    }

    if (curfile)
      $('#repourl').empty().append( $('<a/>').attr('href', 'http://darcs.ramaze.net/ramaze'+curfile).text('download '+curfile.substr(1)) );
  });

  $('a.selected').parent('span.file').click();
}

$(function(){
  if (document.location.hash != '') {
    curfile = document.location.hash.substr(1);
    $('#file_contents').load('/source', { file: curfile }, setup);
  } else {
    setup();
  }
});