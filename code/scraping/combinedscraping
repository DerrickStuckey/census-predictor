
# -*- coding: utf-8 -*-
"""
Created on Fri Feb 20 07:00:51 2015

@author: Jillian
"""
###This code downloads and combines all data at the zip code level, including:
###census total population; state abbreviations; total SS recipients;
###total tax returns filed and other IRS data; number of medicare certified hospital beds; 
###number of gas stations; number of fast food restaurants; number 
###of FCC registered antenna structures; number of childcare centers and number of home daycare centers;
###median housing price; median rent; 5-year change in home values; % of population that: is white, is Asian is black,
###has a bachelors, has a masters, is hispanic, is multiracial; and % of households having children. 
###To pull the census data you would need to input an API key, and to pull the hospital data you
### would need to supply the user id, password and be on an authorized network.

import os
os.chdir('C:/Users/Jillian/Documents/GWU/practicum')
censusAPI = ' ' #put census API key here
ahd_username = ' ' #put AHD user name here
ahd_pword = ' ' #put AHD password here

##PART I: PULLING FILE WITH CENSUS FIPS CODES, STATE ABBREVIATIONS

def GetFIPSdata():
    import urllib2
    import pandas as pd
    print "Pulling FIPS data"
    URL = 'http://www2.census.gov/geo/docs/reference/codes/files/national_county.txt'
    html = urllib2.urlopen(URL).read()
    
    #saving the data as a text file
    testtext = open("CensusData/2010countyFips.txt", "w")
    print>>testtext, html
    
    #Making lists to hold the data for each variable and importing text file
    State = []
    StateFP = []
    CountyFP = []
    CountyName = []
    ClassFP = []
    
    results = []
    with open('CensusData/2010countyFips.txt') as inputfile:
        for line in inputfile:
            results.append(line.strip().split(','))
    
    #appending data to lists
    for record in results:
        if record != ['']:
            State.append(record[0])
            StateFP.append(record[1])
            CountyFP.append(record[2])
            CountyName.append(record[3])
            ClassFP.append(record[4])
    
    #converting to data frame    
    d = {
            'StateAbbr': State,
            'StateFP': StateFP,
            'CountyFP': CountyFP,
            'CountyName': CountyName,
            'ClassFP': ClassFP,
        } 
    
    CountyStateFP = pd.DataFrame(data=d)
    return CountyStateFP

##PART II: USING FIPS CODES TO PULL CENSUS DATA FOR EACH STATE
def GetCensusData(CSFP):
    import re
    import urllib2
    import pandas as pd
    import us
    print "Pulling census data"
    
    #Getting a unique list of state codes
    StateCodes = CSFP['StateFP'].unique()
    
    #Pulling census zip-code-level total population data using those codes,
    #adding full state names and making into data frame
    BASE_URL = 'http://api.census.gov/data/2010/sf1?get=P0010001&for=zip+code+tabulation+area:*&in=state:'
    url_end = '&key=' + censusAPI
    
    St_list = []
    Pop_list = []
    Zip_list = []
    stateName = []
    for state in StateCodes:
        url = BASE_URL + state + url_end
        html = urllib2.urlopen(url).read()
        records = re.findall('\["([0-9]*)","([0-9]*)","([0-9]*)"\]',html)
        for record in records:
            Pop_list.append(record[0])
            St_list.append(record[1])
            stateName.append(us.states.lookup(record[1]))
            Zip_list.append(record[2])
    
    d = {
            'stateCode': St_list,
            'zipCode': Zip_list,
            '2010pop': Pop_list,
            'state': stateName,
        } 
    
    PopulationByZip = pd.DataFrame(data=d)
    
    #Bringing state abbrevs from FIPS into census and making unique index
    FIPS2= CSFP[["StateAbbr","StateFP"]]
    FIPS2 = FIPS2.drop_duplicates()
    StateAbbrev = FIPS2.set_index("StateFP")
    pop2 = PopulationByZip
    pop2["CodeInd"] = pop2["stateCode"]
    pop2['CodeInd2'] = "C" + pop2.apply(lambda x:'%s%s' % (x['stateCode'],x['zipCode']),axis=1)
    pop2 = pop2.set_index("CodeInd")
    PopByZip = pop2.join(StateAbbrev, how='left')
    PopByZip = PopByZip.set_index("CodeInd2")
    return PopByZip

##PART III: DOWNLOADING AND JOINING SS DATA 
def GetSSdata():
    print "Pulling Social Security data"
    import urllib2
    #downloading file with SS recipients by zip code
    fileUrl = 'http://www.ssa.gov/policy/docs/statcomps/oasdi_zip/2010/oasdi_zip10.xlsx'
    f = urllib2.urlopen(fileUrl)
    data = f.read()
    with open('SS/SS.2010_zip.xlsx', 'wb') as w:
        w.write(data)

