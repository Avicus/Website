Mutations::Friends::Remove = GraphQL::Relay::Mutation.define do
  name 'FriendRemove'
  description 'When a user wants to remove another user from their friends list.'

  input_field :user_id, !types.Int do
    description 'ID of the user who is removing the friend.'
  end

  input_field :friend_id, !types.Int do
    description 'ID of the user that is being removed.'
  end

  return_field :success, !types.Boolean do
    description 'If the friend was removed.'
  end

  return_field :response_data, !FriendResponseDara do
    description 'Information about what the request accompanied (removed, request canceled, not friends, etc).'
  end

  resolve ->(obj, args, ctx) {
    # TODO: define resolve function
  }
end

FriendResponseDara = GraphQL::ObjectType.define do
  name 'RemoveResponseData'
  description 'Information about what the request accompanied (removed, request canceled, not friends, etc).'

  field :removed, !types.Boolean do
    description 'If a the friend was removed.'
  end
  field :canceled, !types.Boolean do
    description 'If a friend request for this user was canceled.'
  end
  field :not_friends, !types.Boolean do
    description 'If the user is not friends with the person they are attempting to remove.'
  end

end