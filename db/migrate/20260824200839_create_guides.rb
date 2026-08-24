class CreateGuides < ActiveRecord::Migration[8.1]
  def change
    create_table :guides do |t|
      t.string :title
      t.string :slug
      t.text :summary
      t.integer :position, null: false, default: 0

      t.timestamps
    end
    add_index :guides, :slug, unique: true
  end
end
