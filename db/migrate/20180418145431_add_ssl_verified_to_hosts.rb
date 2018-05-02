class AddSslVerifiedToHosts < ActiveRecord::Migration[5.1]
  def change
    add_column :hosts, :ssl_verified, :boolean
  end
end
