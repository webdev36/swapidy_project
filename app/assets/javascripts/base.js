
$(function() {

  var container = $('#container');
  container.isotope({
    itemSelector : '.item',
    layoutMode : 'fitRows'
  });

//footer
  $('#footer_fb').mouseover(function(){
    $(this).attr("src",'/images/footer_fb_hover.png');
  })
  .mouseout(function(){
    $(this).attr("src",'/images/footer_fb.png');
  });
  
  $('#footer_twitter').mouseover(function(){
    $(this).attr("src",'/images/footer_twitter_hover.png');
  })
  .mouseout(function(){
    $(this).attr("src",'/images/footer_twitter.png');
  });
  
  //popup
  $("#popup-box-bg").live("click", function(){
    hidePopup();
  });
  
  //honey scoreboard
  $('.honey_currency_plus').mouseover(function(){
    $(this).attr("src",'/images/honey_currency_plus_hover.png');
  })
  .mouseout(function(){
    $(this).attr("src",'/images/honey_currency_plus.png');
  });

    $('.nav_notification').mouseover(function(){
    $(this).attr("src",'/images/notification_icon_hover.png');
  })
  .mouseout(function(){
    $(this).attr("src",'/images/notification_icon.png');
  });

    $('#profile_group').mouseover(function(){
    $(this).attr("src",'/images/profile_icon_hover.png');
  })
  .mouseout(function(){
    $(this).attr("src",'/images/profile_icon.png');
  });
    $('.nav_down').mouseover(function(){
    $(this).attr("src",'/images/down_icon_hover.png');
  })
  .mouseout(function(){
    $(this).attr("src",'/images/down_icon.png');
  });
  $('.nav_settings').mouseover(function(){
    $(this).attr("src",'/images/settings_icon_hover.png');
  })
  .mouseout(function(){
    $(this).attr("src",'/images/settings_icon.png');
  });

  $('.vote_button').click(function(){
    $(this).attr("src","/images/vote_after.png");
});
});

function open_in_new_tab(url)
{
  window.open(url, '_blank');
  window.focus();
}

// popup boxes - pass popup box ID as parameter (needs "popup-box-bg" empty div that is used as mask)
function showPopup(element_id) {
  $("#popup-box-bg").show();
  $('.active-popup').removeClass('active-popup').hide();
  $('#' + element_id).addClass('active-popup');
  $('#' + element_id).fadeIn('fast', function (){
    //resetPopupSize(element_id);
  });
}

function hidePopup() {
  $('#popup-box-bg').fadeOut('fast');
  $('.active-popup').hide();
  $('.active-popup').removeClass('active-popup');
}


function showLoader(element_id) {
  var popupHeight = $(element_id).height();
  var popupWidth = $(element_id).width();
  if(popupWidth == 0) popupWidth = 400;
  if(popupHeight == 0) popupHeight = 200;
  $(element_id).html("<div class='loader' style='width: " + popupWidth + "px; height: " + popupHeight + "px;'><img src='/assets/loading.gif' /></div>");
}