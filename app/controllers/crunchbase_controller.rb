class CrunchbaseController < ApplicationController

  def index
    @search = Search.new
    respond_to do |format|
      format.html { render :index}
      format.json { render :index}
    end
  end

  def search
    @search = Search.new(search_params)
    @page = 0
    @records = {}
    respond_to do |format|
      if @search.valid?
        @records[:organization] = Organization.find_by_name(@search.search_string)
        @records[:product] = Product.find_by_name(@search.search_string)
        format.json { }
      else
        format.json { render :index}
      end
    end
  end

  def page
    @page = params[:page].to_i
    @item_type = params[:item_type]
    @search_string = params[:search_string]
    @records = {}
    @records[@item_type.to_sym] = @item_type.camelize.constantize.find_by_name(@search_string, @page)
    @template = File.join('crunchbase', "search_#{@item_type}")
  end



  def item
    @item_type = params[:item_type]
    @permalink = params[:permalink]
    @record = nil
    @record = @item_type.camelize.constantize.find_by_permalink(@permalink)
    @template = @record.nil? ? File.join('crunchbase', "item_error") : File.join('crunchbase', "#{@item_type}")
    #render :text => params.inspect
  end

  private

  def search_params
    params.require(:search).permit(:search_string)
  end

end
