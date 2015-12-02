define [
  'jquery'
  'underscore'
  'backbone'
  'templates'

  'views/panel'
  'models/history'
  'views/helpers'
  'views/rations'
  'collections/rations'

  'notify'
], ($, _, Backbone, JST, PanelView, History, Helpers, RationsView, RationCollection) ->
  class HistoryView extends Backbone.View
    template: JST['app/scripts/templates/history.hbs'] 
    #el: '#container'
    panel: new PanelView()

    initialize: (sprints) ->
      @sprints = sprints
      this.listenTo(Backbone.Events, 'SprintError',(msg) ->
                                                  this.displayNotification(msg)
                                                this)
    render: () ->
      self = this
      @$el.html @template(sprints: @sprints.toJSON())
      $('.sprints').on('click', '.sprint', -> 
        # This needs to avoid sending GET request each time, but only if spoiler
        # is hidden
        hidden = $(this).find(".info").is(":hidden")
        $(this).find(".info").slideToggle("slow")

        # TODO: Add loading symbol, and remove it
        _rations = new RationCollection($(this).attr("id"))
        if hidden
            new Promise (resolve, reject) =>
                _rations.fetch(
                  success: (collection) =>
                    sorted = collection.groupBy((item) ->
                                          item.get("daily_menu").day_number
                                        )
                    _view = new RationsView(JSON.stringify(sorted))
                    _view.$el = $(this).find('#sprint_ration')
                    _view.render()
                    resolve()
                )
      )
    

      @panel.$el = @$('#user_panel')
      @panel.render()
      @panel.delegateEvents()
    
    displayNotification:(msg) ->
        $.notify(msg)

    close: () ->
      @panel.remove()
      this.stopListening()