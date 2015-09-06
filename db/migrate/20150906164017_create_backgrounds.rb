class CreateBackgrounds < ActiveRecord::Migration
  include ActionView::Helpers::AssetUrlHelper

  def change
    create_table :backgrounds do |t|
      t.string :url
      t.string :credit

      t.timestamps null: false
    end

    inserts =
      (0..24).collect do |n|
        %[('#{image_url("backgrounds/#{n}.jpg")}', 'Chris Cruthers', NOW(), NOW())]
      end

    execute <<-SQL
      INSERT INTO backgrounds (url, credit, created_at, updated_at) VALUES #{inserts.join(', ')}
    SQL
  end
end
