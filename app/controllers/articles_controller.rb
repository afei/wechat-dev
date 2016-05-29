class ArticlesController < ApplicationController
  def index
    @articles = Article.all		
  end

  def new
	  @article = Article.new	
  end

  def create
		@article = Article.new(article_params)
		if @article.save
			render :index
		else
			render :new
		end
  end

	def show
		@article = Article.find(1)
		
		respond_to do |format|
			format.html { render }
			Rails.logger.info( @article.to_xml )
			format.xml { render :xml=>@article.to_xml }
		end
	end

	
	private
	def article_params
		params.require(:article).permit(:title, :description, :picurl, :url)
	end
end
