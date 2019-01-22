require 'bundler'
Bundler.require

$:.unshift File.expand_path("./../lib", __FILE__)
require 'app/scrapper.rb'
#require 'views/' #pour appeller les programmes donnant une interface visuelle

#Index.new.perform

#perform la methode write_json de la class Scrapper
Scrapper.new.write_json