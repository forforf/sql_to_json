S2JApp = angular.module('S2JApp', [])

console.log "S2JApp defined", S2JApp

###
#directives
S2JApp.directive 'activity', ($scope, $document) ->

  #function we will return to the Angular context
  linkFunction = ($scope, $element, $attributes) ->

    #attributes that we want to pass when activity is detected
    scopeExpresson = $attributes.activity

    #bind the document to clicks and key presses
    $document.mousemove (event) ->
      idleTime = 0
      console.log 'mousemove detected'
      $scope.$apply( scopeExpression )

  return linkFunction

#$(this).keypress (e)->
#  idleTime = 0
###

#controllers
S2JApp.controller 'ConnectionCtrl', ($scope, $element, $http) ->
  $scope.makeConnection = ->
    console.log "Element", $element
    console.log $element.serialize()
    form_data = $element.serialize()
    console.log "Form Data Connection", form_data
    form_hdr =  {'Content-Type': 'application/x-www-form-urlencoded'}
    promise = $http.post '/connection', form_data, headers: form_hdr
    promise.success (resp) ->
      console.log "$http Resp", resp


S2JApp.controller 'DatabasesCtrl', ($scope, $http, $timeout, $document) ->

  $scope.safeApply = (fn) ->
    phase = this.$root.$$phase
    if phase is '$apply' or phase is '$digest'
      if fn and (typeof(fn) is 'function')
        fn()
    else
      this.$apply(fn)


  checkInterval = 2000 #60000
  idleTime = -checkInterval
  idleIncrement = ->
    idleTime = idleTime + checkInterval
  setInterval(idleIncrement, checkInterval)

  $document.on 'mousemove', (event) ->
    idleTime = 0
  $document.on 'keypress', (event) ->
    idleTime = 0


  #$scope.handleActivity = ->
  #  console.log "Handling activity"



  class DynamicRefresh
    constructor: ->
      #normal interval (no backoff) if time is less than this
      @activePeriod = 15 #seconds

      #minimum interval allowed
      @minRequestInterval = 3 #seconds

      #check 3 times during an active period
      @activeRequestInterval = @activePeriod / 3.0

    #back off algorithm when exceeding active period
    backOff: (t) =>
      if t > @activePeriod #should always be true
        2*t - @activePeriod
      else #shouldn't get here but just in case
        console.log "WARNING: Refresh rate backoff not working properly"
        @activePeriod

    refreshCheckSecs: (idleTime) =>
      return @activePeriod unless idleTime
      idleSecs = idleTime / 1000.0
      return @backOff(idleSecs) if idleSecs > @activePeriod
      return @activeRequestInterval if @activeRequestInterval > @minRequestInterval
      return @minRequestInterval


  refreshChecker = (new DynamicRefresh()).refreshCheckSecs

  $scope.checkDatabases = ->
    console.log "checking connection"
    promise = $http.get('/databases')
    promise.success (data) ->
      $scope.dbs = data

  #since $timeout affects all watches, move to global
  #periodic database check
  $scope.repeatCheck = (prevCheck, nextDelay) ->
    prevCheck or= 0
    nextDelay or= 0
    current_refresh = refreshChecker(idleTime)*1000
    nextDelay = 0 if current_refresh < nextDelay
    thisCheck = Date.now()
    timeSinceLastCheck = thisCheck - prevCheck
    timeToCheckDbs = timeSinceLastCheck > nextDelay
    console.log "timeToCheckDbs", timeToCheckDbs
    if timeToCheckDbs
      $scope.safeApply($scope.checkDatabases())
      prevCheck = thisCheck
      nextDelay = refreshChecker(idleTime)*1000
    setTimeout($scope.repeatCheck, checkInterval, prevCheck, nextDelay)

  #setInterval($scope.repeatCheck, 6000)
    #$timeout($scope.repeatCheck, old_delay)

  #kicking off repeater
  $scope.repeatCheck(0)
