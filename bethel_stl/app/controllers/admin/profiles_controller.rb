class Admin::ProfilesController < Admin::BaseController
  def edit
    @user = current_user
  end

  def update
    @user = current_user

    if @user.update_with_password(profile_params)
      bypass_sign_in(@user)
      redirect_to edit_admin_profile_path, notice: "Your profile was updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def authorized_for_admin?
    current_user.can_manage_conferences?
  end

  def profile_params
    params.require(:user).permit(:email, :password, :password_confirmation, :current_password)
  end
end