def SS_CensusJoin(PBZ2):
    import pandas as pd
    import us
    xls = pd.ExcelFile('SS/SS.2010_zip.xlsx')
    
    #pulling data off excel spreadsheet for each state/territory and 
    #appending to a single data frame
    X=range(0, 56)
    SSbyZip = pd.DataFrame()
    for x in X:
        df = xls.parse(sheetname=x, skiprows=6, index_col=None, na_values=['NA'])
        df = df.iloc[:,[1,3]]  #selecting columns with relevant data      
        df["2010.SSrecip"] = df.iloc[:,[1]] #making named columns to hold that data
        df["zipCode"] = df.iloc[:,[0]]
        df = df.iloc[:,[2,3]]   #selecting only my named columns         
        names = []
        for name in xls.sheet_names:
            names.append(name) #pulling the name of each sheet (state name)
        df["names"] = names[x]
        SSbyZip = SSbyZip.append(df, ignore_index=True) #appending all of this state data to master data
    FIPS = us.states.mapping('name', 'fips')
    FIPS2 = pd.DataFrame(data=FIPS.items(), columns=['name', 'fips'])
    FIPS2 = FIPS2.set_index('name')
    SSbyZip["tempInd"] = SSbyZip["names"]
    SSbyZip = SSbyZip.set_index("tempInd")
    FipsJoin = SSbyZip.join(FIPS2, how='left')
    
    #dropping junk rows and adding leading zeros back into zip codes and state codes
    SSbyZip = FipsJoin.dropna(subset=[["zipCode", "fips"]])
    SSbyZip = SSbyZip[SSbyZip.zipCode != 'Includes beneficiaries in foreign countries.']  
    SSbyZip.zipCode = SSbyZip.zipCode.astype(int)
    SSbyZip["zipCode"] =SSbyZip.zipCode.map("{:05}".format)
    SSbyZip.fips = SSbyZip.fips.astype(int)
    SSbyZip["fips"] =SSbyZip.fips.map("{:02}".format)    
    SSbyZip["index"] =  "C" + SSbyZip.apply(lambda x:'%s%s' % (x['fips'],x['zipCode']),axis=1)
    
    #Adding the SS totals to the census data
    SSbyZip2 = SSbyZip.set_index("index")   
    SSbyZip2 = SSbyZip2.drop(['zipCode', 'names'], axis=1) 
    pop3 = PBZ2
    combined2010 = pop3.join(SSbyZip2, how='left')
    combined2010.to_pickle('zipSS.pk')  
    return combined2010

##Part IV: PULLING AND JOININ IRS TAX DATA   
def GetIRSdata():
    import urllib
    import zipfile
    import os
    import shutil
    
    print "Pulling IRS data"    
    #downloading zipped folder with 2010 tax records
    fileUrl = 'http://www.irs.gov/file_source/pub/irs-soi/2010zipcode.zip'
    urllib.urlretrieve(fileUrl,"IRS/IRS.2010.zip")
    #unzipping only needed file
    my_dir = r"IRS"
    my_zip = r"IRS/IRS.2010.zip"
    
    with zipfile.ZipFile(my_zip) as zip_file:
        filename = os.path.basename('10zpallnoagi.csv')
        source = zip_file.open('10zpallnoagi.csv')
        target = file(os.path.join(my_dir, filename), "wb")
        with source, target:
            shutil.copyfileobj(source, target)

