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
   $('.media_pando').mouseover(function(){
    $(this).attr("src",'/images/media/1_hover.png');
  })
  .mouseout(function(){
    $(this).attr("src",'/images/media/1.png');
  });
    $('.media_hn').mouseover(function(){
    $(this).attr("src",'/images/media/4_hover.jpg');
  })
  .mouseout(function(){
    $(this).attr("src",'/images/media/4.jpg');
  });

  $('.media_patch').mouseover(function(){
    $(this).attr("src",'/images/media/2_hover.png');
  })
  .mouseout(function(){
    $(this).attr("src",'/images/media/2.png');
  });
   $('.media_technori').mouseover(function(){
    $(this).attr("src",'/images/media/3_hover.png');
  })
  .mouseout(function(){
    $(this).attr("src",'/images/media/3.png');
  });
  $(".see_more_sell ").toggle(function(){
	$(".sell_display").css("overflow","visible");
	$(".sell_display").css("height","auto");
	//$('dropdow_item').css("-webkit-transform","180deg");
	//$(this).text("Hide")
  },function(){
		$(".sell_display").css("overflow","hidden");
		$(".sell_display").css("height","120px");
		//$(this).text("Show All")
		//$('sell_display').addClass('hide_item');


	});
	
  $(".see_more_buy").toggle(function(){
	$(".buy_display").css("overflow","visible");
	$(".buy_display").css("height","auto");
	//$(this).text("Hide")
  },function(){
	  $(".buy_display").css("overflow","hidden");
	  $(".buy_display").css("height","120px");
	  //$(this).text("Show All")
  });
  $(".del-product").live('click',function(){		
		var url_ajax = '/home/del_product';
		var order_product_id = $(this).attr('order_product_id');
		$.ajax({
			url :url_ajax,
			beforeSend : function(xhr) {
            xhr.setRequestHeader('X-CSRF-Token', $('meta[name="csrf-token"]').attr('content'))
          	},
			type: "POST",
			data: 'order_id=' + order_product_id,
			dataType:'script',
			success :function(){
				 
			}
		});
		return false;
	}); 
   	  
	  
  $('.popup_select_price .price_type').live('click', function(){
  	var url_select_price = '/home/swap_product';
		$.ajax({
			url : url_select_price,
			beforeSend : function(xhr) {
	        	xhr.setRequestHeader('X-CSRF-Token', $('meta[name="csrf-token"]').attr('content'))
	      	},
	      	data:'product_id=' + $(this).attr('product-id')+ '&price='+$(this).attr('product-price')+ '&type='+$(this).attr('type')+ '&condition='+$(this).attr('product-using_condition'),
			type: 'POST',
			dataType: 'script', 
			success:function(){
				 //location.reload();
			}
		});
  });
  
  $(".button_for_buy a, .button_for_sell a").live("click", function(){
  	var popup_id = $(this).attr("popup_id");
  	var $isotope_item = $(this).parent().parent().parent().parent(); 
  	new_left = $isotope_item.position().left + 16;
  	new_top = $isotope_item.position().top + 250;
  	
  	$('#' + popup_id).css({"left": new_left + 'px', "top": new_top + 'px'});
  	$('#' + popup_id).css({"opacity": '1', "-webkit-transform": 'none', "transform": 'none', 'display': 'block'});
  	$('#' + popup_id).removeClass('isotope-item');
  	$('#' + popup_id).removeClass('isotope-hidden');
  	if($('#' + popup_id).hasClass('active')){
	    $('#' + popup_id).removeClass('active');
	    $('#' + popup_id).hide();
	    current_popup_id = "";
	  }else{
	  	if(current_popup_id != ""){
	  		$('#' + current_popup_id).hide();
	  	}
	    $('#' + popup_id).addClass('active');
	    $('#' + popup_id).show();
	    current_popup_id = popup_id;
	  }
  });
});

var current_popup_id = "";

function goto_checkout(){
   sell_count = 0;
   $("#product_items .sell_display .cart_product_thumb").each(function(){
   	sell_count += 1;
   });
   
   buy_count = 0;
   $("#product_items .buy_display .cart_product_thumb").each(function(){
   	buy_count += 1;
   });
   if(buy_count == 0 || sell_count == 0) {
   	 alert("You have not selected any sell/buy products");
   }else{
   	 window.location = "/orders/new";	
   }
   
}
	
function switchToCheckoutStep(form_id, step_url) {
  $("#" + form_id).attr("action", step_url);
  $("#" + form_id).submit();
}

function display_guide() {
  //guiders
  //if(userLoggedIn && userViews == 1)
  guiders.createGuider({
  buttons: [{ name: "Close" },
    { name: "Next" }],
  description: "Welcome to Swapidy! We'll tell you everything you need to get started step by step.",
  id: "first",
  next: "second",
  overlay: true,
  title: "Welcome to Swapidy!"
  }).show();

  guiders.createGuider({
  attachTo: "#location_search",
  buttons: [{ name: "Close" },
    { name: "Next" }],
  description: "Click on this tab to choose which location you're in.",
  id: "second",
  next: "third",
  position: '6',
  width:400,
  title: "Where you at?",
  overlay: true
  });
  
  guiders.createGuider({
  attachTo: ".nav_notification",
  buttons: [{ name: "Close" },
    { name: "Next" }],
  description: "Anytime there's any new news with your transactions, you'll receive a notification here. ",
  id: "third",
  next: "fourth",
  position: '6',
  title: "All your notifications",
  width: 400,
  overlay: true
  });

  guiders.createGuider({
  attachTo: ".nav_profile",
  buttons: [{ name: "Close" },
    { name: "Next" }],
  description: "All of your transaction history will be displayed here. ",
  id: "fourth",
  next: "fifth",
  position: '6',
  title: "Everything you do goes here",
  width: 400,
  overlay: true
  });

  guiders.createGuider({
  attachTo: ".nav_settings",
  buttons: [{ name: "Close" },
    { name: "Next" }],
  description: "All of your account settings will be displayed here (name, password, credit card).",
  id: "fifth",
  next: "sixth",
  position: '6',
  title: "All your settings",
  width: 400,
  overlay: true
  });

  guiders.createGuider({
  attachTo: ".honey_display",
  buttons: [{ name: "Close" },
    { name: "Next" }],
  description: "<img src='/images/honey_20px_grey.png'> is our Honey currency symbol. This box shows how much Honey currency you have. If you click on the plus sign, you can add Honey to your account.",
  id: "sixth",
  next: "seventh",
  position: '9',
  title: "Add Honey to your account",
  overlay: true,
  width:500
  });

  guiders.createGuider({
  attachTo: ".sell_now",
  buttons: [{ name: "Close" }],
  description: "Start selling by clicking sell now and choosing the correct model.",
  id: "seventh",
  next: "eighth",
  position: '12',
  width:400,
  title: "You're good to go!",
  overlay: false
  });



  //}
  
  
}

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

