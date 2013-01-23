$(function() {
  $('form').live('submit', function(){ PageLeave_onFormSubmit($(this)); }); // Must be last in this constructor. People may trigger buttons with keyboard or maybe in future in some other way.
  //$("textarea").live('change', function(){ PageLeave_markAsUnsaved($(this)); });
  $("select, input[type=text], input[type=password], input[type=file], input[type=checkbox], input[type=radio]").live('change', function(){ PageLeave_markAsUnsaved($(this)); });

  window.onbeforeunload = function() {
    var found_count = 0;
    $('.unsavedForm').each(function() {found_count += 1; });
    
    if(found_count > 0){
      return 'Are you sure you want to leave this page?';
    }else{
      return undefined;
    }
  }
});

function PageLeave_onFormSubmit(src) {
  //if($(src).hasClass('submissionDoesNotReloadPage')) {
    $(src).removeClass('unsavedForm');
  //}
}

function PageLeave_markAsUnsaved(src) {
  var form = $(src).parents('form');
  if(!form.hasClass("nonConfirmForm")){
    form.addClass('unsavedForm');  
  }
}

