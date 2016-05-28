class CreateArticles < ActiveRecord::Migration
  def change
    create_table :articles do |t|
      t.string :title
      t.string :description
      t.string :picurl
      t.string :url

      t.timestamps null: false
    end
  end
end