function showPageLoading() {
  $("#page_loading_animation").show();
}

function hidePageLoading() {
  $("#page_loading_animation").hide();
}

function submit_signin_form(){
  $("#popup-dialog_for_signin form").removeClass('unsavedForm');
  $.ajax({
    type : 'POST',
    url : $("#popup-dialog_for_signin form").attr("action"),
    data : $("#popup-dialog_for_signin form").serialize(),
    dataType : 'script',
    success: function(data) {}
  });
}
function submit_signup_form(){
  $("#popup-dialog_for_signup form").removeClass('unsavedForm');
  $.ajax({
    type : 'POST',
    url : $("#popup-dialog_for_signup form").attr("action"),
    data : $("#popup-dialog_for_signup form").serialize(),
    dataType : 'script',
    success: function(data) {}
  });
}

/**
 * guiders.js
 *
 * version 1.3.0
 *
 * Developed at Optimizely. (www.optimizely.com)
 * We make A/B testing you'll actually use.
 *
 * Released under the Apache License 2.0.
 * www.apache.org/licenses/LICENSE-2.0.html
 *
 * Questions about Guiders?
 * You may email me (Jeff Pickhardt) at pickhardt+guiders@gmail.com
 *
 * Questions about Optimizely should be sent to:
 * sales@optimizely.com or support@optimizely.com
 *
 * Enjoy!
 */

