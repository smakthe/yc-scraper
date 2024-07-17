module ScrapeHelper
    require 'selenium-webdriver'
    require 'csv'
    require 'json'

    # Setup Selenium WebDriver
    def setup_driver
        options = Selenium::WebDriver::Chrome::Options.new.tap do |op|
            op.add_argument('--headless')
            op.add_argument('--disable-gpu')
            op.add_argument('--no-sandbox')
        end
        Selenium::WebDriver.for :chrome, options: options
    end

    # Fetch and parse HTML content using Selenium
    def fetch_html(driver, lim, url)
        driver.get(url)
        while true
            driver.execute_script("window.scrollTo(0,document.body.scrollHeight)")
            if driver.page_source =~ /Showing\s(\d+)\s/
                break if $1.to_i > lim
            end
        end
        driver.page_source
    end

    # Construct URL with filters
    def construct_url(filters)
        base_url = 'https://www.ycombinator.com/companies'
        query_params = filters.to_hash.map { |k, v| "#{k}=#{v}" }.join('&')
        "#{base_url}?#{query_params}"
    end

    # Extract company information from the first page
    def extract_basic_info(driver, lim, url)
        companies = []
        doc = fetch_html(driver, lim, url)
        company_names = doc.scan(/coName_86jzd_453">([^<]*)</m).flatten
        company_locations = doc.scan(/coLocation_86jzd_469">([^<]*)</m).flatten
        short_descriptions = doc.scan(/coDescription_86jzd_478">([^<]*)</m).flatten
        yc_batches = doc.scan(/<\/path><\/svg>([^<]*)<\/span>/m).flatten
        company_urls = doc.scan(/company_86jzd_338"\shref="([^>]*)"/m).flatten
        base_url = "https://www.ycombinator.com"
        (0...lim).each do |i|
            detailed_info = extract_detailed_info(driver, base_url+company_urls[i])
            companies << {
                name: company_names[i],
                location: company_locations[i],
                description: short_descriptions[i],
                yc_batch: yc_batches[i]
            }.merge(detailed_info)
        end
        companies
    end

    # Extract detailed information from the second page
    def extract_detailed_info(driver, url)
        driver.get(url)
        doc = driver.page_source
        website = doc.scan(/text-linkColor\s*"><a\s+href="([^\s]*)"/).flatten
        founders = doc.scan(/leading-snug">\s*<div\s+class="font-bold">([^>]*)</m).flatten
        linkedin_urls = doc.scan(/mt-1\sspace-x-2"><a\s+href="([^\s]*)"/m).flatten
        {
            website: website,
            founders: founders,
            linkedin_urls: linkedin_urls
        }
    end

    # Save data to CSV file
    def save_to_csv(companies, file_path)
        CSV.open(file_path, 'w') do |csv|
            csv << ['Name', 'Location', 'Description', 'YC Batch', 'Website', 'Founders', 'LinkedIn URLs']
            companies.each do |company|
            csv << [
                company[:name], company[:location], company[:description], company[:yc_batch],
                company[:website], company[:founders].join('; '), company[:linkedin_urls].join('; ')
            ]
            end
        end
    end

end