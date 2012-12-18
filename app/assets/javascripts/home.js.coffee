# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

$ ->

$('.hero-unit button.btn-large').click (event) ->
  console.log("Sell/Buy button click triggered")
  $('div#product_type').show()
  $.scrollTo($('div#product_type'), 1000)
