class Admin::ContactGroupsController < Admin::BaseController
  before_action :set_contact_group, only: [:edit, :update, :destroy]
  before_action :set_members, only: [:new, :create, :edit, :update]

  def index
    @contact_groups = ContactGroup.all.order(:name)
  end

  def new
    @contact_group = ContactGroup.new

    if params[:slideout]
      render :new_slideout, layout: false
    end
  end

  def create
    @contact_group = ContactGroup.new(contact_group_params)

    if @contact_group.save
      if params[:slideout]
        render :create_slideout, formats: [:turbo_stream], layout: false
      else
        redirect_to admin_messages_path, notice: "Contact group was successfully created."
      end
    elsif params[:slideout]
      render :new_slideout, layout: false, status: :unprocessable_entity
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    if params[:slideout]
      render :edit_slideout, layout: false
    end
  end

  def update
    if @contact_group.update(contact_group_params)
      if params[:slideout]
        render :update_slideout, formats: [:turbo_stream], layout: false
      else
        redirect_to admin_messages_path, notice: "Contact group was successfully updated."
      end
    elsif params[:slideout]
      render :edit_slideout, layout: false, status: :unprocessable_entity
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @contact_group.destroy

    respond_to do |format|
      format.turbo_stream { render :destroy_slideout, formats: [:turbo_stream], layout: false }
      format.html { redirect_to admin_messages_path, notice: "Contact group was successfully deleted." }
    end
  end

  private

  def set_contact_group
    @contact_group = ContactGroup.find(params[:id])
  end

  def set_members
    @members = Household.includes(:members).order(:name).map do |household|
      [household, household.members.order(:first_name)]
    end
  end

  def contact_group_params
    params.require(:contact_group).permit(:name, member_ids: [])
  end
end
