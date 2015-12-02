define [
  'jquery',
  'underscore',
  'backbone',
  'router',

  'models/session',
  'models/sprint'
  'models/day'

  'collections/days'
  'collections/orders'
  'collections/sprints'

  'views/index'
  'views/content_view'
  'views/contacts',
  'views/login',
  'views/daily_menu',
  'views/history'
], ($, _, Backbone, Router, Session, Sprint, Day, DayCollection, OrderCollection, SprintsCollection, IndexView, ContentView, ContactsView, LoginView, DayCollectionView, HistoryView) ->
  class Application
    @defaults = 
      api_endpoint: "https://young-shore-4526.herokuapp.com/api/v1"

    constructor: (options = {}) ->
      @router = null
      @options = $.extend(Application.defaults, options)

    initialize: () ->
      this._initConfiguration()
      this._initRoutes()
      this._initEvents()
    
    _initConfiguration: ->
      self = this
      #CORS support
      $.support.cors = true
      $.ajaxPrefilter \ 
        (options, originalOptions, jqXHR) ->
          options.url = "#{self.options.api_endpoint}/#{options.url}"
          no

    _initRoutes: ->
      @router = new Router()

      @router.on 'route:login', (page) =>
        #_view = new LoginView()
        ContentView.switchView(new LoginView())
        #_view.render()

      @router.on 'route:sprints', (page) =>
        _dayCollection = new DayCollection()
        _orderCollection = new OrderCollection()
        new Promise (resolve, reject) =>
            _dayCollection.fetch(
              success: (collection) =>
                # _view = new DayCollectionView(_dayCollection)
                # _view.render()
                ContentView.switchView(new DayCollectionView(_dayCollection, _orderCollection))
                #ContentView.render()
                resolve()
              error: () =>
                this.getSprintsHistory("There is no sprint to order!")
                @router.navigate('history')
                reject()
            )
      @router.on 'route:history', (page) =>
        this.getSprintsHistory()
      
      @router.on 'route:index', (page) =>
        ContentView.switchView(new IndexView())
      
      Backbone.history.start()

    _initEvents: ->
      Backbone.history.on "route", () =>
        this.checkAuth()
      Session.on 'change:auth', (session) =>
        this.checkAuth()
      # Check if user already logined
      Session.getAuth().catch( (err) =>
            console.log err
            Backbone.history.start() unless Backbone.History.started
            @router.navigate("login", {trigger: true})
            return
          )

    getSprintsHistory: (errorText) ->
      _sprints = new SprintsCollection()
      new Promise (resolve, reject) =>
            _sprints.fetch(
              success: (collection) =>
                #_view = new HistoryView(_sprints)
                ContentView.switchView(new HistoryView(_sprints))
                if errorText
                  Backbone.Events.trigger('SprintError', errorText)
                #_view.render()
                resolve()
              error: =>
                @router.navigate("login", {trigger: true})
            )
             
    checkAuth: ->
      new Promise (resolve, reject) =>
        unless Session.get('auth')
          return Session.getAuth()
          .then ->
            resolve()
          .catch (err)->
            reject(err)
        resolve()
      .then ->
        Backbone.history.start() unless Backbone.History.started
      .catch (err) =>
        console.log err
        unless Backbone.History.started
          if Backbone.history.location.hash == '#login'
            Backbone.history.start() 
          else 
            Backbone.history.start({silent: true}) 
        @router.navigate("login", {trigger: true})
        return

  return new Application()