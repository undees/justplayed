require 'osx/cocoa'
require 'rubygems'
require 'chronic'

$:.unshift File.dirname(__FILE__) + '/../build/bundles'

bundle_name = 'WhatJustPlayed'
require "#{bundle_name}.bundle"
OSX::ns_import bundle_name.to_sym
