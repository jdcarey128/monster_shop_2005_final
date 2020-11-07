class Merchant::DiscountsController < Merchant::BaseController

  def new
    @discount = Discount.new
  end

end
