class CreateCategoryProblemSelections < ActiveRecord::Migration
  def change
    create_table :category_problem_selections do |t|
      t.references :category, index: true
      t.references :problem, index: true

      t.timestamps
    end
  end
end
