# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

guocci = angular.module('guocci', [ 'ngMaterial', 'ngMdIcons' ])
guocci.config( ($mdThemingProvider) -> $mdThemingProvider.theme('docs-dark', 'default').primaryPalette('indigo').dark() )

guocci.controller(
  'HomeController',
  [
    '$scope',
    '$http',
    '$log',
    '$window',
    ($scope, $http, $log, $window) ->
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