def IRS_CensusJoin(COMB2010):
    #pulling in relevant columns and rows from IRS data and prep for join with master data
    IRSdf = pd.DataFrame.from_csv("IRS/10zpallnoagi.csv", header=1, index_col=None)
    IRSdf['IRS_rtrns'] = IRSdf.iloc[:,4]
    IRSdf = IRSdf[IRSdf.IRS_rtrns != 0]
    IRSdf['fips'] = IRSdf.iloc[:,0]
    IRSdf['zipCode']=IRSdf.iloc[:,2]
    IRSdf['avgDependents']=IRSdf.iloc[:,8]/IRSdf.iloc[:,4]
    IRSdf['avgJointRtrns']=IRSdf.iloc[:,5]/IRSdf.iloc[:,4]
    IRSdf['avgChldTxCred']=IRSdf.iloc[:,51]/IRSdf.iloc[:,4]
    IRSdf['avgUnemp']=IRSdf.iloc[:,28]/IRSdf.iloc[:,4]
    IRSdf['avgFrmRtrns']=IRSdf.iloc[:,20]/IRSdf.iloc[:,4]
    IRSdf['avgTaxes']=IRSdf.iloc[:,35]/IRSdf.iloc[:,4]
    IRSdf = IRSdf[['fips','zipCode','avgDependents','avgJointRtrns','avgChldTxCred','avgUnemp','avgFrmRtrns','avgTaxes']]
    
    #adding back in leading zeros to zips and fips codes
    IRSdf.zipCode = IRSdf.zipCode.astype(int)
    IRSdf['zipCode'] =IRSdf.zipCode.map("{:05}".format)
    IRSdf.zipCode = IRSdf.zipCode.astype(str)
    IRSdf.fips = IRSdf.fips.astype(int)
    IRSdf['fips'] =IRSdf.fips.map("{:02}".format)
    IRSdf.fips = IRSdf.fips.astype(str)
    #creating index field
    IRSdf['index'] = "C" + IRSdf.apply(lambda x:'%s%s' % (x['fips'],x['zipCode']),axis=1)
    #Combining IRS data with census data
    IRSdf2 = IRSdf.set_index('index')
    IRSdf2 = IRSdf2.iloc[:,0]
    
    combined2010 = COMB2010.join(IRSdf2, how='left')
    combined2010.to_pickle('zipSS_IRS.pk')
    return combined2010

##Part V: PULLING AND JOINING HOSPITAL BED DATA
def HospBeds():
    from selenium import webdriver
    import time
    import pandas as pd
    import urllib2
    
    path_to_chromedriver = 'chromedriver_win32/chromedriver.exe' # change path as needed
    browser = webdriver.Chrome(executable_path = path_to_chromedriver)
    time.sleep(10)
    browser.set_page_load_timeout(30)
    print "pulling hospital data"
    url1 = 'http://www.ahd.com/search.php'
    browser.get(url1)
    time.sleep(10)
    
    #entering log in info
    browser.find_element_by_id('username').send_keys(ahd_username)
    browser.find_element_by_id('password').send_keys(ahd_pword)
    browser.find_element_by_name('Submit').click()
    
    #setting min and max number of total beds for each query 
    #(because a maximum of 750 records can be downloaded at once)
    min = [1,25,27,46,70,101,151,221,351]
    max = [24,26,45,69,100,150,220,350,5000]
    x = range(0,len(min))
    for n in x:
        browser.find_element_by_id('bed_min_total').clear()
        browser.find_element_by_id('bed_min_total').send_keys(min[n])
        browser.find_element_by_id('bed_max_total').clear()    
        browser.find_element_by_id('bed_max_total').send_keys(max[n])
        browser.find_element_by_name('submitted').click()
        time.sleep(10)
        href = 'http://www.ahd.com/list_cms.php?bed_min_total=' +str(min[n]) + '&bed_max_total=' + str(max[n]) + '&listing=1&viewmap=0&excel=1'
        f = urllib2.urlopen(href)  
        data = f.read()
        name = "Hospitals/hospitalfile" + str(n) + ".xls"
        with open(name, 'wb') as w:
            w.write(data)
        browser.find_element_by_link_text("Search").click()
        time.sleep(5)
    #combining query data, removing dupes and pulling relevant columns
    Data = pd.ExcelFile('Hospitals/hospitalfile0.xls', header=7, index_col=None)
    name = Data.sheet_names
    HospitalData = Data.parse(name[0], index_col = None, header = 7)
    for x in range(1,9):
        loc = 'Hospitals/hospitalfile' +str(x) +'.xls'
        Data2 = pd.ExcelFile(loc, header=7, index_col=None)
        names = Data2.sheet_names
        parsed = Data2.parse(names[0], index_col = None, header = 7)   
        HospitalData = HospitalData.append(parsed)
        
    HospitalData.to_pickle('Hospitals/CombinedHospitalData.pk')


