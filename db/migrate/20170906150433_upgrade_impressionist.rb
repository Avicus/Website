class UpgradeImpressionist < ActiveRecord::Migration[5.1]
  def change
    add_column :impressions, :params, :text, limit: 65535

    add_index :impressions, [:impressionable_type, :impressionable_id, :params], :name => 'poly_params_request_index', :unique => false, :length => {:params => 255}
  end
end
