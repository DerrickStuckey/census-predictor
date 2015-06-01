# -*- coding: utf-8 -*-
"""
Created on Fri Feb 20 07:00:51 2015

@author: Jillian
"""

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



##PART III: DOWNLOADING SS DATA 
def GetSSdata():
    print "Pulling SS data"
    import urllib2
    #downloading file with SS recipients by zip code
    fileUrl = 'http://www.ssa.gov/policy/docs/statcomps/oasdi_zip/2010/oasdi_zip10.xlsx'
    f = urllib2.urlopen(fileUrl)
    data = f.read()
    with open('SS/SS.2010_zip.xlsx', 'wb') as w:
        w.write(data)

##PART IV: JOINING SS WITH CENSUS DATA
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
        df = df.iloc[:,[1,3]]        
        df["2010.SSrecip"] = df.iloc[:,[1]]
        df["zipCode"] = df.iloc[:,[0]]
        df = df.iloc[:,[2,3]]   #all rows and only columns 1 and 9         
        names = []
        for name in xls.sheet_names:
            names.append(name)
        df["names"] = names[x]
        SSbyZip = SSbyZip.append(df, ignore_index=True)
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
    combined2010.to_csv('zipSS.csv')    
    return combined2010

##Part V: PULLING IRS TAX DATA   
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

##PART VI: JOINING IRS DATA TO MASTER DATASET 
def IRS_CensusJoin(COMB2010):
    import pandas as pd
    #pulling in relevant columns and rows from IRS data and prep for join with master data
    IRSdf = pd.DataFrame.from_csv("IRS/10zpallnoagi.csv", header=1, index_col=None)
    IRSdf = IRSdf.iloc[:,[0,2,4]]
    #creating columns with uniform name
    IRSdf['IRS_rtrns'] = IRSdf.iloc[:,2]
    IRSdf = IRSdf[IRSdf.IRS_rtrns != 0]
    IRSdf['fips'] = IRSdf.iloc[:,0]
    IRSdf['zipCode']=IRSdf.iloc[:,1]
    #Getting rid of no-named columns
    IRSdf = IRSdf.iloc[:,[3,4,5]]
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
    combined2010.to_csv('zipSS_IRS.csv')
    combined2010.to_pickle('zipSS_IRS.pk')
    return combined2010

##Part VII: PULLING HOSPITAL BED DATA
def HospBeds():
    ahd_username = 'labate'
    ahd_pword = 'georgewashington'
    
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
    #(a maximum of 750 records can be downloaded at once)
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
        
    HospitalData.to_csv('Hospitals/CombinedHospitalData.csv')
    HospitalData.to_pickle('Hospitals/CombinedHospitalData.pk')

##Part VIII: JOINING HOSPITAL BED DATA TO DATASET
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
    CombinedData2.to_csv('CombinedZipFile.csv')
    CombinedData2.to_pickle('zipSS_IRS_Beds.pk')

##Part IX: PULLING GAS STATION DATA
def GetGasStations():
    from bs4 import BeautifulSoup
    import urllib2
    import os
    import pandas as pd
    import time
    
    os.chdir('C:/Users/Jillian/Documents/GWU/practicum')
    
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
        print "zip code + ", zipCode
        print "stations = ", len(stations2)
        time.sleep(2)
    
    d = {'zipCode': zc, 'gasStations': totalStations}
    stations = pd.DataFrame(d)
    stations.to_pickle('GasStations/stations.pk')
    stations.to_csv('GasStations/stations.csv')

