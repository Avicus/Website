Mutations::Presents::Find = GraphQL::Relay::Mutation.define do
  name 'PresentFind'
  description 'When a user finds a present in a lobby.'

  input_field :user_id, !types.Int do
    description 'ID of the user who found the present.'
  end

  input_field :slug, !types.String do
    description 'Slug of the present.'
  end

  input_field :family, !types.String do
    description 'Family of the present.'
  end

  input_field :create, types.Boolean, default_value: false do
    description 'If the present should be created if not found. Defaults to false.'
  end

  return_field :message, !types.String do
    description 'Message to be displayed to the player.'
  end

  return_field :success, !types.Boolean do
    description 'If the present was successfully marked as found.'
  end

  resolve ->(obj, args, ctx) {
    user = User.find_by_id(args[:user_id])
    return [success: false, created: false] if user.nil?
    found = Present.where(slug: args[:slug], family: args[:family]).first
    return [success: false, message: 'This present cannot be found!'] if found.nil? && !args[:create]
    found = Present.new(
        slug: args[:slug],
        family: args[:family],
        human_name: args[:slug],
        human_location: 'Nowhere',
        found_at: Time.now
    ) if found.nil?
    already = PresentFinder.where(present: found, user: user).last.present?
    response = {
        success: (already ? false : PresentFinder.create(present: found, user: user)),
        message: (already ? 'You have already claimed this present!' : 'You found a present!')
    }
  }
end
