# https://github.com/ddollar/foreman/wiki/Missing-Output
$stdout.sync = true

require 'bundler/setup'

require 'sinatra'
require 'backburner'
require File.expand_path("../job", __FILE__)

set :server, :thin

post '/sms' do
  Backburner.enqueue(Job, params[:to], params[:body], params[:endpoint], params[:channel])
end
