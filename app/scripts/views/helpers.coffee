define [
  'handlebars'
], (Handlebars) ->
  Handlebars.registerHelper(
    'state_class'
    (state) ->
      css_classes =
        started: 'panel-success'
        pending: 'panel-danger'
        closed: 'panel-default'

      return css_classes[state]
  )

  Handlebars.registerHelper(
    'to_date_format'
    (date) ->
      _date = new Date(date)
      return ('0' + _date.getDate()).slice(-2) + "." + ('0' + (_date.getMonth() + 1)).slice(-2) + "." + _date.getFullYear()
  )

  Handlebars.registerHelper(
    'day_of_week'
    (day) ->
      _days = ["Monday", "Tuesday", "Wednesday", "Thursday"
      , "Friday", "Saturday", "Sunday"]
      _days[day - 1]
  )

  Handlebars.registerHelper(
    'format_quantity'
    (quantity) ->
      if quantity<2
        return quantity + " piece"
      else
        return quantity + " pieces"  
  )

  Handlebars.registerHelper(
    'actual_price'
    (quantity, price) ->
       actual_price = Math.round(((Number(quantity)*Number(price)) + 0.00001) * 100) / 100
       return String(actual_price)
  )
  
  Handlebars.registerHelper(
    'equal'
    (lvalue, rvalue, options) -> 
        if ( lvalue!=rvalue )
          return options.inverse(this)
        else 
          return options.fn(this)
    
  )