def HospJoin():
    import pandas as pd
    CombinedData  = pd.read_pickle('zipSS_IRS.pk')
    
    #pulling a list of fips from the combined data set for indexing
    StateFips = CombinedData[["StateAbbr","stateCode"]]
    StateFips = StateFips.set_index('StateAbbr')
    StateFips = StateFips.drop_duplicates()
    
    #creating index field, getting sums of beds by zip+state combo
    HospitalData = pd.read_pickle('Hospitals/CombinedHospitalData.pkl')
    HospitalData = HospitalData[["Beds","State","ZIP"]]
    HospitalData = HospitalData[(HospitalData['State'] != "MP") & (HospitalData['State'] != "GU") & (HospitalData['State'] != "VI")]
    HospitalData = HospitalData.set_index('State')
    HospitalData2 = HospitalData.join(StateFips, how='left')  
    HospitalData2["index"] =  "C" + HospitalData2.apply(lambda x:'%s%s' % (x['stateCode'],x['ZIP']),axis=1)
    HospitalData2 = HospitalData2[["Beds","index"]]
    HospitalData2.Beds = HospitalData2.Beds.astype(int)
    BedSums= HospitalData2.groupby('index', as_index=False).sum()
    BedSums= BedSums.set_index('index')
    
    #indexing bed sums back into combined data set and saving it
    CombinedData2 = CombinedData.join(BedSums, how='left')
    CombinedData2.to_pickle('zipSS_IRS_Beds.pk')
    
##Part VI: PULLING AND JOINING GAS STATION DATA
def GetGasStations():
    from bs4 import BeautifulSoup
    import urllib2
    import os
    import pandas as pd
    import time
    
    os.chdir('C:/Users/Jillian/Documents/GWU/practicum')
    print "Pulling number of gas stations"
    CombinedData = pd.read_pickle('zipSS_IRS.pk')
    zipCodes = CombinedData['zipCode']
    zc = []
    totalStations = []
    
    for zipCode in zipCodes:
        BASE_URL = 'http://www.allgasstations.com/ZipCodes.php?zip='
        url = BASE_URL + str(zipCode)
        html = urllib2.urlopen(url).read()    
        soup = BeautifulSoup(html)
        try:    
            stations = soup.find('td')
            stations2 = stations.find_all('i')
            totalStations.append(len(stations2))
        except Exception:
            stations.append(0)
        zc.append(zipCode)
        time.sleep(2)
    
    d = {'zipCode': zc, 'gasStations': totalStations}
    stations = pd.DataFrame(d)
    stations.to_pickle('GasStations/stations.pk')

def GasJoin():
    import pandas as pd
    #note: gas stations are by zip, across state where necessary (i.e., where a zip is in 2 states,
    #the number repeats)    
    CombinedData = pd.read_pickle('zipSS_IRS_Beds.pk')
    stations = pd.read_pickle('GasStations/stations.pk')
    stations2 = stations.drop_duplicates()
    stations2 = stations2.set_index('zipCode')
    CombinedData['index'] = CombinedData['zipCode']
    CombinedZip = CombinedData.reset_index('index')
    CombinedZip = CombinedZip.set_index('index')
    Combined = CombinedZip.join(stations2, how='left')
    Combined = Combined.set_index('CodeInd2')
    Combined.to_pickle('zipSS_IRS_Beds_Gas.pk')


##Part VII: GETTING AND JOINING NUMBER OF FAST FOOD RESTAURANTS
def GetFastFood():
    import urllib
    import zipfile
    import shutil
    import os
    
    os.chdir('C:/Users/Jillian/Documents/GWU/practicum')
    print "Pulling number of fast food restaurants"
    fileUrl = 'http://www.fastfoodmaps.com/fastfoodmaps_locations_2007.csv.zip'
    urllib.urlretrieve(fileUrl,"FastFood/FastFoodLoc_2007.zip")
    #unzipping only needed file
    my_dir = r"FastFood"
    my_zip = r"FastFood/FastFoodLoc_2007.zip"
    
    with zipfile.ZipFile(my_zip) as zip_file:
        filename = os.path.basename('fastfoodmaps_locations_2007.csv')
        source = zip_file.open('fastfoodmaps_locations_2007.csv')
        target = file(os.path.join(my_dir, filename), "wb")
        with source, target:
            shutil.copyfileobj(source, target)


def FastFoodJoin():
    import pandas as pd
    #pulling in relevant columns and rows from IRS data and prep for join with master data
    CombinedData  = pd.read_pickle('zipSS_IRS_Beds_Gas.pk')
    #pulling a list of fips from the combined data set for indexing
    StateFips = CombinedData[["StateAbbr","stateCode"]]
    StateFips = StateFips.set_index('StateAbbr')
    StateFips = StateFips.drop_duplicates()
    
    #prepping the fast food data and getting counts by zip code
    fastfood = pd.DataFrame.from_csv("FastFood/fastfoodmaps_locations_2007.csv", header=None, index_col=1)
    fastfood = fastfood.iloc[:,[4,5]]
    fastfood.columns = ['state', 'zip']
    fastfood = fastfood.set_index('state')
    fastfood2 = fastfood.join(StateFips, how='left')  
    fastfood2['zip'] = fastfood2['zip'].str[:5]
    fastfood2.zip = fastfood2.zip.astype(int)
    fastfood2['zip'] =fastfood2.zip.map("{:05}".format)
    fastfood2["index"] =  "C" + fastfood2.apply(lambda x:'%s%s' % (x['stateCode'],x['zip']),axis=1)
    ff_count= fastfood2.groupby('index', as_index=False).count()
    ff_count = ff_count.iloc[:,[1]]
    ff_count.columns = ['count_fastfood']
    
    #joining fast food data with combined table
    comb_ff = CombinedData.join(ff_count, how='left')
    comb_ff.to_pickle('zipSS_IRS_Beds_Gas_FF.pk')


