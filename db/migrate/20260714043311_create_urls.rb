class CreateUrls < ActiveRecord::Migration[8.1]
  def change
    create_table :urls do |t|
      t.text :original_url
      t.string :short_code
      t.integer :clicks, default: 0, null: false

      t.timestamps
    end
  end
end
