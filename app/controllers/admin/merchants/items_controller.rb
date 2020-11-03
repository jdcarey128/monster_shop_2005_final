class Admin::Merchants::ItemsController < Admin::BaseController
  def index
    @merchant = Merchant.find(params[:merchant_id])
    @items = @merchant.items
    render 'items/index'
  end

  def new
    require "pry"; binding.pry
    @merchant = Merchant.find(params[:merchant_id])
    @item = Item.new
  end

  def create
    require "pry"; binding.pry
    @merchant = Merchant.find(params[:merchant_id])
    @item = @merchant.items.new(item_params)
    check_default_image(@item)
    if @item.save
      flash[:alert] = 'New item saved successfully!'
      redirect_to "/merchant/items"
    else
      flash[:error] = @item.errors.full_messages.to_sentence
      render :new
    end
  end

  def edit
    require "pry"; binding.pry
    @item = Item.find(params[:id])
  end

  def update
    @item = Item.find(params[:id])
    @merchant = Merchant.find(params[:merchant_id])
    @item.update(item_params) if params[:item]
    check_default_image(@item) unless params[:status]
    if params[:status]
      update_status
    elsif @item.save
      flash[:alert] = "Item #{@item.id} has been successfully updated!"
      redirect_to "/admin/merchants/#{@merchant.id}/items"
    else
      flash[:error] = @item.errors.full_messages.to_sentence
      render :edit
    end
  end

  def destroy
    item = Item.find(params[:id])
    merchant = Merchant.find(params[:merchant_id])
    Review.where(item_id: item.id).destroy_all
    item.destroy
    flash[:alert] = 'This item is now deleted.'
    redirect_to "/admin/merchants/#{merchant.id}/items"
  end

  def update_status
    @item = Item.find(params[:id])
    @merchant = Merchant.find(params[:merchant_id])
    if params[:status] == 'deactivate'
      @item.update(:active? => false)
      flash[:alert] = 'This item is no longer for sale.'
    elsif params[:status] == 'activate'
      @item.update(:active? => true)
      flash[:alert] = 'This item is available for sale.'
    end
    redirect_to "/admin/merchants/#{@merchant.id}/items"
  end

  private

  def item_params
    require "pry"; binding.pry
    params.require(:item).permit(:name,:description,:price,:inventory,:image)
  end

  def check_default_image(item)
    require "pry"; binding.pry
    if params[:item][:image] == ''
      item.update(image: '/images/image.png')
      item.save
    end
  end
end