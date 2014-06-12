angular.module('app').factory('PromiseFactory', function($q) {
  return function PromiseFactory(value, shouldResolve) {
    if (value && typeof value.then === 'function') {
      return value;
    }

    var deferred = $q.defer();
    if (shouldResolve == null || shouldResolve === true) {
      deferred.resolve(value);
    } else {
      deferred.reject(value);
    }

    return deferred.promise;
  };
});
