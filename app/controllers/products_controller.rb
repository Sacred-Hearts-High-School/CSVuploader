class ProductsController < ApplicationController

   def index
      @products = Product.all
   end

   def import
      Product.import(params[:file])
      redirect_to root_url, notice:"Products imported."
   end

   # rails 4.0 之後才有的安全設定，要宣告允許使用的變數
   def product_params
      params.require(:product).permit(:name,:price,:released_on)
   end
       
end
