define [
  'jquery'
  'underscore'
  'backbone'
  'templates',

  'models/session'

  'notify'
], ($, _, Backbone, JST, Session) ->
  class LoginView extends Backbone.View
    template: JST['app/scripts/templates/login.hbs']

    #el: '#container'

    events:
      'mousedown #login': 'submit'
    initialize: () ->
      this.listenTo(Backbone.Events, 'LoginError',(msg) ->
                                                  this.displayNotification(msg)
                                                this)

    render: () ->
      @$el.html @template()

    submit: (event) ->
      $('#login').val('Loading...').prop('disabled', true)
      _params = {email: $("#login_email").val(), password: $("#login_password").val()}
      Session.login(_params)

      return false
    
    displayNotification: (msg)->
      $("#login_password").val('')
      $('#login').val('Login').prop('disabled', false)
      $.notify(msg)

    close:() ->
      this.stopListening()
      $(this.el).off('submit', 'form.login')