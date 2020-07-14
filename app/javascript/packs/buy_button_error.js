document.addEventListener("turbolinks:load", function() {
  $('.buy-button').bind('ajax:error', function() {
      window.location = '/users/sign_in'
    })
})
