module Concerns::Swaggerize
  extend ActiveSupport::Concern

  included do
    after_action :swaggerize
  end

  def swaggerize
    Swaggerize::Perform.new(request, response).call
  rescue StandardError => e
    Rails.logger.info 'Swaggerize error: ' + e.to_s
  end
end
