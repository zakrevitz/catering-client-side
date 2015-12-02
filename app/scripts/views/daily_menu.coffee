define [
  'jquery'
  'underscore'
  'backbone'
  'templates'
  'jquery_ui'

  'models/session'
  'models/order'
  'collections/orders'

  'views/panel'
  'views/order_summary'
  'views/helpers'
], ($, _, Backbone, JST, ui, Session, Order, OrderCollection, PanelView, OrderSummaryView, Helpers) ->
  class DayCollectionView extends Backbone.View
    template: JST['app/scripts/templates/daily_menus.hbs']

    #el: '#container'

    events:
      'mousedown button.btn-send': 'submit'
      'mousedown button.btn-prev': 'prevDay'
      'mousedown button.btn-next': 'nextDay'
      'mousedown input.btn-like': 'like'
      'click input[type=checkbox]': 'toggleInput'
      'change input[type=number]': 'changeQuantity'
      'change input[type=radio]': 'changeOption'
    panel: new PanelView(),
    

    initialize: (dailyMenus, orderCollection) ->
      @dailyMenus = dailyMenus
      this.listenTo(Backbone.Events, 'Overhead',(msg, _prices) ->
                                                  this.displayOverheadNotification(msg, _prices)
                                                this)
      this.listenTo(Backbone.Events, 'EnableButtons',(_prices) ->
                                                  this.enableButtons(_prices)
                                                this)
      @orderCollection = orderCollection
      @order_summary = new OrderSummaryView(@orderCollection)

    render: ->
      this.$el.empty()
      @$el.html @template(dailyMenus: @dailyMenus.toJSON())

      $("#tabs").tabs(disabled:true)
      $( "#tabs" ).tabs( "enable", 0 );
      @panel.$el = @$('#user_panel')
      @panel.render()
      @panel.delegateEvents()
      @order_summary.$el = @$('#order_summary')
      @order_summary.render()

    submit: (event) ->
      active_tab = $("#tabs").find('.day_tab[aria-hidden="false"]')
      if active_tab.find("input:checkbox:checked").length > 0
        this.undelegateEvents()
        @orderCollection.post_rations()

    prevDay: (event) ->
      active = $( "#tabs" ).tabs( "option", "active" )
      $( "#tabs" ).tabs( "enable", active - 1 );
      $( "#tabs" ).tabs( "option", "active", active - 1 )
      $( "#tabs" ).tabs( "disable", active );
      $("#next").prop('disabled', false )
      unless (active - 1)
        $("#prev").prop('disabled', true )

    nextDay: (event) ->
      active = $( "#tabs" ).tabs( "option", "active" )
      $( "#tabs" ).tabs( "enable", active + 1 );
      $( "#tabs" ).tabs( "option", "active", active + 1 )
      $( "#tabs" ).tabs( "disable", active );
      $("#prev").prop('disabled', false )
      $("#next").prop('disabled', true )
      if (active+2 == $('#tabs >ul >li').size())
          $("#submit").prop('disabled', false )
      active_tab = $("#tabs").find('.day_tab[aria-hidden="false"]')
      if active_tab.find("input:checkbox:checked").length > 0
        $("#next").prop('disabled', false )
    
    toggleInput: (event) ->
      tab = $("#tabs").find('.day_tab[aria-hidden="false"]')
      day_id = tab.attr('name')
      category_id = $(event.currentTarget).closest('.category').attr('id')
      dish_id = $(event.currentTarget).closest('.dish').attr('id')
      unless $(event.currentTarget).attr('id') == 'nothing'
        id = $(event.currentTarget).attr('id')
        $('[id=' + id + '-r]').prop('disabled', false )
        $('#' + id + '-r').prop('checked', true )
        input_el = $('#' + id + '-i')
        input_el.prop('disabled', (i, v) -> !v )
        _disabled = input_el.is(":disabled")
        tab.find('#nothing').hide()
        if !(_disabled)
           if $('#' + id + '-r')
             option_id = $('#' + id + '-r').val()
           quantity = input_el.val()
           @orderCollection.add_from_model(day_id,category_id,dish_id, option_id, @dailyMenus, quantity, id)
        if _disabled
          $('[id=' + id + '-r]').prop('disabled', true )
          last = @orderCollection.remove_order(id, @dailyMenus)
          unless tab.find("input:checkbox:checked").length > 0
            tab.find('#nothing').show()
            $("#next").prop('disabled', true )
          if last
            tab.find('#nothing').show()
            $("#next").prop('disabled', true )
            @order_summary.render()
      else
        if $(event.currentTarget).prop('checked')
          this.nextDay()
        else
           unless tab.find("input:checkbox:checked").length > 0
              $("#next").prop('disabled', true )

    changeQuantity:(event)->
      quantity = $(event.currentTarget).val()
      if Number(quantity) > 0
        id = $(event.currentTarget).attr('id')
        id = id.slice(0,-2)
        @orderCollection.changeQuantity(quantity, id, @dailyMenus)
      else
        $(event.currentTarget).val(1)
    
    changeOption: (event) ->
      tab = $("#tabs").find('.day_tab[aria-hidden="false"]')
      day_id = tab.attr('name')
      category_id = $(event.currentTarget).closest('.category').attr('id')
      dish_id = $(event.currentTarget).closest('.dish').attr('id')
      id = $(event.currentTarget).attr('id')
      id = id.slice(0,-2)
      option_id = $(event.currentTarget).val()
      @orderCollection.changeOption(day_id,category_id,dish_id,option_id, id, @dailyMenus)
    
    like: (event)->
      id = $(event.currentTarget).attr('id')
      $(event.currentTarget).closest('#tabs').find("div#"+id).toggleClass("favourited-true")
      Session.like(id)
    
    close: () ->
      $(this.el).off('click', 'input[type=checkbox]')
      $(this.el).off('change', 'input[type=number]')
      $(this.el).off('change', 'input[type=radio]')
      $(this.el).off('mousedown', 'button.btn-send')
      $(this.el).off('mousedown', 'button.btn-prev') 
      $(this.el).off('mousedown', 'button.btn-next')
      $(this.el).off('mousedown', 'input.btn-like')
      @panel.remove()
      this.stopListening()
    
    displayOverheadNotification: (msg, _prices) ->
      $.notify(msg)
      @order_summary.render(_prices)
      $('#order_summary').children().addClass( 'budget_overhead' )
      $('#order_summary').find('.panel').removeClass('panel-default')
      $('#order_summary').find('.panel').addClass('panel-danger')
      $("#prev").prop('disabled', true )
      $("#next").prop('disabled', true )
      $("#submit").prop('disabled', true )
    
    enableButtons: (_prices) ->
      active = $( "#tabs" ).tabs( "option", "active" )
      $("#prev").prop('disabled', false )
      unless active
        $("#prev").prop('disabled', true )
      unless $("li.ui-tabs-active").find("input:checkbox:checked").length > 0
        $("#next").prop('disabled', false )
      @order_summary.render(_prices)