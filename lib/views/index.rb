require 'bundler'
Bundler.require

#$:.unshift File.expand_path("./../lib", __FILE__)
#require '../app/scrapper.rb'
#require 'views/' pour appeller les programmes donnant une interface visuelle
require 'pry'

class Index

  def perform
#   binding.pry
#   puts "end of file"
    puts "What do you want to do user ?"
    puts "'Scrapper' ? 'Send' an email ?"
    answer = gets.chomp.to_s
    
    if answer == "Scrapper" 
    
        Scrapper.new.perform
    
    elsif answer == "Send"
    
        EmailSender.new.perform
    
    else 
    
        puts "I don't understand what do you mean. Do you want perform 'Scrapper' ? or 'Send' email ?"
    
    end
  end      
 # Done.new.perform
 

end

Index.new.perform


