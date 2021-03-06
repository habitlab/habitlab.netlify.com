hash_data_unparsed = window.location.hash
if hash_data_unparsed.startsWith('#')
  hash_data_unparsed = hash_data_unparsed.substr(1)
if hash_data_unparsed.length > 0
  try
    history.pushState("", document.title, window.location.pathname + window.location.search)
  catch
    window.location.hash = ''
#require('css!./bootstrap.min.css')
#require('css!./bootstrap-theme.min.css')
#require('bootstrap-loader')
$ = require('jquery')
window.$ = window.jQuery = $
require('script-loader!./bootstrap.min.js')
swal = require('./bower_components/sweetalert2/dist/sweetalert2.min.js')
window.swal = swal

list_url = [['habitlab', 'feedback'].join('-'), ['cs', 'stanford', 'edu'].join('.')].join('@')
$(document).ready ->
  $('#address').attr('href', ['ma', 'il', 'to'].join('') + ':' + list_url)
  $('#address').text(list_url)

getUrlParameters = ->
  url = window.location.href
  hash = url.lastIndexOf('#')
  if hash != -1
    url = url.slice(0, hash)
  map = {}
  parts = url.replace(/[?&]+([^=&]+)=([^&]*)/gi, (m,key,value) ->
    #map[key] = decodeURI(value).split('+').join(' ').split('%2C').join(',') # for whatever reason this seems necessary?
    map[key] = decodeURIComponent(value).split('+').join(' ') # for whatever reason this seems necessary?
  )
  return map

params = getUrlParameters()

data = {}
data.browser = navigator.userAgent
data.language = navigator.language
data.languages = navigator.languages
data.client_timestamp = Date.now()
data.client_localtime = new Date().toString()

base_url = "https://habitlab.herokuapp.com"
#base_url = "http://localhost:5000"

$('#submit_button').click ->
  feedback = $('#feedback_textarea').val().trim()
  uninstall_reasons = []
  for x in document.querySelectorAll('input[type=checkbox]')
    if x.checked
      uninstall_reasons.push x.getAttribute('description')
  if feedback.length > 0 or uninstall_reasons.length > 0
    swal {
      title: 'Thanks for your feedback!'
      text: 'Your feedback has been submitted. Thank you for helping us improve HabitLab!'
    }
    #$('#feedback_textarea').val('')
    data.feedback = feedback
    data.uninstall_reasons = uninstall_reasons
    $.getJSON (base_url + "/add_uninstall_feedback?#{$.param(data)}&callback=?"), null, (response) ->
      #console.log response
      return
  else
    swal {
      title: 'Please check an option or enter some text'
    }

unparsed_data = params.d ? hash_data_unparsed
if unparsed_data? and unparsed_data.length > 0
  base64_js = require('base64-js')
  msgpack_lite = require('msgpack-lite')
  data_new = msgpack_lite.decode(base64_js.toByteArray(unparsed_data))
  for k,v of data_new
    data[k] = v
  
  if window.location.host == 'habitlab.github.io'
    $.getJSON (base_url + "/add_uninstall?#{$.param(data)}&callback=?"), null, (response) ->
      #console.log response
      return


