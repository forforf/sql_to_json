



#$ ->
  #alert "OK"
  #db_scope = angular.element("#db-ctrl").scope()
  #db_scope.s2j = S2J
  #console.log "$ready", S2J, db_scope
  #Increments idle time every minute (so can be 1 even with activity!!)
  #S2J.idleInterval = setInterval("S2J.timerIncrement()", S2J.idleCheckInterval)

  #Zero the idle timer on user activity
  #$(this).mousemove (e)->
  #  S2J.idleTime = 0

  #$(this).keypress (e)->
  #  idleTime = 0

  #$('.connect').click ->
  #  form_data = $("#db-config-form").serialize()
  #  console.log form_data
  #  $.post '/connection', form_data, (resp) ->
  #    #angular.element(domElement).controller()
  #    console.log "Jquery click", resp



