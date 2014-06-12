angular.module 'app'

.factory 'FormFactory', ($q) ->

  ###
  Basic form class that you can extend in your actual forms.

  Object attributes:
  - loading[Boolean] - is the request waiting for response?
  - message[String] - after response, success message
  - errors[String[]] - after response, error messages

  Options:
    - submitPromise[function] (REQUIRED) - creates a form request promise
    - onSuccess[function] - will be called on succeded promise
    - onFailure[function] - will be called on failed promise
  ###
  class FormFactory
    constructor: (@options = {}) ->
      @loading = false

      @options.onSuccess ?= _.bind(@_onSuccess, @)
      @options.onFailure ?= _.bind(@_onFailure, @)

    submit: ->
      @_handleRequestPromise @_createSubmitPromise() unless @loading

    _onSuccess: (response) ->
        @message = response.message || response.success
        response

    _onFailure: (response) ->
      @errors = response.data?.data?.errors || response.data?.errors || [response.data?.error || response.error || "Something has failed. Try again."]
      @errors_by_key = response.data?.data?.errors_by_key || response.data?.errors_by_key || response.errors_by_key
      $q.reject(response)

    _createSubmitPromise: ->
      @options.submitPromise()

    _handleRequestPromise: (@$promise, onSuccess, onFailure) ->
      @loading = true
      @submitted = false
      @message = null
      @errors = []
      @errors_by_key = []

      @$promise
        .then (response) =>
          @errors = []
          @errors_by_key = []
          @submitted = true
          response

        .then(onSuccess || @options.onSuccess)

        .catch(onFailure || @options.onFailure)

        .finally =>
          @loading = false

      @$promise


angular.module 'gulliver'

.factory 'UserProfileForm', (Auth, AccountResource, FormFactory, $ionicPopup, $location, HostelsResource) ->
  class UserProfileForm extends FormFactory
    hostels: HostelsResource.getAll()

    _createSubmitPromise: ->
      AccountResource.update(@user || {}).$promise
      .then (response) ->
        Auth.refreshCurrentUser(response.data.user) if response.data?.user

    destroyAccount: ->
      $ionicPopup.prompt
        title: 'Delete your account'
        subTitle: 'Are you sure? We will remove all your activities and comments.'
        inputType: 'password'
        inputPlaceholder: 'Your current password'
        okType: 'button-assertive'
      .then (password) =>
        if password
          $promise = AccountResource.delete({password}).$promise
          @_handleRequestPromise $promise, ->
            Auth.setAuthToken(null)
            $location.path("/")

    generatePassword: ->
      @_handleRequestPromise AccountResource.resetPassword().$promise, _.bind(@_onSuccess, @)
