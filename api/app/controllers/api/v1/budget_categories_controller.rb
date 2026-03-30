module Api
  module V1
    class BudgetCategoriesController < BaseController
      def index
        render json: BudgetCategory.all.order(:name)
      end

      def show
        render json: budget_category
      end

      def create
        category = BudgetCategory.create!(category_params)
        render json: category, status: :created
      end

      def update
        budget_category.update!(category_params)
        render json: budget_category
      end

      def destroy
        budget_category.destroy!
        head :no_content
      end

      def reorder
        params[:positions].each do |item|
          BudgetCategory.where(id: item[:id]).update_all(position: item[:position])
        end
        head :no_content
      end

      private

      def budget_category
        @budget_category ||= BudgetCategory.find(params[:id])
      end

      def category_params
        params.require(:budget_category).permit(
          :name, :fortnightly_amount, :description, :section,
          :sam_amount, :ish_amount, :sam_pct, :ish_pct, :position
        )
      end
    end
  end
end