##Part VIII: GETTING AND JOINING DATA ON NUMBER OF FCC REGISTERED ANTENNA STRUCTURES
def GetTowers():
    from selenium import webdriver
    import time
    import pandas as pd
    import re

    print "Pulling number of antenna structures"
    
    ##NOTE: This code takes days to pull all the data
    path_to_chromedriver = 'chromedriver_win32/chromedriver.exe' # change path as needed
    browser = webdriver.Chrome(executable_path = path_to_chromedriver)
    time.sleep(5)
    browser.set_page_load_timeout(120)
    print "pulling cell tower data"
    url1 = 'http://wireless2.fcc.gov/UlsApp/AsrSearch/asrRegistrationSearch.jsp'
    browser.get(url1)
    time.sleep(5)
    browser.set_script_timeout(30)
    
    #pulling zips from master data
    CombinedData = pd.read_pickle('zipSS_IRS.pk')
    zipList = CombinedData['zipCode']
    ##making lists to hold the data   
    zipCode = []
    towers = []
    
    #entering search query
    browser.find_element_by_xpath('/html/body/table[4]/tbody/tr/td[2]/div/table/tbody/tr/td[3]/form/div/table/tbody/tr[2]/td/table/tbody/tr[4]/td/input').click()
    for x in zipList:
        zipField = browser.find_element_by_xpath('/html/body/table[4]/tbody/tr/td[2]/div/table/tbody/tr/td[3]/form/div/table/tbody/tr[2]/td/table/tbody/tr[5]/td/table/tbody/tr[4]/td[2]/input[1]')   
        zipField.clear() 
        zipField.send_keys(x)    
        #scraping total towers    
        browser.find_element_by_xpath('/html/body/table[4]/tbody/tr/td[2]/div/table/tbody/tr/td[3]/form/div/table/tbody/tr[2]/td/table/tbody/tr[5]/td/table/tbody/tr[4]/td[2]/input[2]').click()
        browser.implicitly_wait(20)
        hits = browser.find_element_by_css_selector('td.cell-pri-light')
        counthits = hits.text.encode('ascii', 'ignore')
        tower = re.findall('Matches [0-9]+-[0-9]+ \(of ([0-9]+)',counthits)
        zipCode.append(x)    
        print x    
        print tower
        if tower != []:
            towers.extend(tower)
        else:
            towers.append('0')
        browser.back()
        time.sleep(1)
    #saving results as a data frame
    d = {'zipCode': zipCode, 'towers': towers}
    towerDF = pd.DataFrame(d)
    towerDF.to_pickle('CellTowers/cellTowers.pk')

def TowersJoin():
    import pandas as pd
    #note: data is by zip, across state where necessary (i.e., where a zip is in 2 states,
    #the number repeats)    
    CombinedData = pd.read_pickle('zipSS_IRS_Beds_Gas_ff.pk')
    towers = pd.read_pickle('CellTowers/cellTowers.pk')
    towers2 = towers.drop_duplicates()
    towers2 = towers2.set_index('zipCode')
    CombinedData['index'] = CombinedData['zipCode']
    CombinedZip = CombinedData.reset_index('index')
    CombinedZip = CombinedZip.set_index('index')
    Combined = CombinedZip.join(towers2, how='left')
    Combined = Combined.rename(columns={'level_0': 'CodeInd2'})
    Combined = Combined.set_index('CodeInd2')
    Combined.to_pickle('zipSS_IRS_Beds_Gas_ff_towers.pk')
    
