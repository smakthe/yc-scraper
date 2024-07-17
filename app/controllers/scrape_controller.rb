class ScrapeController < ApplicationController
  include ScrapeHelper

  def index
    driver = setup_driver
    lim = params[:n]
    filters = safe_params
    file_path = "yc_scrapdata.csv"
    url = construct_url(filters)
    begin
      companies = extract_basic_info(driver, lim, url)
      save_to_csv(companies, file_path)
      render json: {
        message: "Data scraped successfully",
        status: 200
      }, status: 200
    rescue
      render json: {
        error: "Error while scraping data",
        status: 400
      }, status: 400
    end
    driver.quit
  end

  private

  def safe_params
    params.require(:filters)
          .permit(:batch, :industry, :region, :tag, :company_size, :is_hiring, :nonprofit, :black_founded, :hispanic_latino_founded, :women_founded)
  end

end
