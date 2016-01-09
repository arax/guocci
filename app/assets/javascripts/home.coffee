# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

guocci = angular.module('guocci', [ 'ngMaterial' ])

guocci.controller('DemoCtrl', ['$scope', ($scope) -> $scope.name = 'stranger'])

guocci.config( ($mdThemingProvider) -> $mdThemingProvider.theme('docs-dark', 'default').primaryPalette('yellow').dark() )
