app.service('CommentsResource', function($resource, BACKEND_URL) {
  var $res;

  $res = $resource(BACKEND_URL + "/activities/:activity_id/comments/:id.json", {
    activity_id: '@activity_id',
    id: '@id'
  });

  return {
    $resource: $res,

    getAllForActivity: function(activity_id, params) {
      return $res.query(angular.extend(params || {}, {
        activity_id: activity_id
      }));
    },

    create: function(activity_id, comment) {
      return $res.save({
        activity_id: activity_id
      }, {
        comment: comment
      });
    },

    destroy: function(activity_id, id) {
      return $res.remove({
        activity_id: activity_id,
        id: id
      });
    }
  };
});

// usage
app.controller("NewCommentCtrl", function(ActivityResource, CommentsResource){
  $scope.activity = ActivityResource.find(123);

  $scope.submitComment = function() {
    CommentsResource.create($scope.activity.id, $scope.comment).then(...);
  };
})
