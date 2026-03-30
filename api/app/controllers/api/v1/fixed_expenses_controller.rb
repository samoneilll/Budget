module Api
  module V1
    class FixedExpensesController < BaseController
      def index
        render json: FixedExpense.all
      end

      def create
        expense = FixedExpense.create!(expense_params)
        render json: expense, status: :created
      end

      def update
        expense.update!(expense_params)
        render json: expense
      end

      def destroy
        expense.destroy!
        head :no_content
      end

      private

      def expense
        @expense ||= FixedExpense.find(params[:id])
      end

      def expense_params
        params.require(:fixed_expense).permit(:name, :fortnightly_amount, :position)
      end
    end
  end
end
