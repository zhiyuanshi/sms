# https://github.com/ddollar/foreman/wiki/Missing-Output
$stdout.sync = true

require 'bundler/setup'

require 'backburner'
require File.expand_path("../job", __FILE__)

Backburner.work("sms", worker: Backburner::Workers::Forking)
