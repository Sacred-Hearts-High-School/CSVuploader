require 'csv'
require 'roo'
require 'iconv'

class Product < ActiveRecord::Base


   # 這裡的 import 方法，會自動判斷匯入的資料檔欄位標題
   # 就算匯入的檔案，欄位沒有依照順序也不要緊，
   # 不過資料檔第一行一定要吻合系統資料欄位名稱。
   # 因我們常用中文做第一行欄位名稱，這個方法反而不好用。
   # 不過這段程式可以新增(new)，也可以更新(update)資料
   # 算是多功能的作法。
   def self.import(file)
      allowed_attributes = ["id","name","released_on","price","create_at","updated_at"]
      spreadsheet = open_spreadsheet(file)
      header = spreadsheet.row(1)
      (2..spreadsheet.last_row).each do |i|
         row=Hash[[header,spreadsheet.row(i)].transpose]
         product = find_by_id(row["id"]) || new
         product.attributes = row.to_hash.select {|k,v| allowed_attributes.include? k }
         product.save!
      end
   end

   # 這裡用固定欄位順序來匯入，所以匯入的 Excel 一定要照這個順序：
   # name, price, release_on  而且第一行是標題欄位，會自動略過。
   # 本段程式只能用來新增資料 (new)
   def self.import2(file)
      spreadsheet = open_spreadsheet(file)

      # 這是略過第一行的意思
      header = spreadsheet.row(1)
      # 從第二行讀取到最後
      (2..spreadsheet.last_row).each do |i|

         product = Product.new
         product.name = spreadsheet.row(i)[0]
         product.price = spreadsheet.row(i)[1]
         product.released_on = spreadsheet.row(i)[2]

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
