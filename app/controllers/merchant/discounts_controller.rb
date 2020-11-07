class Merchant::DiscountsController < Merchant::BaseController

  def new
    @discount = Discount.new
  end

  def create
    discount = Discount.new(discount_params)
    if discount.save
      discount.apply_to_all_merchant_items(current_user.merchant.id)
      flash[:success] = "You have succesfully created a bulk discount"
      redirect_to merchant_root_path
    else
    end
  end

  private
  def discount_params
    params.require(:discount).permit(:discount_percent, :item_threshold)
  end

end
