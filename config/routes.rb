Rails.application.routes.draw do
  root 'ladder#index'

  # get '/admin/sync', to: 'admin#sync_dingtalk_users'
  # post '/admin/ticket', to: 'admin#query_jsapi_ticket'
  # post '/admin/jsapiconfig', to: 'admin#request_jsapi_config'
  get '/admin/grades/waiting', to: 'user#all_waiting_grades'
  post '/admin/grades/waiting/post', to: 'user#all_waiting_grades_data'
  post '/admin/grade/status', to: 'admin#grade_all_status'
  get '/admin/grades/punish', to: 'user#punish'

  get '/ladder/scores', to: 'ladder#realtime_score'

  get '/user', to: 'user#main'
  get '/user/:user_id', to: 'user#request_grade'
  post '/user/:user_id/post', to: 'user#add_grade'
  get '/user/:user_id/grades/waiting', to: 'user#waiting_grades'
  post '/user/:user_id/grades/waiting/post', to: 'user#waiting_grades_data'
  get '/user/:grade_id/details', to: 'user#grade_details'
  post '/user/:grade_id/details/post', to: 'user#grade_details_data'
  post '/user/:grade_id/details/update/status', to: 'user#grade_status_update'
  get '/user/:user_id/grades/proved', to: 'user#proved_grades'
  post '/user/:user_id/grades/proved/post', to: 'user#proved_grades_data'
  get '/user/:user_id/calendar', to: 'user#calendar'
  get '/user/:user_id/calendar/increase', to: 'user#daily_increase'
  get '/user/:user_id/calendar/task', to: 'user#daily_task'	
  post '/user/:user_id/calendar/post', to: 'user#find_daily_task'

  get '/group/graduates', to: 'user#graduates'
  get '/group/graduates/scores', to: 'user#graduates_scores'

  get '/all-valid-users', to: 'user#find_all_valid_users'

  get '/react/hello', to: 'react#hello'

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
