require 'bundler'
Bundler.require

#$:.unshift File.expand_path("./../lib", __FILE__)
#require '../app/scrapper.rb'
#require 'views/' pour appeller les programmes donnant une interface visuelle
require 'pry'

class Index

  def perform

    puts "What do you want to do user ?"
    puts "save email and Townhall array of hash  as'JSON' or as 'Google' spreadsheet or as 'csv' ?"
    answer = gets.chomp.to_s
    
    if answer == "JSON" 
      
      puts "you chose to save as JSON. Processing..."
      Scrapper.new.save_as_JSON
    
    elsif answer == "Google"

      puts "you chose to save as Google spreadsheet. Processing..."
      Scrapper.new.save_as_spreadsheet

    elsif answer == "csv"

      puts "you chose to save as csv. Processing..."
      Scrapper.new.save_as_csv
    
    else 
    
      puts "I don't understand what do you mean. You need to write JSON or Google or csv."
    
    end
  
  end      

end #fin de ma classe
