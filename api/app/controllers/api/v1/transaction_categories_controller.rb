module Api
  module V1
    class TransactionCategoriesController < BaseController
      def index
        cats = TransactionCategory.includes(:budget_category).order('budget_categories.position, transaction_categories.name')
        render json: cats.map { |tc|
          { id: tc.id, name: tc.name, budget_category_id: tc.budget_category_id, budget_category_name: tc.budget_category.name }
        }
      end
    end
  end
end
