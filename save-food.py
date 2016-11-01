import csv
import requests
from BeautifulSoup import BeautifulSoup

import sys, traceback
import urllib
import urllib2
import cookielib
import os
from os import path
from bs4 import BeautifulSoup

url = 'http://www.fao.org/save-food/partners/en/'


soup = BeautifulSoup(url)
org = soup('span',{'class':'select2-match'})[0]
#tds = div.find('table').findAll('td')

print(org)

#for td in tds:
#    day = td('span')[0].text
#    forecast = td('div')[1].text
#    print day, forecast
#
#
#######################
## begin the scraper ##
#######################



#for a_id in award_ids: 
#		current_award = str(a_id)
#		print "Getting documents for  " + current_award
#		
#		#Open acprs url
#		url = "" + current_award + ""
#		page = urllib2.urlopen(url)
#
#		# Load the project documents page
#		soup = BeautifulSoup(page, "html.parser")
#
#		# get folder names and make folders and subfolders with contents of web page
#		folder_list = soup.find_all("span", {"class":"awardMast-awardNum"})
#		subfolder_list = soup.find_all("h2")[1:]
#		amend_list = soup.find_all("h4")
#		
#		pre_award_links = soup.find_all("table", {"id":"bordertable"})[0]
#		award_links = soup.find_all("table", {"id":"bordertable"})[1]
#		financial_links = soup.find_all("table", {"id":"bordertable"})[2]
#		performance_links = soup.find_all("table", {"id":"bordertable"})[3]
#		project_links = soup.find_all("table", {"id":"bordertable"})[4]
#		branding_links = soup.find_all("table", {"id":"bordertable"})[5]
#		closeout_links = soup.find_all("table", {"id":"bordertable"})[6]
#		payment_links = soup.find_all("table", {"id":"bordertable"})[7]
#		site_visit_links = soup.find_all("table", {"id":"bordertable"})[8]
#		other_links = soup.find_all("table", {"id":"bordertable"})[9]
#		#link_list = str(link_class).find_all("a", {"target":"_blank"})
#		
#		link_list = soup.find_all("a", {"target":"_blank"})
#		#link_class = soup.find_all("tr", {"class":["even", "odd"]}, {"target":"_blank"})
#
#		quarter_bunch = soup.find_all("table", {"id":"bordertable"})[3]
#		quarter_list = quarter_bunch.find_all("span", {"class":"midtitle"})
#		
				