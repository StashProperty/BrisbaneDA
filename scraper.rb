require 'scraperwiki'
require 'faraday'
require 'date'
require 'json'

url = 'https://developmenti.brisbane.qld.gov.au/Geo/GetApplicationFilterResults'
info_url = 'https://developmenti.brisbane.qld.gov.au/Home/FilterDirect?filters=DANumber='

resp = Faraday.post(url) do |req|
    req.headers['Content-Type'] = 'application/json'
    req.body = '{"Progress":"all","StartDateUnixEpochNumber":0,"EndDateUnixEpochNumber":'+Date.today.to_time.to_i.to_s + '000,"DateRangeField":"submitted","DateRangeDescriptor":"Last 7 Days","MaxRecords":1000,"SortField":"submitted","PixelWidth":800,"PixelHeight":800}'
end
raw = JSON.parse(resp.body)

raw['features'][1..-1].each do |set|
	record = {}
	set = set['properties']
	record['council_reference'] = set['application_number']
	record['address'] = set['description'].split(" - ")[0]
	record['description'] = set['description'].split(" - ")[1..-1].join(" - ")
	record['info_url'] = info_url + record['council_reference']
	record['date_received'] = set['date_received']
	record['date_scraped'] = Date.today.to_s
	puts "Saving #{record['council_reference']}, #{record['address']}"
	ScraperWiki.save_sqlite(['council_reference'], record)
end
