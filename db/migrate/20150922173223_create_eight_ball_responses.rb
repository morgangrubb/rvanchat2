class CreateEightBallResponses < ActiveRecord::Migration
  def change
    create_table :eight_ball_responses do |t|
      t.string :text

      t.timestamps null: false
    end
  end
end