var guiders = (function($) {
  var guiders = {};
  
  guiders.version = "1.3.0";

  guiders._defaultSettings = {
    attachTo: null, // Selector of the element to attach to.
    autoFocus: false, // Determines whether or not the browser scrolls to the element.
    buttons: [{name: "Close"}],
    buttonCustomHTML: "",
    classString: null,
    closeOnEscape: false,
    description: "Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.",
    highlight: null,
    isHashable: true,
    offset: {
      top: null,
      left: null
    },
    onClose: null, 
    onHide: null,
    onShow: null,
    overlay: false,
    position: 0, // 1-12 follows an analog clock, 0 means centered.
    shouldSkip: function() {}, // Optional handler allows you to skip a guider if returns true.
    title: "Sample title goes here",
    width: 400,
    xButton: false // This places a closer "x" button in the top right of the guider.
  };

  guiders._htmlSkeleton = [
    "<div class='guider'>",
    "  <div class='guiders_content'>",
    "    <div class='guiders_title'></div>",
    "    <div class='guiders_close'></div>",
    "    <p class='guiders_description'></p>",
    "    <div class='guiders_buttons_container'>",
    "    </div>",
    "  </div>",
    "  <div class='guiders_arrow'>",
    "  </div>",
    "</div>"
  ].join("");

  guiders._arrowSize = 42; // This is the arrow's width and height.
  guiders._backButtonTitle = "Back";
  guiders._buttonAttributes = {"href": "javascript:void(0);"};
  guiders._buttonClassName = "guiders_button"; // Override this if you use a different class name for your buttons.
  guiders._buttonClickEvent = "click touch"; // Using click touch allows this to trigger with iPad/iPhone taps, as well as browser clicks
  guiders._buttonElement = "<a></a>"; // Override this if you want to use a different element for your buttons, like spans.
  guiders._closeButtonTitle = "Close";
  guiders._currentGuiderID = null;
  guiders._fixedOrAbsolute = "fixed";
  guiders._guiders = {};
  guiders._lastCreatedGuiderID = null;
  guiders._nextButtonTitle = "Next";
  guiders._offsetNameMapping = {
    "topLeft": 11,
    "top": 12,
    "topRight": 1,
    "rightTop": 2,
    "right": 3,
    "rightBottom": 4,
    "bottomRight": 5,
    "bottom": 6,
    "bottomLeft": 7,
    "leftBottom": 8,
    "left": 9,
    "leftTop": 10
  };
  guiders._windowHeight = 0;
  
  // Basic IE browser detection
  var ieBrowserMatch = navigator.userAgent.match('MSIE (.)');
  guiders._isIE = ieBrowserMatch && ieBrowserMatch.length > 1;
  guiders._ieVersion = ieBrowserMatch && ieBrowserMatch.length > 1 ? Number(ieBrowserMatch[1]) : -1;
  
  guiders._addButtons = function(myGuider) {
    var guiderButtonsContainer = myGuider.elem.find(".guiders_buttons_container");
  
    if (myGuider.buttons === null || myGuider.buttons.length === 0) {
      guiderButtonsContainer.remove();
      return;
    }
  
    for (var i = myGuider.buttons.length - 1; i >= 0; i--) {
      var thisButton = myGuider.buttons[i];
      var thisButtonElem = $(guiders._buttonElement,
        $.extend({"class" : guiders._buttonClassName, "html" : thisButton.name }, guiders._buttonAttributes, thisButton.html || {})
      );

      if (typeof thisButton.classString !== "undefined" && thisButton.classString !== null) {
        thisButtonElem.addClass(thisButton.classString);
      }
  
      guiderButtonsContainer.append(thisButtonElem);
      
      var thisButtonName = thisButton.name.toLowerCase();
      if (thisButton.onclick) {
        thisButtonElem.bind(guiders._buttonClickEvent, thisButton.onclick);
      } else {
        switch (thisButtonName) {
          case guiders._closeButtonTitle.toLowerCase():
            thisButtonElem.bind(guiders._buttonClickEvent, function () {
              guiders.hideAll();
              if (myGuider.onClose) {
                myGuider.onClose(myGuider, false /* close by button */);
              }
            });
            break;
          case guiders._nextButtonTitle.toLowerCase():
            thisButtonElem.bind(guiders._buttonClickEvent, function () {
              !myGuider.elem.data("locked") && guiders.next();
            });
            break;
          case guiders._backButtonTitle.toLowerCase():
            thisButtonElem.bind(guiders._buttonClickEvent, function () {
              !myGuider.elem.data("locked") && guiders.prev();
            });
            break;
        }
      }
    }
  
    if (myGuider.buttonCustomHTML !== "") {
      var myCustomHTML = $(myGuider.buttonCustomHTML);
      myGuider.elem.find(".guiders_buttons_container").append(myCustomHTML);
    }
  
    if (myGuider.buttons.length === 0) {
      guiderButtonsContainer.remove();
    }
  };

  guiders._addXButton = function(myGuider) {
    var xButtonContainer = myGuider.elem.find(".guiders_close");
    var xButton = $("<div></div>", {
      "class" : "guiders_x_button",
      "role" : "button"
    });
    xButtonContainer.append(xButton);
    xButton.click(function() {
      guiders.hideAll();
      if (myGuider.onClose) {
        myGuider.onClose(myGuider, true);
       }
    });
  };

  guiders._wireEscape = function (myGuider) {
    $(document).keydown(function(event) {
      if (event.keyCode == 27 || event.which == 27) {
        guiders.hideAll();
        if (myGuider.onClose) {
          myGuider.onClose(myGuider, true /*close by X/Escape*/);
        }
        return false;
      }
    });      
  };

  guiders._unWireEscape = function (myGuider) {
    $(document).unbind("keydown");
  };
  
  guiders._attach = function(myGuider) {
    if (typeof myGuider !== 'object') {
      return;
    }
        
    var attachTo = $(myGuider.attachTo);

    var myHeight = myGuider.elem.innerHeight();
    var myWidth = myGuider.elem.innerWidth();

    if (myGuider.position === 0 || attachTo.length === 0) {
      var fixedOrAbsolute = "fixed";
      if (guiders._isIE && guiders._ieVersion < 9) {
        fixedOrAbsolute = "absolute";
      }
      myGuider.elem.css("position", fixedOrAbsolute);
      myGuider.elem.css("top", ($(window).height() - myHeight) / 3 + "px");
      myGuider.elem.css("left", ($(window).width() - myWidth) / 2 + "px");
      return;
    }
    
    // Otherwise, the guider is positioned relative to the attachTo element.
    var base = attachTo.offset();
    var top = base.top;
    var left = base.left;
    
    // topMarginOfBody corrects positioning if body has a top margin set on it.
    var topMarginOfBody = $("body").outerHeight(true) - $("body").outerHeight(false);
    top -= topMarginOfBody;

    // Now, take into account how the guider should be positioned relative to the attachTo element.
    // e.g. top left, bottom center, etc.
    if (guiders._offsetNameMapping[myGuider.position]) {
      // As an alternative to the clock model, you can also use keywords to position the guider.
      myGuider.position = guiders._offsetNameMapping[myGuider.position];
    }
    
    var attachToHeight = attachTo.innerHeight();
    var attachToWidth = attachTo.innerWidth();  
    var bufferOffset = 0.9 * guiders._arrowSize;
    
    // offsetMap follows the form: [height, width]
    var offsetMap = {
      1: [-bufferOffset - myHeight, attachToWidth - myWidth],
      2: [0, bufferOffset + attachToWidth],
      3: [attachToHeight/2 - myHeight/2, bufferOffset + attachToWidth],
      4: [attachToHeight - myHeight, bufferOffset + attachToWidth],
      5: [bufferOffset + attachToHeight, attachToWidth - myWidth],
      6: [bufferOffset + attachToHeight, attachToWidth/2 - myWidth/2],
      7: [bufferOffset + attachToHeight, 0],
      8: [attachToHeight - myHeight, -myWidth - bufferOffset],
      9: [attachToHeight/2 - myHeight/2, -myWidth - bufferOffset],
      10: [0, -myWidth - bufferOffset],
      11: [-bufferOffset - myHeight, 0],
      12: [-bufferOffset - myHeight, attachToWidth/2 - myWidth/2]
    };
    
    var offset = offsetMap[myGuider.position];
    top += offset[0];
    left += offset[1];
    
    var positionType = "absolute";
    // If the element you are attaching to is position: fixed, then we will make the guider
    // position: fixed as well.
    if (attachTo.css("position") === "fixed" && guiders._fixedOrAbsolute === "fixed") {
      positionType = "fixed";
      top -= $(window).scrollTop();
      left -= $(window).scrollLeft();
    }
    
    // If you specify an additional offset parameter when you create the guider, it gets added here.
    if (myGuider.offset.top !== null) {
      top += myGuider.offset.top;
    }
    if (myGuider.offset.left !== null) {
      left += myGuider.offset.left;
    }
    
    guiders._styleArrow(myGuider);
    
    // Finally, set the style of the guider and return it!
    myGuider.elem.css({
      "position": positionType,
      "top": top,
      "left": left
    });
    
    return myGuider;
  };

  guiders._guiderById = function(id) {
    if (typeof guiders._guiders[id] === "undefined") {
      throw "Cannot find guider with id " + id;
    }
    return guiders._guiders[id];
  };

  guiders._showOverlay = function() {
    // This callback is needed to fix an IE opacity bug.
    // See also:
    // http://www.kevinleary.net/jquery-fadein-fadeout-problems-in-internet-explorer/
    $("#guiders_overlay").fadeIn("fast", function(){
      if (this.style.removeAttribute) {
        this.style.removeAttribute("filter");
      }
    });
    if (guiders._isIE) {
      $("#guiders_overlay").css("position", "absolute");
    }
  };

  guiders._highlightElement = function(selector) {
    $(selector).addClass('guiders_highlight');
  };

  guiders._dehighlightElement = function(selector) {
    $(selector).removeClass('guiders_highlight');
  };

  guiders._hideOverlay = function() {
    $("#guiders_overlay").fadeOut("fast");
  };

  guiders._initializeOverlay = function() {
    if ($("#guiders_overlay").length === 0) {
      $("<div id='guiders_overlay'></div>").hide().appendTo("body");
    }
  };

  guiders._styleArrow = function(myGuider) {
    var position = myGuider.position || 0;
    if (!position) {
      return;
    }
    var myGuiderArrow = $(myGuider.elem.find(".guiders_arrow"));
    var newClass = {
      1: "guiders_arrow_down",
      2: "guiders_arrow_left",
      3: "guiders_arrow_left",
      4: "guiders_arrow_left",
      5: "guiders_arrow_up",
      6: "guiders_arrow_up",
      7: "guiders_arrow_up",
      8: "guiders_arrow_right",
      9: "guiders_arrow_right",
      10: "guiders_arrow_right",
      11: "guiders_arrow_down",
      12: "guiders_arrow_down"
    };
    myGuiderArrow.addClass(newClass[position]);
  
    var myHeight = myGuider.elem.innerHeight();
    var myWidth = myGuider.elem.innerWidth();
    var arrowOffset = guiders._arrowSize / 2;
    var positionMap = {
      1: ["right", arrowOffset],
      2: ["top", arrowOffset],
      3: ["top", myHeight/2 - arrowOffset],
      4: ["bottom", arrowOffset],
      5: ["right", arrowOffset],
      6: ["left", myWidth/2 - arrowOffset],
      7: ["left", arrowOffset],
      8: ["bottom", arrowOffset],
      9: ["top", myHeight/2 - arrowOffset],
      10: ["top", arrowOffset],
      11: ["left", arrowOffset],
      12: ["left", myWidth/2 - arrowOffset]
    };
    var position = positionMap[myGuider.position];
    myGuiderArrow.css(position[0], position[1] + "px");
  };

  /**
   * One way to show a guider to new users is to direct new users to a URL such as
   * http://www.mysite.com/myapp#guider=welcome
   *
   * This can also be used to run guiders on multiple pages, by redirecting from
   * one page to another, with the guider id in the hash tag.
   *
   * Alternatively, if you use a session variable or flash messages after sign up,
   * you can add selectively add JavaScript to the page: "guiders.show('first');"
   */
  guiders._showIfHashed = function(myGuider) {
    var GUIDER_HASH_TAG = "guider=";
    var hashIndex = window.location.hash.indexOf(GUIDER_HASH_TAG);
    if (hashIndex !== -1) {
      var hashGuiderId = window.location.hash.substr(hashIndex + GUIDER_HASH_TAG.length);
      if (myGuider.id.toLowerCase() === hashGuiderId.toLowerCase()) {
        guiders.show(myGuider.id);
      }
    }
  };

  guiders.reposition = function() {
    var currentGuider = guiders._guiders[guiders._currentGuiderID];
    guiders._attach(currentGuider);
  };
  
  guiders.next = function() {
    var currentGuider = guiders._guiders[guiders._currentGuiderID];
    if (typeof currentGuider === "undefined") {
      return;
    }
    currentGuider.elem.data("locked", true);

    var nextGuiderId = currentGuider.next || null;
    if (nextGuiderId !== null && nextGuiderId !== "") {
      var nextGuider = guiders._guiderById(nextGuiderId);
      var omitHidingOverlay = nextGuider.overlay ? true : false;
      guiders.hideAll(omitHidingOverlay, true);
      if (currentGuider && currentGuider.highlight) {
        guiders._dehighlightElement(currentGuider.highlight);
      }
      if (nextGuider.shouldSkip && nextGuider.shouldSkip()) {
        guiders._currentGuiderID = nextGuider.id;
        guiders.next();
        return;
      }
      else {
        guiders.show(nextGuiderId);
      }
    }
  };

  guiders.prev = function () {
    var currentGuider = guiders._guiders[guiders._currentGuiderID];
    if (typeof currentGuider === "undefined") {
      // not what we think it is
      return;
    }
    if (currentGuider.prev === null) {
      // no previous to look at
      return;
    }
  
    var prevGuider = guiders._guiders[currentGuider.prev];
    prevGuider.elem.data("locked", true);
    
    // Note we use prevGuider.id as "prevGuider" is _already_ looking at the previous guider
    var prevGuiderId = prevGuider.id || null;
    if (prevGuiderId !== null && prevGuiderId !== "") {
      var myGuider = guiders._guiderById(prevGuiderId);
      var omitHidingOverlay = myGuider.overlay ? true : false;
      guiders.hideAll(omitHidingOverlay, true);
      if (prevGuider && prevGuider.highlight) {
        guiders._dehighlightElement(prevGuider.highlight);
      }
      guiders.show(prevGuiderId);
    }
  };

  guiders.createGuider = function(passedSettings) {
    if (passedSettings === null || passedSettings === undefined) {
      passedSettings = {};
    }
    
    // Extend those settings with passedSettings
    myGuider = $.extend({}, guiders._defaultSettings, passedSettings);
    myGuider.id = myGuider.id || String(Math.floor(Math.random() * 1000));
    
    var guiderElement = $(guiders._htmlSkeleton);
    myGuider.elem = guiderElement;
    if (typeof myGuider.classString !== "undefined" && myGuider.classString !== null) {
      myGuider.elem.addClass(myGuider.classString);
    }
    myGuider.elem.css("width", myGuider.width + "px");
    
    var guiderTitleContainer = guiderElement.find(".guiders_title");
    guiderTitleContainer.html(myGuider.title);
    
    guiderElement.find(".guiders_description").html(myGuider.description);
    
    guiders._addButtons(myGuider);
    
    if (myGuider.xButton) {
        guiders._addXButton(myGuider);
    }
    
    guiderElement.hide();
    guiderElement.appendTo("body");
    guiderElement.attr("id", myGuider.id);
    
    // Ensure myGuider.attachTo is a jQuery element.
    if (typeof myGuider.attachTo !== "undefined" && myGuider !== null) {
      guiders._attach(myGuider);
    }
    
    guiders._initializeOverlay();
    
    guiders._guiders[myGuider.id] = myGuider;
    if (guiders._lastCreatedGuiderID != null) {
      myGuider.prev = guiders._lastCreatedGuiderID;
    }
    guiders._lastCreatedGuiderID = myGuider.id;
    
    /**
     * If the URL of the current window is of the form
     * http://www.myurl.com/mypage.html#guider=id
     * then show this guider.
     */
    if (myGuider.isHashable) {
      guiders._showIfHashed(myGuider);
    }
    
    return guiders;
  }; 

  guiders.hideAll = function(omitHidingOverlay, next) {
    next = next || false;

    $(".guider:visible").each(function(index, elem){
      var myGuider = guiders._guiderById($(elem).attr('id'));
      if (myGuider.onHide) {
        myGuider.onHide(myGuider, next);
      }
    });
    $(".guider").fadeOut("fast");
    var currentGuider = guiders._guiders[guiders._currentGuiderID];
    if (currentGuider && currentGuider.highlight) {
    	guiders._dehighlightElement(currentGuider.highlight);
    }
    if (typeof omitHidingOverlay !== "undefined" && omitHidingOverlay === true) {
      // do nothing for now
    } else {
      guiders._hideOverlay();
    }
    return guiders;
  };

  guiders.show = function(id) {
    if (!id && guiders._lastCreatedGuiderID) {
      id = guiders._lastCreatedGuiderID;
    }
  
    var myGuider = guiders._guiderById(id);
    if (myGuider.overlay) {
      guiders._showOverlay();
      // if guider is attached to an element, make sure it's visible
      if (myGuider.highlight) {
        guiders._highlightElement(myGuider.highlight);
      }
    }
    
    if (myGuider.closeOnEscape) {
      guiders._wireEscape(myGuider);
    } else {
      guiders._unWireEscape(myGuider);
    }
  
    // You can use an onShow function to take some action before the guider is shown.
    if (myGuider.onShow) {
      myGuider.onShow(myGuider);
    }
    guiders._attach(myGuider);
    myGuider.elem.fadeIn("fast").data("locked", false);
      
    guiders._currentGuiderID = id;
    
    var windowHeight = guiders._windowHeight = $(window).height();
    var scrollHeight = $(window).scrollTop();
    var guiderOffset = myGuider.elem.offset();
    var guiderElemHeight = myGuider.elem.height();
    
    var isGuiderBelow = (scrollHeight + windowHeight < guiderOffset.top + guiderElemHeight); /* we will need to scroll down */
    var isGuiderAbove = (guiderOffset.top < scrollHeight); /* we will need to scroll up */
    
    if (myGuider.autoFocus && (isGuiderBelow || isGuiderAbove)) {
      // Sometimes the browser won't scroll if the person just clicked,
      // so let's do this in a setTimeout.
      setTimeout(guiders.scrollToCurrent, 10);
    }
    
    $(myGuider.elem).trigger("guiders.show");

    return guiders;
  };
  
  guiders.scrollToCurrent = function() {
    var currentGuider = guiders._guiders[guiders._currentGuiderID];
    if (typeof currentGuider === "undefined") {
      return;
    }
    
    var windowHeight = guiders._windowHeight;
    var scrollHeight = $(window).scrollTop();
    var guiderOffset = currentGuider.elem.offset();
    var guiderElemHeight = currentGuider.elem.height();
    
    // Scroll to the guider's position.
    var scrollToHeight = Math.round(Math.max(guiderOffset.top + (guiderElemHeight / 2) - (windowHeight / 2), 0));
    window.scrollTo(0, scrollToHeight);
  };
  
  // Change the bubble position after browser gets resized
  var _resizing = undefined;
  $(window).resize(function() {
    if (typeof(_resizing) !== "undefined") {
      clearTimeout(_resizing); // Prevents seizures
    }
    _resizing = setTimeout(function() {
      _resizing = undefined;
      if (typeof (guiders) !== "undefined") {
        guiders.reposition();
      }
    }, 20);
  });
  
  return guiders;
}).call(this, jQuery);

