# frozen_string_literal: true

Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  # resource
  post '/batting_average/process', to: 'batting_averages#process_file'
end