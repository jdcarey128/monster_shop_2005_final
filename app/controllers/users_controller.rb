class UsersController < ApplicationController

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)

    if @user.valid?
      @user.save
      flash[:success] = 'You are now registered and logged in!'
      session[:user_id] = @user.id
      redirect_to "/profile"
    else
      flash[:error] = @user.errors.full_messages.to_sentence
      render :new
    end
  end

  def show
  end

  private

  def user_params
    params.require(:user).permit(
      :name,
      :street_address,
      :city, 
      :state,
      :zip,
      :email,
      :password,
      :password_confirmation
    )
  end
end
