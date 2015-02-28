# Plugin's routes
# See: http://guides.rubyonrails.org/routing.html

Rails.application.routes.draw do
  get 'issues/:issue_id/vote', :to => 'vote#get'
  post 'issues/:issue_id/vote', :to => 'vote#add'
end
