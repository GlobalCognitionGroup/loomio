angular.module('loomioApp').factory 'ProposalModel', (BaseModel) ->
  class ProposalModel extends BaseModel
    @singular: 'proposal'
    @plural: 'proposals'

    setupViews: ->
      @setupView 'votes'

    serialize: ->
      motion:
        discussion_id: @discussionId
        name: @name
        description: @description
        closing_at: @closingAt

    positionVerbs: ['agree', 'abstain', 'disagree', 'block']
    positions: ['yes', 'abstain', 'no', 'block']

    canBeEdited: ->
      @isNew() or !@hasVotes()

    hasVotes: ->
      @votes().length > 0

    author: ->
      @recordStore.users.find(@authorId)

    group: ->
      @discussion().group()

    discussion: ->
      @recordStore.discussions.find(@discussionId)

    votes: ->
      @votesView.data() unless @isNew()

    authorName: ->
      @author().name

    isActive: ->
      #!(@closedAt? and @closedAt.isValid())
      !@closedAt? or !@closedAt.isValid()

    uniqueVotesByUserId: ->
      votesByUserId = {}
      _.each _.sortBy(@votes(), 'createdAt'), (vote) ->
        votesByUserId[vote.authorId] = vote
      votesByUserId

    uniqueVotes: ->
      _.values @uniqueVotesByUserId()

    lastVoteByUser: (user) ->
      @uniqueVotesByUserId()[user.id]

    userHasVoted: (user) ->
      @lastVoteByUser(user)?

    close: ->
      @processing = true
      @restfulClient.postMember(@id, "close").then(@saveSuccess, @saveFailure)
