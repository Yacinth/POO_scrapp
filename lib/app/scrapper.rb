require 'bundler'
Bundler.require
require 'nokogiri'
require 'rubygems'
require 'open-uri'
require 'json'
require 'pry'
require "google_drive"

class Scrapper

  def get_townhall_mails
    townhall_mails = []
    i = 0
    page = Nokogiri::HTML(open("http://www.annuaire-des-mairies.com/val-d-oise.html"))
    page.xpath('//p/a').each do |url|
      mail = get_townhall_email("http://www.annuaire-des-mairies.com/"+url['href'][1..-1])
      townhall_mails << { url.text.downcase => mail }
    end
  end

  def get_townhall_urls
    urls = []
    page = Nokogiri::HTML(open("http://www.annuaire-des-mairies.com/val-d-oise.html"))
    page.xpath('//p/a').each do |url|
      urls << { url.text.downcase => "http://www.annuaire-des-mairies.com/"+url['href'][1..-1] }
    end
    return urls
  end
  
  def get_townhall_email(townhall_url)
    begin
      page = Nokogiri::HTML(open(townhall_url))
      #page.encoding = 'utf-8'
      unless page.xpath('//body').text.downcase.include?('adresse email')
        return ''
      end
      page.xpath('//td').each do |td|
        match = td.text.match(/[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,4}/i)
        if(match)
          return match[0]
        end
      end
      rescue StandardError => e  
        #puts e.message  
        #puts e.backtrace.inspect  
        #puts townhall_url
        #return ''
    end
    #return ''
  end
  
  def big_array
    towns = get_townhall_urls
    
    a = []
    i=0
      towns.each do |town|
        a << { town.keys[0] => get_townhall_email(town.values[0]) }
        i += 1
      #break if i == 25
      #puts i
      end
    return a
  end
  
  #methode qui crée un fichier array_email.json dans le dossier db et y insere le big_array
  def save_as_JSON
      File.open("db/array_email.json","w") do |f|
      f.write(JSON.pretty_generate(big_array))
      
  end

  def save_as_spreadsheet

  session = GoogleDrive::Session.from_config("config.json")
  ws = session.spreadsheet_by_key("1LNBcTsB_eCk2cZ-tMKVLaG9weHiPC7cuizilrt1c3fk").worksheets[0]
  
  # Gets content of A2 cell.
  p ws[2, 1]  #==> "hoge"
  
  towns = get_townhall_urls
  
  i=0
  k=1
  towns.each do |town|
    # Changes content of cells.
    # Changes are not sent to the server until you call ws.save().
    ws[k, 1] = town.keys[0]
    ws[k, 2] = get_townhall_email(town.values[0])
    i += 1
    k += 1
      
  end
  #sauvegarde le tableau entier dans le google sheet
  ws.save
    
  # Dumps all cells.
  (1..ws.num_rows).each do |row|
    (1..ws.num_cols).each do |col|
      p ws[row, col]
    end
  end

  # Yet another way to do so.
  p ws.rows  #==> [["fuga", ""], ["foo", "bar]]

  # Reloads the worksheet to get changes by other clients.
  ws.reload
  
  end



end #fin de ma classe

#Scrapper.new.save_as_spreadsheet
end
