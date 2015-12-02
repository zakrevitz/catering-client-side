define [
  'jquery'
  'underscore'
  'backbone'
  'templates'
  'collections/orders'
], ($, _, Backbone, JST, OrderCollection) ->
  class OrderSummaryView extends Backbone.View
    template: JST['app/scripts/templates/order_summary.hbs']

    events: {}

    initialize: (orderCollection) ->
      @orderCollection = orderCollection

    render: (prices) ->
      sorted = @orderCollection.groupBy((item) ->
                                          item.get("day_number")
                                        )
      sorted = JSON.stringify(sorted)
      if prices
        total = JSON.stringify(prices)
        @$el.html @template(summary: JSON.parse(sorted), total: JSON.parse(total))
      else 
        @$el.html @template(summary: JSON.parse(sorted), total: '')
      