class CreateStatistics < ActiveRecord::Migration
  def up
    create_table :statistics do |t|
      t.integer :user_id,                 null: false
      t.string :email,                    null: false
      t.integer :project_id,              null: false
      t.string :project_name_with_owner,  null: false
      t.string :key,                      null: false
      t.integer :counter,                 null: false, default: 0
      t.datetime :activity_at,            null: false

      t.timestamps
    end


    add_index :statistics, :user_id
    add_index :statistics, :project_id
    add_index :statistics, :key
    add_index :statistics, [:user_id, :key, :activity_at]
    add_index :statistics, [:project_id, :key, :activity_at]
    add_index :statistics, [:key, :activity_at]
    add_index :statistics, :activity_at

    add_index :statistics, [:user_id, :project_id, :key, :activity_at], unique: true,
      name: 'index_statistics_on_all_keys'
  end

  def down
    drop_table :statistics
  end

end
