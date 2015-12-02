define [
  'underscore'
  'backbone'
  'models/order'
], (_, Backbone, OrderModel) ->

  class OrdersCollection extends Backbone.Collection
    model: OrderModel
    url: ->
      'daily_ration'

    initialize:()->

    add_order: (title, price, name, quantity, id, dailyMenus)->
      numberPattern = /\d+/g  #finds all numbers in string
      array = name.match( numberPattern )
      if array && array.length == 3
        _orderModel = new OrderModel({"day_id": array[0],"dish_id": array[1] ,"quantity": quantity, "day_number":array[2], "title": title, "price": price, "id": id })
        this.add(_orderModel)
        this.checkTotalPrice(dailyMenus)
    add_from_model: (day_id, category_id, dish_id, option_id, dailyMenus, quantity,id) ->
      day = dailyMenus.get(day_id)
      categories = day.get('categories')
      cat = _.find(categories, (obj) -> obj.id == Number(category_id) )
      dish = _.find(cat.dishes, (obj) -> obj.id == Number(dish_id) )
      if dish.type == 'DishWithOption'
        option = _.find(dish.options, (obj) -> obj.id == Number(option_id) )
        title = dish.title.concat(" ".concat(option.title))
        _orderModel = new OrderModel({"day_id": day_id,"dish_id": dish_id ,"quantity": quantity, "day_number":day.get('day_number'), "option_id":option.id, "title": title, "price": option.price, "id": id }) 
      else  
        _orderModel = new OrderModel({"day_id": day_id,"dish_id": dish_id ,"quantity": quantity, "day_number":day.get('day_number'), "title": dish.title, "price": dish.price, "id": id })
      this.add(_orderModel)
      this.checkTotalPrice(dailyMenus)
    
    remove_order: (model_id, dailyMenus) ->
      this.remove(this.findWhere({id: model_id}).id)
      return this.checkTotalPrice(dailyMenus) 

    changeQuantity: (quantity, id, dailyMenus) ->
      _model_id = this.findWhere({id: id}).id
      this.get(_model_id).set("quantity": quantity)
      this.checkTotalPrice(dailyMenus)

    changeOption: (day_id,category_id,dish_id,option_id, id, dailyMenus) ->
      day = dailyMenus.get(day_id)
      categories = day.get('categories')
      cat = _.find(categories, (obj) -> obj.id == Number(category_id) )
      dish = _.find(cat.dishes, (obj) -> obj.id == Number(dish_id) )
      option = _.find(dish.options, (obj) -> obj.id == Number(option_id) )
      title = dish.title.concat(" ".concat(option.title))
      _model_id = this.findWhere({id: id}).id
      this.get(_model_id).set("title": title)
      this.get(_model_id).set("price": option.price)
      this.get(_model_id).set("option_id": option_id)
      this.checkTotalPrice(dailyMenus)
    
    checkTotalPrice: (dailyMenus) ->
      sorted = this.groupBy((item) ->
                              item.get("day_id")
                           )
      prices = {}
      _.each((sorted), (ration_array, day_id) -> 
        _total_ration_price = _.reduce((ration_array),(memo, value) -> 
                       return memo + value.get("price")*value.get("quantity")
                      ,0)
        _total_ration_price = Math.round((_total_ration_price + 0.00001) * 100) / 100
        _money_left = dailyMenus.get(day_id).get('max_total') - _total_ration_price
        _money_left = Math.round((_money_left + 0.00001) * 100) / 100
        prices[dailyMenus.get(day_id).get('day_number')] = {total: String(_total_ration_price) , money_left: String(_money_left)}
        )
      last = Object.keys(prices)[Object.keys(prices).length-1]
      if last
        if prices[last].money_left < 0
          Backbone.Events.trigger('Overhead', 'Overheaded budget', prices)
        else
          Backbone.Events.trigger('EnableButtons', prices)
        return 0
      else
        return true

    post_rations: () =>
      # — First delete attributes no longer needed
      # — Why?
      # — Because of reasons.
      this.each((_model) =>
          _model.unset("title")
          _model.unset("price")
          _model.unset("id")
        )
      $.ajax({
            url: 'daily_ration'
            data: {"data": JSON.stringify({"request": this})},
            dataType: 'json'
            type: 'POST',
            success: ->
                console.log "Sent!"
                Backbone.history.navigate('history', {trigger: true})
            error: ->
                # TODO: Notification if something wents wrong
                console.log  "Noooooooooooooooooooooooooo!"
        })
  return OrdersCollection