/*
 * Tiny Scrollbar
 * http://www.baijs.nl/tinyscrollbar/
 *
 * Dual licensed under the MIT or GPL Version 2 licenses.
 * http://www.opensource.org/licenses/mit-license.php
 * http://www.opensource.org/licenses/gpl-2.0.php
 *
 * Date: 13 / 08 / 2012
 * @version 1.81
 * @author Maarten Baijs
 *
 */
;( function( $ ) 
{
    $.tiny = $.tiny || { };

    $.tiny.scrollbar = {
        options: {
                axis         : 'y'    // vertical or horizontal scrollbar? ( x || y ).
            ,   wheel        : 40     // how many pixels must the mouswheel scroll at a time.
            ,   scroll       : true   // enable or disable the mousewheel.
            ,   lockscroll   : true   // return scrollwheel to browser if there is no more content.
            ,   size         : 'auto' // set the size of the scrollbar to auto or a fixed number.
            ,   sizethumb    : 'auto' // set the size of the thumb to auto or a fixed number.
            ,   invertscroll : false  // Enable mobile invert style scrolling
        }
    };

    $.fn.tinyscrollbar = function( params )
    {
        var options = $.extend( {}, $.tiny.scrollbar.options, params );
        
        this.each( function()
        { 
            $( this ).data('tsb', new Scrollbar( $( this ), options ) ); 
        });

        return this;
    };

    $.fn.tinyscrollbar_update = function(sScroll)
    {
        return $( this ).data( 'tsb' ).update( sScroll ); 
    };

    function Scrollbar( root, options )
    {
        var oSelf       = this
        ,   oWrapper    = root
        ,   oViewport   = { obj: $( '.viewport', root ) }
        ,   oContent    = { obj: $( '.overview', root ) }
        ,   oScrollbar  = { obj: $( '.scrollbar', root ) }
        ,   oTrack      = { obj: $( '.track', oScrollbar.obj ) }
        ,   oThumb      = { obj: $( '.thumb', oScrollbar.obj ) }
        ,   sAxis       = options.axis === 'x'
        ,   sDirection  = sAxis ? 'left' : 'top'
        ,   sSize       = sAxis ? 'Width' : 'Height'
        ,   iScroll     = 0
        ,   iPosition   = { start: 0, now: 0 }
        ,   iMouse      = {}
        ,   touchEvents = 'ontouchstart' in document.documentElement
        ;

        function initialize()
        {
            oSelf.update();
            setEvents();

            return oSelf;
        }

        this.update = function( sScroll )
        {
            oViewport[ options.axis ] = oViewport.obj[0][ 'offset'+ sSize ];
            oContent[ options.axis ]  = oContent.obj[0][ 'scroll'+ sSize ];
            oContent.ratio            = oViewport[ options.axis ] / oContent[ options.axis ];

            oScrollbar.obj.toggleClass( 'disable', oContent.ratio >= 1 );

            oTrack[ options.axis ] = options.size === 'auto' ? oViewport[ options.axis ] : options.size;
            oThumb[ options.axis ] = Math.min( oTrack[ options.axis ], Math.max( 0, ( options.sizethumb === 'auto' ? ( oTrack[ options.axis ] * oContent.ratio ) : options.sizethumb ) ) );
        
            oScrollbar.ratio = options.sizethumb === 'auto' ? ( oContent[ options.axis ] / oTrack[ options.axis ] ) : ( oContent[ options.axis ] - oViewport[ options.axis ] ) / ( oTrack[ options.axis ] - oThumb[ options.axis ] );
            
            iScroll = ( sScroll === 'relative' && oContent.ratio <= 1 ) ? Math.min( ( oContent[ options.axis ] - oViewport[ options.axis ] ), Math.max( 0, iScroll )) : 0;
            iScroll = ( sScroll === 'bottom' && oContent.ratio <= 1 ) ? ( oContent[ options.axis ] - oViewport[ options.axis ] ) : isNaN( parseInt( sScroll, 10 ) ) ? iScroll : parseInt( sScroll, 10 );
            
            setSize();
        };

        function setSize()
        {
            var sCssSize = sSize.toLowerCase();

            oThumb.obj.css( sDirection, iScroll / oScrollbar.ratio );
            oContent.obj.css( sDirection, -iScroll );
            iMouse.start = oThumb.obj.offset()[ sDirection ];

            oScrollbar.obj.css( sCssSize, oTrack[ options.axis ] );
            oTrack.obj.css( sCssSize, oTrack[ options.axis ] );
            oThumb.obj.css( sCssSize, oThumb[ options.axis ] );
        }

        function setEvents()
        {
            if( ! touchEvents )
            {
                oThumb.obj.bind( 'mousedown', start );
                oTrack.obj.bind( 'mouseup', drag );
            }
            else
            {
                oViewport.obj[0].ontouchstart = function( event )
                {   
                    if( 1 === event.touches.length )
                    {
                        start( event.touches[ 0 ] );
                        event.stopPropagation();
                    }
                };
            }

            if( options.scroll && window.addEventListener )
            {
                oWrapper[0].addEventListener( 'DOMMouseScroll', wheel, false );
                oWrapper[0].addEventListener( 'mousewheel', wheel, false );
            }
            else if( options.scroll )
            {
                oWrapper[0].onmousewheel = wheel;
            }
        }

        function start( event )
        {
            $( "body" ).addClass( "noSelect" );

            var oThumbDir   = parseInt( oThumb.obj.css( sDirection ), 10 );
            iMouse.start    = sAxis ? event.pageX : event.pageY;
            iPosition.start = oThumbDir == 'auto' ? 0 : oThumbDir;
            
            if( ! touchEvents )
            {
                $( document ).bind( 'mousemove', drag );
                $( document ).bind( 'mouseup', end );
                oThumb.obj.bind( 'mouseup', end );
            }
            else
            {
                document.ontouchmove = function( event )
                {
                    event.preventDefault();
                    drag( event.touches[ 0 ] );
                };
                document.ontouchend = end;        
            }
        }

        function wheel( event )
        {
            if( oContent.ratio < 1 )
            {
                var oEvent = event || window.event
                ,   iDelta = oEvent.wheelDelta ? oEvent.wheelDelta / 120 : -oEvent.detail / 3
                ;

                iScroll -= iDelta * options.wheel;
                iScroll = Math.min( ( oContent[ options.axis ] - oViewport[ options.axis ] ), Math.max( 0, iScroll ));

                oThumb.obj.css( sDirection, iScroll / oScrollbar.ratio );
                oContent.obj.css( sDirection, -iScroll );

                if( options.lockscroll || ( iScroll !== ( oContent[ options.axis ] - oViewport[ options.axis ] ) && iScroll !== 0 ) )
                {
                    oEvent = $.event.fix( oEvent );
                    oEvent.preventDefault();
                }
            }
        }

        function drag( event )
        {
            if( oContent.ratio < 1 )
            {
                if( options.invertscroll && touchEvents )
                {
                    iPosition.now = Math.min( ( oTrack[ options.axis ] - oThumb[ options.axis ] ), Math.max( 0, ( iPosition.start + ( iMouse.start - ( sAxis ? event.pageX : event.pageY ) ))));
                }
                else
                {
                     iPosition.now = Math.min( ( oTrack[ options.axis ] - oThumb[ options.axis ] ), Math.max( 0, ( iPosition.start + ( ( sAxis ? event.pageX : event.pageY ) - iMouse.start))));
                }

                iScroll = iPosition.now * oScrollbar.ratio;
                oContent.obj.css( sDirection, -iScroll );
                oThumb.obj.css( sDirection, iPosition.now );
            }
        }
        
        function end()
        {
            $( "body" ).removeClass( "noSelect" );
            $( document ).unbind( 'mousemove', drag );
            $( document ).unbind( 'mouseup', end );
            oThumb.obj.unbind( 'mouseup', end );
            document.ontouchmove = document.ontouchend = null;
        }

        return initialize();
    }

}(jQuery));
var mct1_Options =
{
    sliderId: "mcts1",
    direction: "vertical",
    scrollInterval: 3000,
    scrollDuration: 1400,
    hoverPause: true,
    autoAdvance: true,
    scrollByEachThumb: true,
    circular: true,
    largeImageSlider: null,
    inSyncWithLargeImageSlider: true,
    license: "mylicense"
};

