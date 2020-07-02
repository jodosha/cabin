# frozen_string_literal: true

Hanami::Model::SQL.migration do
  change do
    create_table :users do
      primary_key :id
      column :name, String, null: false
      column :age, Integer

      column :created_at, DateTime, null: false
      column :updated_at, DateTime, null: false
    end
  end
end
