class GroupsController < ApplicationController

  before_action :authenticate_user!, only: [:show, :new, :create, :edit, :update, :destroy, :join, :quit]
  before_action :find_group_and_check_permission, only: [:edit, :update, :destroy]

  def index
    @groups = Group.all
  end

  def show
    @group = Group.find(params[:id])
    @posts = @group.posts.recent.paginate( :page => params[:page], :per_page => 5 )
  end

  def new
    @group = Group.new
  end

  def create
    @group = Group.new(group_params)
    @group.user = current_user

    if @group.save
      current_user.join!(@group)
      redirect_to groups_path, :notice => "添加成功"
    else
      render :new
    end
  end

  def edit
  end

  def update

    if @group.update(group_params)
      redirect_to groups_path, :notice => "修改成功"
    else
      render :edit
    end
  end

  def destroy
    @group.destroy
    redirect_to groups_path, :alert => "删除成功"
  end

  def join
    @group = Group.find(params[:id])

    if !current_user.is_member_of?(@group)
      current_user.join!(@group)
      flash[:notice] = "加入讨论组成功"
    else
      flash[:warning] = "你已经是讨论组成员，如何添加？"
    end

    redirect_to group_path(@group)
  end

  def quit
    @group = Group.find(params[:id])

    if current_user.is_member_of?(@group)
      current_user.quit!(@group)
      flash[:alert] = "退出成功"
    else
      flash[:alert] = "你不是群组成员，如何退出"
    end

    redirect_to group_path(@group)
  end

  private

  def group_params
    params.require(:group).permit(:title, :description)
  end

  def find_group_and_check_permission
    @group = Group.find(params[:id])

    if current_user != @group.user
      redirect_to root_path, alert: "你没有权限"
    end
  end

end