##Part IX: GETTING AND JOINING NUMBER OF CHILD CARE AND DAYCARE CENTERS
def GetDayCare():
    import re
    import urllib2
    import pandas as pd
    
    print "Pulling number of home care and daycare centers"
    
    CombinedData = pd.read_pickle('zipSS_IRS.pk')
    info = CombinedData[['zipCode', 'state']]
    info[['state']] = info[['state']].astype(str)
    info['state2'] = info['state'].map(str.lower)
    info['state2'] = info['state2'].str.replace(' ','_')
    zc = []
    careCenters = []
    homeCare = []
    stateFormat = []
    stateOrig = CombinedData['state']
    
    for i, row in enumerate(info.values):   
        zipCode = info['zipCode'][i]
        states = info['state2'][i]
        BASE_URL = 'http://childcarecenter.us/'
        state = str(states) +'/'
        END_URL = '_childcare'
        url = BASE_URL + state + str(zipCode) + END_URL
        html = urllib2.urlopen(url).read()   
        centers = re.findall('There are ([0-9]+)',html) 
        familycare = re.findall('You may also want to check out ([0-9])+', html)
        zc.append(zipCode)    
        stateFormat.append(state)
        if len(familycare):
            homeCare.append(int(familycare[0]))
        else:
            homeCare.append(0)
        if len(centers):
            careCenters.append(int(centers[0]))
        else:
            careCenters.append(0)
        print zipCode
        
    
    d = {'zipCode': zc, 'careCenters': careCenters, 'homeDaycare': homeCare, 'state': stateOrig}
    childCare = pd.DataFrame(d)
    childCare.to_pickle('Daycare/childCare.pk')

def DayCareJoin():
    import pandas as pd   
    CombinedData = pd.read_pickle('zipSS_IRS_Beds_Gas_ff_towers.pk')
    daycare = pd.read_pickle('Daycare/childCare.pk')
    daycare=daycare[['careCenters','homeDaycare']]
    Combined = CombinedData.join(daycare, how='left')
    Combined.to_pickle('zipSS_IRS_Beds_Gas_ff_towers_daycare.pk')

##Part X: GETTING AND JOINING NUMBER OF CVS STORES
def GetCVS():
    from bs4 import BeautifulSoup
    import urllib2
    import pandas as pd
    import re
    import time
    
    print "Pulling number of CVS stores"
    
    CombinedData = pd.read_pickle('zipSS_IRS.pk')
    CombinedData[['state']] = CombinedData[['state']].astype(str)
    CombinedData['state2'] = CombinedData['state'].str.replace(' ','-')
    unique = CombinedData['state2'].unique()
    
    storeZipcodes = []
    
    #creating a list in which every store zip code is listed once
    for i in unique:   
            BASE_URL = 'http://www.cvs.com/stores/cvs-pharmacy-locations/'
            url = BASE_URL + str(i)
            html = urllib2.urlopen(url).read()    
            soup = BeautifulSoup(html)
            stateLinks = soup.find("div", class_="states")
            hrefList = []
            for a in stateLinks.find_all('a', href=True):
                site = 'http://www.cvs.com' + a['href']
                if site not in hrefList:
                    hrefList.append(site)
            for link in hrefList:
                if link == 'http://www.cvs.com/stores/cvs-pharmacy-locations/New-York/Suffern%2Fmontebello':
                    pass
                else:
                    time.sleep(3)
                    print link
                    cityPage = urllib2.urlopen(link).read()
                    storeZips= re.findall('[A-Z]{2} ([0-9]{5})', cityPage)
                    storeZipcodes.extend(storeZips[2:]) #two spurious zips show up at the start of all pages, removing these
                    print storeZips[2:]
    
    df = pd.DataFrame(storeZipcodes)
    df.to_pickle('CVS/FullStoreZipList.pk')
    
def JoinCVS():
    import os
    import pandas as pd
    os.chdir('C:/Users/Jillian/Documents/GWU/practicum')
    cvs = pd.read_pickle('CVS/FullStoreZipList.pk')
    cvs.columns = ['CVSstores']
    #getting count by zipcode
    grouped= cvs.groupby(cvs['CVSstores']).count()
    #merging into master data
    CombinedData= pd.read_pickle('zipSS_IRS_Beds_Gas_ff_towers_daycare.pk')
    CombinedData['CodeInd2'] = CombinedData.index
    CombinedData['zipCode2']=CombinedData["zipCode"]
    CombinedData=CombinedData.set_index('zipCode2')
    final= CombinedData.join(grouped, how='left')
    final['CVSstores']=final['CVSstores'].fillna(0)
    final=final.set_index('CodeInd2')
    final.to_pickle('zipSS_IRS_Beds_Gas_ff_towers_daycare_CVS.pk')

