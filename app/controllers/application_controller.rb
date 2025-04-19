class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  # allow_browser versions: :modern
  before_action :authenticate_user!
  # before_action :check_admin, only: [:admin_dashboard]

  private

  def check_admin
    redirect_to root_path, alert: 'Not authorized' unless current_user.admin?
  end
end
