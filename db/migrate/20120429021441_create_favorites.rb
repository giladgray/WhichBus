class CreateFavorites < ActiveRecord::Migration
  def change
    create_table :favorites do |t|
      t.string :favorable_id
      t.string :favorable_type
      t.references :user

      t.timestamps
    end
  end
end
