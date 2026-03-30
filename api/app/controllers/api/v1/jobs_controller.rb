module Api
  module V1
    class JobsController < BaseController
      def categorise
        CategoriseJob.perform_later
        render json: { queued: true }
      end
    end
  end
end
