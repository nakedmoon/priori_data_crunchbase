# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

class @CrunchBase

  @bindPaginationLinks: (itemType) ->
    containerSelector  = '#' + itemType + '_container'
    $(containerSelector).find('a.pagination-link').click ->
      valuesToSubmit = $("input[type=hidden]#search_search_string").val()
      $('body').modalmanager('loading')
      $.ajax(
        url: $(@).attr("href")
        data: {search_string: valuesToSubmit}
        dataType: "JSON"
        method: 'GET'
      ).success((json) ->
        console.log(json.message)
        $(containerSelector).html(json.html)
        $('body').modalmanager('loading')
      ).error (xhr) ->
        console.log "error"
        console.log xhr.responseText
        tmpData = jQuery.parseJSON(xhr.responseText)
        $('body').modalmanager('loading')
      false


  @bindShowItems: (itemType) ->
    containerSelector  = '#' + itemType + '_container'
    _modal = $('#row-modal')
    _modal.empty()
    $(containerSelector).find('a.row-link').click ->
      $('body').modalmanager('loading')
      $.ajax(
        url: $(@).attr("href")
        dataType: "JSON"
        method: 'GET'
      ).success((json) ->
        $('body').modalmanager('loading')
        console.log(json.message)
        _modal.html(json.html)
        _modal.modal()
      ).error (xhr) ->
        console.log "error"
        console.log xhr.message
        tmpData = jQuery.parseJSON(xhr.message)
        $('body').modalmanager('loading')
      false




