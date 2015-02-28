class Votes < ActiveRecord::Base
  unloadable

  def add_vote(issue_id, user_id, point = 0)
    votes = Votes.find(:first, :conditions => ['issue_id = ? and user_id = ?', issue_id, user_id])
    if votes
      votes.point = point.nil? ? 0 : point
      votes.save!
    else
      votes = Votes.new
      votes.issue_id = issue_id
      votes.user_id = user_id
      votes.point = point.nil? ? 0 : point
      votes.save!
    end

    return get_point(issue_id)
  end

  def get_point(issue_id)
    return Votes.sum(:point, :conditions => ['issue_id = ?', issue_id])
  end

  def get_points(user_id, issue_id)
    return result = {
      "plus" => Votes.sum(:point, :conditions => ['issue_id = ? and point > 0', issue_id]),
      "minus" => Votes.sum(:point, :conditions => ['issue_id = ? and point < 0', issue_id]),
      "zero" => Votes.sum(:point, :conditions => ['issue_id = ? and point = 0', issue_id]),
      "vote" => Votes.count(:point, :conditions => ['issue_id = ? and user_id = ?', issue_id, user_id]),
    }
  end
end
