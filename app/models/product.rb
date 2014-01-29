require 'csv'
require 'roo'
require 'iconv'

class Product < ActiveRecord::Base

   #attr_accessible :name, :price, :released_on
   

   def self.import(file)
      allowed_attributes = ["id","name","release_on","price","create_at","updated_at"]
      spreadsheet = open_spreadsheet(file)
      header = spreadsheet.row(1)
      (2..spreadsheet.last_row).each do |i|
         row=Hash[[header,spreadsheet.row(i)].transpose]
         product = find_by_id(row["id"]) || new
         product.attributes = row.to_hash.select {|k,v| allowed_attributes.include? k }
         product.save!
      end
   end

   def self.open_spreadsheet(file)
      case File.extname(file.original_filename)
      when '.csv' then Roo::Csv.new(file.path)
      when '.xls' then Roo::Excel.new(file.path, nil, :ignore)
      when '.xlsx' then Roo::Excelx.new(file.path, nil, :ignore)
      else raise "Unknown file type: #{file.original_filename}"
      end
   end

end