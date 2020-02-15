class UsersController < ApplicationController

  def new
    @user = User.new
  end

  def create

    data = user_params.merge(display_id: "display")

    @user = User.new(data)

    num1 = User.find_by(name: user_params["name"])
    num2 = User.find_by(login_id: user_params["login_id"])

    if num1 == nil && num2 == nil

      if @user.save
        redirect_to root_path, success: '登録が完了しました'
      else
        flash.now[:danger]='登録に失敗しました。登録情報を見直してください。'
        render :new
        return
      end
    elsif num1 != nil
        flash.now[:danger]='すでに使用されている名前です。'
        render :new
        return
    else
        flash.now[:danger]='すでに使用されているIDです。'
        render :new
    end
  end

  private
  def user_params
      params.require(:user).permit(:name, :password, :password_confirmation, :user_type, :login_id)
  end

end

