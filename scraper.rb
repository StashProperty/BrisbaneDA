# Scraping from Masterview 2.0

 
 
def scrape_page(page) 
 page.at("table#_ctl2_pnl table").search("tr")[2..-1].each do |tr| 
   tds = tr.search('td').map{|t| t.inner_text.gsub("\r\n", "").strip} 
   p tds 
     day, month, year = tds[3].split("/").map{|s| s.to_i} 
     record = { 
       "info_url" => (page.uri + tr.search('td').at('a')["href"]).to_s, 
       "council_reference" => tds[1].split(" - ")[0].squeeze(" ").strip, 
       "date_received" => Date.new(year, month, day).to_s, 
       "description" => tds[1].split(" - ")[1..-1].join(" - ").squeeze(" ").strip, 
       "address" => tds[2].squeeze(" ").strip, 
       "date_scraped" => Date.today.to_s 
     } 
     record["comment_url"] = "https://sde.brisbane.qld.gov.au/services/startDASubmission.do?direct=true&daNumber=" + CGI.escape(record["council_reference"]) + "&sdeprop=" + CGI.escape(record["address"]) 
     #p record 
     if (ScraperWiki.select("* from data where `council_reference`='#{record['council_reference']}'").empty? rescue true) 
       ScraperWiki.save_sqlite(['council_reference'], record) 
     else 
       puts "Skipping already saved record " + record['council_reference'] 
     end 
   end 
 end 
 
 
 url = "http://pdonline.brisbane.qld.gov.au/MasterView/modules/applicationmaster/default.aspx?page=found&1=thismonth&6=F" 
 
 
agent = Mechanize.new 
 
 
# Read in a page 
page = agent.get(url) 
 
 
form = page.forms.first 
button = form.button_with(value: "I agree") 
raise "Can't find agree button" if button.nil? 
page = form.submit(button) 
page = agent.get(url) 
 
 
scrape_page(page) 
