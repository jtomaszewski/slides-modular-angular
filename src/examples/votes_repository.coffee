angular.module('app')

.service 'VotesRepository', (Restangular, Promise) ->
  new class VotesRepository
    router: Restangular.one('songs')

    # Stores cached votes mapped by song songId.
    # {songId => voteType}
    _votes: {}
    _loading_votes: {}

    # Get Vote for a given songId.
    getVote: (songId) ->
      return @_votes[songId] if @_votes[songId]

      oldVote = @_votes[songId]

      vote = @router.one(songId).one('vote').get()
      .then (response) =>
        @_cacheVote(songId, response.data.vote, false)
      .catch =>
        @_cacheVote(songId, oldVote, false)
      @_cacheVote(songId, vote, true)

    # Destroy vote with given songId.
    destroyVote: (songId) ->
      oldVote = @_votes[songId]

      vote = @router.one(songId).one('vote').get(delete: 1)
      .then =>
        @_cacheVote(songId, null, false)
      .catch =>
        @_cacheVote(songId, oldVote, false)
      @_cacheVote(songId, vote, true)

    # Create vote for given songId and type.
    createVote: (songId, type = "like") ->
      oldVote = @_votes[songId]

      vote = @router.one(songId).post('vote', {type})
      .then (response) =>
        @_cacheVote(songId, response, false)
      .catch =>
        @_cacheVote(songId, oldVote, false)
      @_cacheVote(songId, vote, true)

    _cacheVote: (songId, vote, loading = false) ->
      if loading
        @_loading_votes[songId] = true
      else
        delete @_loading_votes[songId]
      @_votes[songId] = Promise vote