##Part X: JOINING GAS STATION DATA TO MASTER SET
def GasJoin():
    import pandas as pd
    #note: gas stations are by zip, across state where necessary (i.e., where a zip is in 2 states,
    #the number repeats)    
    CombinedData = pd.read_pickle('zipSS_IRS_Beds.pk')
    CombinedData.zipCode= CombinedData.zipCode.astype(int)
    CombinedData["zipCode"] =CombinedData.zipCode.map("{:05}".format)
    stations = pd.read_pickle('GasStations/stations.pk')
    stations2 = stations.drop_duplicates()
    stations2 = stations2.set_index('zipCode')
    CombinedData['index'] = CombinedData['zipCode']
    CombinedZip = CombinedData.reset_index('index')
    CombinedZip = CombinedZip.set_index('index')
    Combined = CombinedZip.join(stations2, how='left')
    Combined = Combined.set_index('CodeInd2')
    Combined.to_csv('zipSS_IRS_Beds_Gas.csv')
    Combined.to_pickle('zipSS_IRS_Beds_Gas.pk')

##Part XI: GETTING FAST FOOD RESTAURANTS
def GetFastFood():
    import urllib
    import zipfile
    import shutil
    import os
    
    os.chdir('C:/Users/Jillian/Documents/GWU/practicum')
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

##Part XII: JOINING FAST FOOD DATA TO MASTER
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
    comb_ff.to_csv('zipSS_IRS_Beds_Gas_FF.csv')
    comb_ff.to_pickle('zipSS_IRS_Beds_Gas_FF.pk')

##Part XIII: GETTING DATA ON NUMBER OF FCC REGISTERED ANTENNA STRUCTURES
def GetTowers():
    import os
    from selenium import webdriver
    import time
    import pandas as pd
    import re
    
    os.chdir('C:/Users/Jillian/Documents/GWU/practicum')
    
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
    
    #entering pulling zips from master data
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
    #saving results as a data frame and csv
    d = {'zipCode': zipCode, 'towers': towers}
    towerDF = pd.DataFrame(d)
    towerDF.to_pickle('CellTowers/cellTowers.pk')
    towerDF.to_csv('CellTowers/cellTowers.csv')

##Part XIV: JOINING ANTENNA RESULTS TO MASTER
def TowersJoin():
    import pandas as pd
    #note: data is by zip, across state where necessary (i.e., where a zip is in 2 states,
    #the number repeats)    
    CombinedData = pd.read_pickle('zipSS_IRS_Beds_Gas_ff.pk')
    towers = pd.DataFrame.from_csv('CellTowers/cellTowers_all.csv')
    towers.zipCode= towers.zipCode.astype(int)
    towers["zipCode"] =towers.zipCode.map("{:05}".format)
    towers2 = towers.drop_duplicates()
    towers2 = towers2.set_index('zipCode')
    CombinedData['index'] = CombinedData['zipCode']
    CombinedZip = CombinedData.reset_index('index')
    CombinedZip = CombinedZip.set_index('index')
    Combined = CombinedZip.join(towers2, how='left')
    Combined = Combined.rename(columns={'level_0': 'CodeInd2'})
    Combined = Combined.set_index('CodeInd2')
    Combined.to_csv('zipSS_IRS_Beds_Gas_ff_towers.csv')
    Combined.to_pickle('zipSS_IRS_Beds_Gas_ff_towers.pk')

#Part XV: Pulling number of childcare centers and home daycare centers
def GetDayCare():
    import re
    import urllib2
    import os
    import pandas as pd
    
    os.chdir('C:/Users/Jillian/Documents/GWU/practicum')
    
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
        print url
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
    childCare.to_csv('Daycare/childCare.csv')

def DayCareJoin():
    import pandas as pd   
    CombinedData = pd.read_pickle('zipSS_IRS_Beds_Gas_ff_towers.pk')
    daycare = pd.DataFrame.from_csv('Daycare/childCare.csv')
    daycare=daycare[['careCenters','homeDaycare']]
    Combined = CombinedData.join(daycare, how='left')
    Combined.to_csv('zipSS_IRS_Beds_Gas_ff_towers_daycare.csv')
    Combined.to_pickle('zipSS_IRS_Beds_Gas_ff_towers_daycare.pk')
    
#running the functions (can skip functions pulling data to use versions on computer)
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
