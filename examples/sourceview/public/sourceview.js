$(document).ready(function(){
  $("#source").treeview({
    persist: 'location',
    unique: true,
    collapsed: true
  });

  $("span.file").click(function(){
    $("a.selected").removeClass('selected');
    $('#file').load('/source', { file: $(this).attr('name') });
    $('a',this).eq(0).addClass('selected');
  });

  $('a.selected').parent('span.file').click();
});