##Part XI: GETTING AND JOINING HOUSING AND RENT DATA
def GetHousing():
    #average home value
    import urllib2
    print "Pulling housing and rental data"
    #downloading and importing zillow data sets
    #median sale price
    fileUrl = 'http://files.zillowstatic.com/research/public/Zip/Zip_Zhvi_AllHomes.csv'
    f = urllib2.urlopen(fileUrl)
    data = f.read()
    with open('Zillow/medianHomePrice.csv', 'wb') as w:
        w.write(data)
    #median rent
    fileUrl = 'http://files.zillowstatic.com/research/public/Zip/Zip_Zri_AllHomes.csv'
    f = urllib2.urlopen(fileUrl)
    data = f.read()
    with open('Zillow/medianRentIndex.csv', 'wb') as w:
        w.write(data)
    #5-year change in value
    fileUrl = 'http://files.zillowstatic.com/research/public/Zip/Zip_Zhvi_Summary_AllHomes.csv'
    f = urllib2.urlopen(fileUrl)
    data = f.read()
    with open('Zillow/ValueChange5yr.csv', 'wb') as w:
        w.write(data)


def JoinHousing():
    import pandas as pd
    
    #Getting average across year of median house prices by month 
    medPrice = pd.DataFrame.from_csv('Zillow/medianHomePrice.csv', index_col=None)
    medPrice=medPrice[['RegionName', '2014-01','2014-02','2014-03','2014-04','2014-05','2014-06','2014-07','2014-08','2014-09','2014-10','2014-11','2014-12',]]
    medPrice['AvgHousePrc2014']=(medPrice['2014-01']+medPrice['2014-02']+medPrice['2014-03']+medPrice['2014-04']+medPrice['2014-05']+medPrice['2014-06']+medPrice['2014-07']+medPrice['2014-08']+medPrice['2014-09']+medPrice['2014-10']+medPrice['2014-11']+medPrice['2014-12'])/12
    medPrice=medPrice[['RegionName','AvgHousePrc2014']]
    medPrice["RegionName"] =medPrice.RegionName.map("{:05}".format)
    medPrice=medPrice.set_index('RegionName')
    
    #Getting average across year of median rent 
    medRent = pd.DataFrame.from_csv('Zillow/medianRentIndex.csv', index_col=None)
    medRent['AvgRent2014']=(medRent['2014-01']+medRent['2014-02']+medRent['2014-03']+medRent['2014-04']+medRent['2014-05']+medRent['2014-06']+medRent['2014-07']+medRent['2014-08']+medRent['2014-09']+medRent['2014-10']+medRent['2014-11']+medRent['2014-12'])/12
    medRent=medRent[['RegionName','AvgRent2014']]
    medRent["RegionName"] =medRent.RegionName.map("{:05}".format)
    medRent=medRent.set_index('RegionName')
    
    #Getting 5-year change in home values (5year)
    ValChng = pd.DataFrame.from_csv('Zillow/ValueChange5yr.csv', index_col=None)
    ValChng=ValChng[['RegionName','5Year']]
    ValChng["RegionName"] =ValChng.RegionName.map("{:05}".format)
    ValChng=ValChng.set_index('RegionName')
    
    #Indexing all data into Full data set
    CombinedData= pd.read_pickle('zipSS_IRS_Beds_Gas_ff_towers_daycare_CVS.pk')
    CombinedData['CodeInd2'] = CombinedData.index
    CombinedData=CombinedData.set_index('zipCode')
    final= CombinedData.join(medPrice, how='left')
    final2=final.join(medRent, how='left')
    final3=final2.join(ValChng, how='left')
    final3=final3.set_index('CodeInd2')
    final3.to_pickle('zipSS_IRS_Beds_Gas_ff_towers_daycare_CVS_zillow.pk')

