app = angular.module("ngPostMessage",['ng'])

app.directive('html',['$window','$postMessage',($window,$postMessage)->
  {
    restrict: 'E'
    controller: (['$scope',($scope)->
      $scope.$on('$messageOutgoing',(event,message,domain="*")->
        sender = $scope.sender || $window.parent
        sender.postMessage(message,domain)
      )
    ])
    link: (($scope,$element,$attrs)->
      $scope.sendMessageToService = ((event)->
        event = event.originalEvent || event
        if event and event.data
          response = null
          $scope.sender = event.source
          try
            response = angular.fromJson(event.data)
          catch error
            console.error('ahem', error)
            response = event.data
          $scope.$root.$broadcast('$messageIncoming', response)
          $postMessage.messages(response)
      )

      angular.element($window).bind('message',$scope.sendMessageToService)
    )
  }
])

app.factory("$postMessage",['$rootScope',($rootScope)->
  $messages = []
  api = {
    messages: ((_message_)->
      if _message_
        $messages.push(_message_)
        $rootScope.$digest()
      $messages
    )
    lastMessage: (->
      $messages[$messages.length - 1]
    )
    post: ((message,domain="*")->
      $rootScope.$broadcast('$messageOutgoing',message,domain)
    )
  }
  api
])
