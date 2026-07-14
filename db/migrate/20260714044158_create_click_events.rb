class CreateClickEvents < ActiveRecord::Migration[8.1]
  def change
    create_table :click_events do |t|
      t.references :url, null: false, foreign_key: true
      t.string :referrer
      t.string :user_agent
      t.string :ip_address

      t.timestamps
    end
  end
end
