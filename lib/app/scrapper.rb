require 'bundler'
Bundler.require
require 'nokogiri'
require 'rubygems'
require 'open-uri'
require 'json'
require 'pry'
require "google_drive"
require 'csv'

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
  end

  def save_as_spreadsheet
    #lignes qui permettent de load la config API de google avec le trés secret config2.json et le morceau de lien du google sheet dans lequel on va inserer les données
    session = GoogleDrive::Session.from_config("config2.json")
    ws = session.spreadsheet_by_key("1LNBcTsB_eCk2cZ-tMKVLaG9weHiPC7cuizilrt1c3fk").worksheets[0]
    
    # Gets content of A2 cell.
    p ws[2, 1]  #==> "hoge"
    
    #création de variable qui contient la methode get_townhall_urls 
    towns = get_townhall_urls
    
    i=0 #colonne
    k=1 #ligne
    #iteration pour chaque ligne du googlesheet on entre en colonne 1 la mairie et en colonne 2 son email
    towns.each do |town|
      # Changes content of cells. ws[ligne, colonne]
      # Changes are not sent to the server until you call ws.save().
      ws[k, 1] = town.keys[0]
      ws[k, 2] = get_townhall_email(town.values[0])
      i += 1
      k += 1
        
    end
    #sauvegarde le tableau ws entier dans le google sheet
    ws.save
      
    #Autres methodes d'ajout de contenu dans des cellules :
    # # Dumps all cells.
    # (1..ws.num_rows).each do |row|
    #   (1..ws.num_cols).each do |col|
    #     p ws[row, col]
    #   end
    # end
    #
    # # Yet another way to do so.
    # p ws.rows  #==> [["fuga", ""], ["foo", "bar]]
  
    # Reloads the worksheet to get changes by other clients.
    ws.reload
  
  end

  def save_as_csv

    i = 1
    towns = get_townhall_urls
    #création du fichier email.csv
		CSV.open("db/email.csv", "wb") do |f|
      #pour chaque url de mairie, on entre l'array [i, key[0] (la mairie), valeur[0](email correspondant) ]
      towns.each do |town|

        f << [i,town.keys[0],get_townhall_email(town.values[0])]
        i += 1

      end

    end

  end

end #fin de ma classe