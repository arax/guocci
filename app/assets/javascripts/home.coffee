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
    ($scope, $http, $log) ->
      $scope.name = ''
      $scope.sites = []

      $scope.generate_name = -> $http.get('/haikunator.json').then(
        (response) -> $scope.name = response.data.name,
        (response) -> $log.error(response)
      )
      $scope.generate_name()

      $scope.retrieve_sites =  -> $http.get('/sites.json').then(
        (response) -> $scope.sites = response.data.sites,
        (response) -> $log.error(response)
      )
      $scope.retrieve_sites()

      $scope.$watch(
        'selected_site',
        (newSite, oldSite) ->
          return if !newSite
          $http.get('/sites/' + newSite + '.json').then(
            (response) -> $scope.site_data = response.data.site,
            (response) -> $log.error(response)
          )
      )

      $scope.$watch(
        'site_data',
        (newSiteData, oldSiteData) ->
          return if !newSiteData || !newSiteData.id
          $http.get('/instances/' + newSiteData.id + '.json').then(
            (response) -> $scope.instances = response.data.instances,
            (response) -> $log.error(response)
          )
      )
  ]
)
