define [
  'underscore'
  'backbone'
], (_, Backbone) ->
  'use strict';

  class SessionModel extends Backbone.Model
    url: 'sessions/sign_in.json'
    initialize: () ->
      self = this
      
      $.ajaxSetup({
        'beforeSend': (xhr) ->
          xhr.setRequestHeader("accept", "application/json");
      })

      $.ajaxPrefilter( (options, originalOptions, jqXHR) ->
        options.xhrFields =
          withCredentials: true
        # CORS support
        options.crossDomain =
          crossDomain: true
      )

    defaults: {email: "", password: "", name: "", auth: false}

    like: (id) ->
      new Promise (resolve, reject) =>
          $.ajax(
            data:{"id":id}
            dataType: 'json'
            url:'dishes/like',
            type:'POST',
            success: ->
                console.log "Liked"
                resolve()
            error: ->
                console.log  "ERROR"
                reject()
            )
    login: (params) ->
      localStorage.clear()
      self = this
      this.fetch(
        data: params,
        dataType: 'json'
        type: 'POST'
        success: (model, xhr, response) ->
          localStorage.setItem('email', model.get('email'))
          localStorage.setItem('name', model.get('name'))
          Backbone.history.navigate('sprints', {trigger: true})
        error: (model, xhr, response) ->
          console.log "ERROR", response
          Backbone.Events.trigger('LoginError', 'Invalid login parameters!')
      )

    logout: (params) ->
      self = this
      new Promise (resolve, reject) =>
          this.destroy(
            success: (model, response) ->
              model.clear()
              model.id = null
              url: "logout/"
              self.set({auth: false, name: null})
          )
          $.ajax({
                url:'sessions/sign_out',
                type:'DELETE',
                success: ->
                    console.log "Logout"
                    localStorage.clear()
                    resolve()
                error: ->
                    console.log  "ERROR"
                    reject()
            });

    getAuth: () ->
      new Promise (resolve, reject) =>
        if (localStorage['name'] && localStorage['email'])
          params = {email: localStorage['email']}
          @fetch(
            data: params,
            dataType: 'json'
            type: 'GET'
            url: 'sessions/signed'
            success:(model) ->
              resolve()
            error: -> 
              localStorage.clear()
              reject 'Unauthorized user'
          )
        else
          localStorage.clear()
          @set('auth': false)
          reject 'Unauthorized'

  return new SessionModel()