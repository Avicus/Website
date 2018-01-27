Mutations::Friends::Add = GraphQL::Relay::Mutation.define do
  name 'FriendAdd'
  description 'When a user attempts to add another user as a friend.'

  input_field :user_id, !types.Int do
    description 'ID of the user who is attempting to add a friend.'
  end

  input_field :friend_id, !types.Int do
    description 'ID of the user that is being added.'
  end

  return_field :success, !types.Boolean do
    description 'If the friend request was sent/accepted.'
  end

  return_field :response_data, !FriendResponseDara do
    description 'Information about what the request accompanied (added, friend, already friends, etc).'
  end

  resolve ->(obj, args, ctx) {
    # TODO: define resolve function
  }
end

FriendResponseDara = GraphQL::ObjectType.define do
  name 'AddResponseData'
  description 'Information about what the request accompanied (added, friend, already friends, etc).'

  field :requested, !types.Boolean do
    description 'If a new friend request was sent.'
  end
  field :added, !types.Boolean do
    description 'If the friend had already requested the user, i.e. the user accepted the request.'
  end
  field :already_friends, !types.Boolean do
    description 'If the user is already friends with the person requested.'
  end
  field :already_requested, !types.Boolean do
    description 'If the user is has already sent a request to this person.'
  end

end