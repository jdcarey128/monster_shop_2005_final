class Merchant::DiscountsController < Merchant::BaseController

  def new
    @discount = Discount.new
  end

  def create
    @discount = Discount.new(discount_params)
    if @discount.save
      @discount.apply_to_all_merchant_items(current_user.merchant.id)
      flash[:success] = "You have succesfully created a bulk discount"
      redirect_to merchant_root_path
    else
      flash[:error] = @discount.errors.full_messages.to_sentence
      render new_merchant_discount_path
    end
  end

  def edit
    @discount = find_discount
  end

  def update
    @discount = find_discount
    if @discount.update(discount_params)
      flash[:success] = "Bulk discount successfully updated"
      redirect_to merchant_root_path
    else
      flash[:error] = @discount.errors.full_messages.to_sentence
      redirect_to edit_merchant_discount_path
    end
  end

  def destroy
    @discount = find_discount
    @discount.destroy
    flash[:success] = "Discount successfully deleted"
    redirect_to merchant_root_path
  end

  private
  def discount_params
    params.require(:discount).permit(:discount_percent, :item_threshold)
  end

  def find_discount
    Discount.find_by_id(params[:id])
  end



end
