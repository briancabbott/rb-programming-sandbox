class VoteController < ApplicationController
  unloadable

  before_filter :require_login
  before_filter :find_user #, :authorize
  before_filter :init_votes

  def add
    find_issue

    if ['-1', '1', '0'].include? params[:point] then
      @point = @votes.add_vote(@issue.id, @user.id, params[:point])
    end

    get
  end

  def get
    find_issue

    result = @votes.get_points(@user.id, @issue.id)
    result['point'] = result['plus'] + result['minus']
    render :json => result
  end

  private

  def init_votes
    @votes = Votes.new
  end

  def find_user
    @user = User.current
  end

  def find_issue
    begin
      @issue = Issue.find(params[:issue_id])
    rescue ActiveRecord::RecordNotFound
      render_404
    end
  end
end