##Part XII: GETTING AND JOINING ACS DEMOGRAPHIC DATA
def GetACS(): 
    import re
    import urllib2
    import pandas as pd
    print "Getting demographic data from American Community Survey"
    medianhhs_inc=[]
    race_tot= []
    white=[]
    black=[]
    asian=[]
    multiracial=[]
    hispnonhisp_total=[]
    hispanic=[]
    familyhhs_tot=[]
    childrenhhs=[]
    totalpop25up=[]
    total25upBachelors=[]
    total25upGraduate=[]
    Zip_list = []
    url= 'http://api.census.gov/data/2013/acs5/profile?get=DP03_0062E,DP05_0028E,DP05_0032E,DP05_0033E,DP05_0039E,DP05_0053E,DP05_0065E,DP05_0066E,DP02_0001E,DP02_0003E,DP02_0058E,DP02_0064E,DP02_0065E&for=zip+code+tabulation+area:*&in=state:*&key='+ censusAPI    
    html = urllib2.urlopen(url).read()
    records = re.findall('\["([0-9]*)","([0-9]*)","([0-9]*)","([0-9]*)","([0-9]*)","([0-9]*)","([0-9]*)","([0-9]*)","([0-9]*)","([0-9]*)","([0-9]*)","([0-9]*)","([0-9]*)","([0-9]*)"\]',html)
    for record in records:
        medianhhs_inc.append(record[0])
        race_tot.append(record[1])
        white.append(record[2])
        black.append(record[3])
        asian.append(record[4])
        multiracial.append(record[5])
        hispnonhisp_total.append(record[6])
        hispanic.append(record[7])
        familyhhs_tot.append(record[8])
        childrenhhs.append(record[9])
        totalpop25up.append(record[10])
        total25upBachelors.append(record[11])
        total25upGraduate.append(record[12])
        Zip_list.append(record[13])
    
    
    d = {
            'medhhsincome': medianhhs_inc,
            'racetot': race_tot,
            'white': white,
            'black': black,
            'asian': asian,
            'multirace': multiracial,
            'hispreporters':hispnonhisp_total,
            'hispanic': hispanic,
            'familyhhs': familyhhs_tot,
            'households_children': childrenhhs,
            'tot25plus': totalpop25up,
            'bachelors':total25upBachelors,
            'graduate': total25upGraduate,
            'zip': Zip_list,
        } 
    
    #changing variable types to integer
    ACSdata = pd.DataFrame(data=d)
    ACSdata[['white']] = ACSdata[['white']].astype(int)
    ACSdata[['black']] = ACSdata[['black']].astype(int)
    ACSdata[['asian']] = ACSdata[['asian']].astype(int)
    ACSdata[['multirace']] = ACSdata[['multirace']].astype(int)
    ACSdata[['racetot']] = ACSdata[['racetot']].astype(int)
    ACSdata[['bachelors']] = ACSdata[['bachelors']].astype(int)
    ACSdata[['graduate']] = ACSdata[['graduate']].astype(int)
    ACSdata[['tot25plus']] = ACSdata[['tot25plus']].astype(int)
    ACSdata[['hispanic']] = ACSdata[['hispanic']].astype(int)
    ACSdata[['hispreporters']] = ACSdata[['hispreporters']].astype(int)
    ACSdata[['households_children']] = ACSdata[['households_children']].astype(int)
    ACSdata[['familyhhs']] = ACSdata[['familyhhs']].astype(int)
    
    #creating percentages
    ACSdata['percwhite']=ACSdata['white']/ACSdata['racetot']
    ACSdata['percblack']=ACSdata['black']/ACSdata['racetot']
    ACSdata['percasian']=ACSdata['asian']/ACSdata['racetot']
    ACSdata['percmultirace']=ACSdata['multirace']/ACSdata['racetot']
    ACSdata['percchildren']=ACSdata['households_children']/ACSdata['familyhhs']
    ACSdata['percbachelors']=ACSdata['bachelors']/ACSdata['tot25plus']
    ACSdata['percgraddegree']=ACSdata['graduate']/ACSdata['tot25plus']
    ACSdata['perchispanic']=ACSdata['hispanic']/ACSdata['hispreporters']
    
    #removing superflous columns
    ACSdata=ACSdata[['medhhsincome','zip','percwhite','percblack','percasian','percmultirace','percchildren','percbachelors','percgraddegree','perchispanic']]
    
    ACSdata.to_pickle('ACS/ACSdata.pk')


def JoinACS():
    import pandas as pd
    ACSdata = pd.read_pickle('ACS/ACSdata.pk') 
    
    #merging into master data
    CombinedData= pd.read_pickle('zipSS_IRS_Beds_Gas_ff_towers_daycare_CVS_zillow.pk')
    CombinedData['CodeInd2'] = CombinedData.index
    CombinedData['zip']=CombinedData["zipCode"]
    CombinedData=CombinedData.set_index('zip')
    ACSdata=ACSdata.set_index('zip')
    final= CombinedData.join(ACSdata, how='left')
    final=final.set_index('CodeInd2')
    final.to_csv('PracticumData_NoPR4.csv')
    

##RUNNING FUNCTIONS (can skip functions pulling data to use versions on computer)
FIPS = GetFIPSdata()
Census = GetCensusData(FIPS)
GetSSdata()
SSjoin = SS_CensusJoin(Census)
GetIRSdata()
IRS_CensusJoin(SSjoin)
HospBeds()
HospJoin()
GetGasStations()
GasJoin()
GetFastFood()
FastFoodJoin()
GetTowers()
TowersJoin()
GetDayCare()
DayCareJoin()
GetCVS()
JoinCVS()
GetHousing()
JoinHousing()
GetACS()
JoinACS()
