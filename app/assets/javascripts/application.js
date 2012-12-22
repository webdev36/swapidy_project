//= require_tree .

$(function() {

  var container = $('#container');
  container.isotope({
    itemSelector : '.item',
    layoutMode : 'fitRows'
  });

  $('#fbtab').hover(function() {
    this.src = 'images/Like_hover.png';
  }, function() {
    this.src = 'images/Like.png';
  });
  $('#twtab').hover(function() {
    this.src = 'images/Follow_hover.png';
  }, function() {
    this.src = 'images/Follow.png';
  });

});

function open_in_new_tab(url)
{
  window.open(url, '_blank');
  window.focus();
}