/* Menucool jQuery Slider v2012.11.22. Copyright www.menucool.com */
(function(a){var c=new b(mct1_Options);function b(f){var m="length",j="className",P=function(a,c){var b=a[m];while(b--)if(a[b]===c)return true;return false},Q=function(b,a){return P(b[j].split(" "),a)},K=function(a,b){if(!Q(a,b))if(a[j]=="")a[j]=b;else a[j]+=" "+b},J=function(a,b){var c=new RegExp("(^| )"+b+"( |$)");a[j]=a[j].replace(c,"$1");a[j]=a[j].replace(/ $/,"")},D=function(b,c){var a=null;if(typeof b.currentStyle!="undefined")a=b.currentStyle;else a=document.defaultView.getComputedStyle(b,null);return a[c]},r="largeImageSlider",u="appendChild",E="inSyncWithLargeImageSlider",v=function(d){var a=d.childNodes,c=[];if(a)for(var b=0,e=a[m];b<e;b++)a[b].nodeType==1&&c.push(a[b]);return c},U=function(b,c){var a=c==0?b.nextSibling:b.firstChild;while(a&&a.nodeType!=1)a=a.nextSibling;return a},h="style",o="offsetTop",n="offsetLeft",s="offsetHeight",w="offsetWidth",z="onmouseover",y="onmouseout";function O(){var c=50,b=navigator.userAgent,a;if((a=b.indexOf("MSIE "))!=-1)c=parseInt(b.substring(a+5,b.indexOf(".",a)));return c}var L=O()<8,T=["$1$2$3","$1$2$3","$1$24","$1$23"];function N(b){var a=[],c=b[m];while(c--)a.push(String.fromCharCode(b[c]));return a.join("")}var b={b:0,a:0,c:0,d:0,e:1,f:0},i,d,c,k,e,g,C,A,l,p,q,t,B,x,M=function(a){k=a;c=[];this.c()},H=function(){i=f.direction=="vertical"?0:1;d={a:f.license,c:f.scrollInterval,b:f.autoAdvance,d:f.scrollByEachThumb,f:f.circular};A&&A.b()},R=document,S=[/(?:.*\.)?(\w)([\w\-])[^.]*(\w)\.[^.]+$/,/.*([\w\-])\.(\w)(\w)\.[^.]+$/,/^(?:.*\.)?(\w)(\w)\.[^.]+$/,/.*([\w\-])([\w\-])\.com\.[^.]+$/],G=function(b){var a=document.createElement("div");if(b)a[j]=b;a[h].display="block";return a},F=function(b){var a=document.createElement("a");a[j]=b;return a};M.prototype={c:function(){g=G(0);g[h][i?"width":"height"]="99999px";g[h].position="absolute";e=G(0);e[u](g);e[h].position="relative";e[h].overflow="hidden";var x=k[w]-parseInt(D(k,"paddingLeft")||0)-parseInt(D(k,"paddingRight")||0),t=k[s]-parseInt(D(k,"paddingTop")||0)-parseInt(D(k,"paddingBottom")||0);e[h].width=x+"px";e[h].height=t+"px";if(!i){e[h].height=k[s]+"px";k[h].height="auto"}k.insertBefore(e,k.firstChild);for(var l=v(k),a,z,B,d=1,y=l[m];d<y;d++){a=G("item");l[d][h].display="block";a[u](l[d]);if(i){a[h].cssFloat="left";a[h].styleFloat="left"}if(f[r]){a[h].cursor="pointer";a.onclick=function(){if(f[E]){b.b=this.i;A.g(1,1)}else f[r].displaySlide(this.i,1,0)}}c.push(g[u](a));c[c[m]-1].i=d-1}b.a=c[m];if(i)p=c[0][n];else{p=D(c[0],"marginTop");if(p=="auto"||!p)p=0;else p=parseInt(p)}if(c[m]>1)var q=i?c[1][n]-c[0][n]-c[0][n]-c[0][w]:c[1][o]-c[0][o]-c[0][s];var j=c[c[m]-1];C=i?j[n]+j[w]+q:j[o]+j[s]+q;g[h][i?"width":"height"]=C+"px";this.b();k[h].backgroundImage="none"},b:function(){var a=this.l();if(a[0]){if(q==null)a[1].f();else{B[j]=d.b?"navPause":"navPlay";q[j]="navPrev";t[j]="navNext"}!d.f&&this.r();if(d.b)l=setTimeout(function(){a[1].d()},d.c);if(f.hoverPause){e[z]=function(){b.d=1;clearTimeout(l);l=null};e[y]=function(){b.d=0;if(l==null&&!b.c&&d.b){window.clearTimeout(l);l=null;l=setTimeout(function(){a[1].d()},d.c/2)}};if(q){t[z]=q[z]=e[z];t[y]=q[y]=e[y]}}else e[z]=e[y]=function(){}}if(f[r]){f[r].getElement()[z]=e[z];f[r].getElement()[y]=e[y];f[E]&&f[r].getAuto()&&f[r].changeOptions({autoAdvance:false})}},e:function(){b.c=0;clearTimeout(l);l=null;if(d.f)this.m();else{this.r();if(!b.e)return}var a=this;if(!b.d&&d.b)l=setTimeout(function(){a.d()},d.c)},d:function(){var a=this.j();if(a!=null){b.b=a;this.g(0,1)}},g:function(j,k){b.c=1;d.d&&this.setActiveNav();var h={duration:f.scrollDuration,onComplete:function(){A.e()}};if(i)var e={left:p-c[b.b][n]+"px"};else if(L)e={top:p-c[b.b][o]+"px"};else e={top:-c[b.b][o]+"px"};a(g).animate(e,h.duration,h.onComplete);f[r]&&(f[E]||j)&&f[r].displaySlide(b.b,1,k)},f:function(){var c=this;if(d.d){x=document.createElement("div");x[j]="navBullets";for(var f=[],a=0;a<b.a;a++)f.push("<a rel='"+a+"'></a>");x.innerHTML=f.join("");for(var e=v(x),a=0;a<b.a;a++){if(a==b.b)e[a][j]="active";e[a].onclick=function(){if(this[j]=="active")return 0;if(b.c)return 0;c.h(parseInt(this.getAttribute("rel")))}}k[u](x)}q=F("navPrev");q.setAttribute("onselectstart","return false");q.onclick=function(){c.To(1)};k[u](q);B=F(d.b?"navPause":"navPlay");B.setAttribute("onselectstart","return false");B.setAttribute("title",d.b?"Pause":"Play");B.onclick=function(){window.clearTimeout(l);l=null;(d.b=!d.b)&&c.d();this[j]=d.b?"navPause":"navPlay";this.setAttribute("title",d.b?"Pause":"Play")};k[u](B);t=F("navNext");t.setAttribute("onselectstart","return false");t.onclick=function(){c.To(0)};k[u](t)},setActiveNav:function(){if(x){var c=v(x),a=c[m];while(a--)if(a==b.b)c[a][j]="active";else c[a][j]=""}},i:function(a,d){var c=function(b){var a=b.charCodeAt(0).toString();return a.substring(a[m]-1)},b=d.replace(S[a-2],T[a-2]).split("");return"b"+a+b[1]+c(b[0])+c(b[2])},h:function(a){b.b=this.p(a);window.clearTimeout(l);l=null;this.g(0,0)},k:function(a){return a.replace(/(?:.*\.)?(\w)([\w\-])?[^.]*(\w)\.[^.]*$/,"$1$3$2")},To:function(c){if(b.c)return;if(c){var a=this.o();if(!d.f&&b.b==0)return;if(a==null)return;else b.b=a}else{a=this.j();if(a==null)return;else b.b=a}window.clearTimeout(l);l=null;this.g(0,0)},j:function(){if(!d.f&&!b.e)return null;var f=this.n(b.b);if(!d.f&&f<b.b)return b.b;if(!d.d){var a=f,h=v(g);while(true){if(i&&c[a][n]-c[b.b][n]>e[w])break;else if(!i&&c[a][o]-c[b.b][o]>e[s])break;if(a==h[h[m]-1].i)break;f=a;a=this.n(a)}return f}return f},m:function(){for(var d=v(g),a=0,e=d[m];a<e;a++)if(d[a].i==b.b)break;else g[u](d[a]);if(i)g[h].left=p-c[b.b][n]+"px";else if(L)g[h].top=p-c[b.b][o]+"px";else g[h].top=-c[b.b][o]+"px"},l:function(){return(new Function("a","b","c","d","e","f","g","h","var noEnoughRoom=d>(h?c.offsetWidth:c.offsetHeight);var l=e(g(b([110,105,97,109,111,100])));if(l==''||l.length>3||a[b([97])]==f((+a[b([97])].substring(1,2)),g(b([110,105,97,109,111,100])))){return [noEnoughRoom, this];}else{return [1,{f:function(){},d:function(){}}];}")).apply(this,[d,N,e,C,this.k,this.i,function(a){return R[a]},i])},o:function(){if(d.f){var f=v(g),j=f[f[m]-1].i;if(!d.d)for(var a=f[m]-1;a>-1;a--){if(i&&C-f[a][n]>e[w])break;else if(!i&&C-f[a][o]>e[s])break;j=f[a].i}for(var a=f[m]-1;a>-1;a--){g.insertBefore(f[a],U(g,1));if(f[a].i==j)break}if(i)g[h].left=p-c[b.b][n]+"px";else g[h].top=p-c[b.b][o]+"px"}else{if(!b.f)return null;j=this.q(b.b);if(!d.d)for(var a=j;a>-1;a--){if(i&&c[b.b][n]-c[a][n]>e[w]||!i&&c[b.b][o]-c[a][o]>e[s])break;j=c[a].i}}return j},n:function(a){return this.p(++a)},q:function(a){return this.p(--a)},p:function(a){if(a>=b.a)a=0;else if(a<0)a=b.a-1;return a},r:function(){b.f=(i?g[n]:g[o])<0;if(b.f)J(q,"navPrevDisabled");else K(q,"navPrevDisabled");b.e=(i?g[n]-e[w]:g[o]-e[s])+C>0;if(b.e)J(t,"navNextDisabled");else K(t,"navNextDisabled")}};var I=function(){var a=document.getElementById(f.sliderId);if(a&&v(a)[m]&&a[s])A=new M(a);else setTimeout(I,900)};H();a(window).load(I);return{displaySlide:function(a){A.h(a)},changeOptions:function(a){for(var b in a)f[b]=a[b];H()}}}a.jQuerySlider=function(){return c}})(jQuery);var jQuerySlider=jQuery.jQuerySlider()