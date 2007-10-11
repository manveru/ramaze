$(document).ready(function(){
  $('ul.filetree').treeview({
    persist: 'location',
		animated: 'fast',
    unique: true,
    collapsed: true
  });

  $("span.file").click(function(){
    $('a.selected').removeClass('selected');
    $('#file_contents').load('/source', { file: $(this).attr('name') });
    $('a',this).eq(0).addClass('selected');
  });

  $('a.selected').parent('span.file').click();
});