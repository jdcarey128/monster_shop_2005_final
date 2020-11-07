class Merchant::DashboardController < Merchant::BaseController
  def index
    return redirect_to "/admin/merchants" if current_admin?
    @merchant = current_user.merchant if current_merchant?
    @discounts = current_user.merchant.distinct_discounts if current_merchant?
  end
end
