# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

guocci = angular.module('guocci', [ 'ngMaterial', 'ngMdIcons', 'ngSanitize' ])
guocci.config( ($mdThemingProvider) -> $mdThemingProvider.theme('docs-dark', 'default').primaryPalette('indigo').dark() )

guocci.controller(
  'HomeController',
  [
    '$scope',
    '$http',
    '$log',
    '$window',
    '$mdDialog',
    ($scope, $http, $log, $window, $mdDialog) ->
      $scope.name = ''
      $scope.sites = []

      $scope.generate_name = -> $http.get('/haikunator.json').then(
        (response) -> $scope.name = response.data.name,
        (response) ->
          $log.error(response)
          $scope.error_message = 'Failed to retrieve a name'
      )
      $scope.generate_name()

      $scope.retrieve_sites =  -> $http.get('/sites.json').then(
        (response) -> $scope.sites = response.data.sites,
        (response) ->
          $log.error(response)
          $scope.error_message = 'Failed to load a list of sites from AppDB'
      )
      $scope.retrieve_sites()

      $scope.create_instance = (name, site_id, endpoint, appliance, size, sshkey) ->
        $http.post(
          '/instances/' + site_id + '/new.json',
          { 'name': name, 'endpoint': endpoint, 'appliance': appliance, 'size': size, 'sshkey': sshkey }
        ).then(
          (response) -> $log.info('Created instance ' + response.data.id)
          (response) ->
            $log.error(response)
            $scope.error_message = 'Failed to create an instance'
        )

      $scope.delete_instance = (id, site_id, endpoint) ->
        $http.post(
          '/instances/' + site_id + '/delete.json',
          { 'id': id, 'endpoint': endpoint }
        ).then(
          (response) -> $log.info('Instance deleted!')
          (response) ->
            $log.error(response)
            $scope.error_message = 'Failed to delete an instance'
        )

      $scope.refresh_instances = (newSiteData) ->
        return if !newSiteData || !newSiteData.id || !newSiteData.endpoint
        $http.post(
          '/instances/' + newSiteData.id + '.json',
          { 'endpoint': newSiteData.endpoint }
        ).then(
          (response) -> $scope.instances = response.data.instances,
          (response) ->
            $log.error(response)
            $scope.error_message = 'Failed to refresh the list of instances'
        )

      $scope.get_proxy_info = -> $http.get('/proxy.json').then(
        (response) -> $scope.proxy_info = response.data,
        (response) ->
          $log.error(response)
          $scope.error_message = 'Failed to get proxy information'
      )
      $scope.get_proxy_info()

      $scope.showAlert = (ev) ->
        $mdDialog.show(
          $mdDialog.alert()
          .parent(angular.element(document.querySelector('#popupContainer')))
          .clickOutsideToClose(true)
          .title('Your Active Proxy')
          .htmlContent('<pre>' + $scope.proxy_info.content + '</pre>')
          .ariaLabel('Proxy Dialog')
          .ok('Got it!')
          .targetEvent(ev)
        )

      $scope.$watch(
        'selected_site',
        (newSite, oldSite) ->
          return if !newSite
          $http.get('/sites/' + newSite + '.json').then(
            (response) -> $scope.site_data = response.data.site,
            (response) ->
              $log.error(response)
              $scope.error_message = 'Failed to retrieve site details'
          )
      )

      $scope.$watch(
        'site_data',
        (newSiteData, oldSiteData) -> $scope.refresh_instances(newSiteData)
      )

      $scope.$watch(
        'error_message',
        (newMsg, oldMsg) ->
          return if !newMsg
          $window.alert(newMsg)
          delete $scope.error_message
      )
  ]
)

guocci.directive('userAvatar', ->
  return {
    replace: true,
    template: '<svg class="user-avatar" viewBox="0 0 128 128" height="64" width="64" pointer-events="none" display="block" > <path fill="#FF8A80" d="M0 0h128v128H0z"/> <path fill="#FFE0B2" d="M36.3 94.8c6.4 7.3 16.2 12.1 27.3 12.4 10.7-.3 20.3-4.7 26.7-11.6l.2.1c-17-13.3-12.9-23.4-8.5-28.6 1.3-1.2 2.8-2.5 4.4-3.9l13.1-11c1.5-1.2 2.6-3 2.9-5.1.6-4.4-2.5-8.4-6.9-9.1-1.5-.2-3 0-4.3.6-.3-1.3-.4-2.7-1.6-3.5-1.4-.9-2.8-1.7-4.2-2.5-7.1-3.9-14.9-6.6-23-7.9-5.4-.9-11-1.2-16.1.7-3.3 1.2-6.1 3.2-8.7 5.6-1.3 1.2-2.5 2.4-3.7 3.7l-1.8 1.9c-.3.3-.5.6-.8.8-.1.1-.2 0-.4.2.1.2.1.5.1.6-1-.3-2.1-.4-3.2-.2-4.4.6-7.5 4.7-6.9 9.1.3 2.1 1.3 3.8 2.8 5.1l11 9.3c1.8 1.5 3.3 3.8 4.6 5.7 1.5 2.3 2.8 4.9 3.5 7.6 1.7 6.8-.8 13.4-5.4 18.4-.5.6-1.1 1-1.4 1.7-.2.6-.4 1.3-.6 2-.4 1.5-.5 3.1-.3 4.6.4 3.1 1.8 6.1 4.1 8.2 3.3 3 8 4 12.4 4.5 5.2.6 10.5.7 15.7.2 4.5-.4 9.1-1.2 13-3.4 5.6-3.1 9.6-8.9 10.5-15.2M76.4 46c.9 0 1.6.7 1.6 1.6 0 .9-.7 1.6-1.6 1.6-.9 0-1.6-.7-1.6-1.6-.1-.9.7-1.6 1.6-1.6zm-25.7 0c.9 0 1.6.7 1.6 1.6 0 .9-.7 1.6-1.6 1.6-.9 0-1.6-.7-1.6-1.6-.1-.9.7-1.6 1.6-1.6z"/> <path fill="#E0F7FA" d="M105.3 106.1c-.9-1.3-1.3-1.9-1.3-1.9l-.2-.3c-.6-.9-1.2-1.7-1.9-2.4-3.2-3.5-7.3-5.4-11.4-5.7 0 0 .1 0 .1.1l-.2-.1c-6.4 6.9-16 11.3-26.7 11.6-11.2-.3-21.1-5.1-27.5-12.6-.1.2-.2.4-.2.5-3.1.9-6 2.7-8.4 5.4l-.2.2s-.5.6-1.5 1.7c-.9 1.1-2.2 2.6-3.7 4.5-3.1 3.9-7.2 9.5-11.7 16.6-.9 1.4-1.7 2.8-2.6 4.3h109.6c-3.4-7.1-6.5-12.8-8.9-16.9-1.5-2.2-2.6-3.8-3.3-5z"/> <circle fill="#444" cx="76.3" cy="47.5" r="2"/> <circle fill="#444" cx="50.7" cy="47.6" r="2"/> <path fill="#444" d="M48.1 27.4c4.5 5.9 15.5 12.1 42.4 8.4-2.2-6.9-6.8-12.6-12.6-16.4C95.1 20.9 92 10 92 10c-1.4 5.5-11.1 4.4-11.1 4.4H62.1c-1.7-.1-3.4 0-5.2.3-12.8 1.8-22.6 11.1-25.7 22.9 10.6-1.9 15.3-7.6 16.9-10.2z"/> </svg>'
  }
)
