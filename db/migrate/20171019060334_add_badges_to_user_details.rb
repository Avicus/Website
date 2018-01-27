class AddBadgesToUserDetails < ActiveRecord::Migration[5.1]
  def change
    add_column :user_details, :custom_badge_icon, :string
    add_column :user_details, :custom_badge_color, :string
  end
end
