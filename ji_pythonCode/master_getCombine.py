###This code downloads and combines 2010 data at the zip code level, including:
###census total population, state abbreviations, total SS recipients,
###total tax returns filed

##PART I: PULLING FILE WITH CENSUS FIPS CODES, STATE ABBREVIATIONS

def GetFIPSdata():
    import urllib2
    import pandas as pd
    print "Pulling FIPS data"
    URL = 'http://www2.census.gov/geo/docs/reference/codes/files/national_county.txt'
    html = urllib2.urlopen(URL).read()
    #saving the data as a text file
    testtext = open("FILELOCATION/FILENAME.txt", "w")
    print>>testtext, html
    
    #Making lists to hold the data for each variable and importing text file
    State = []
    StateFP = []
    CountyFP = []
    CountyName = []
    ClassFP = []
    
    results = []
    with open('FILELOCATION/FILENAME.txt') as inputfile:
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
    
    #Pulling census zip-code-level population data using those codes
    #and making into data frame
    BASE_URL = 'http://api.census.gov/data/2010/sf1?get=P0010001&for=zip+code+tabulation+area:*&in=state:'
    url_end = '&key=YOURKEY'
    
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
    fileUrl = 'FILEPATH/FILENAME.xlsx'
    f = urllib2.urlopen(fileUrl)
    data = f.read()
    with open('FILELOCATION/FILENAME.xlsx', 'wb') as w:
        w.write(data)

##PART IV: JOINING SS WITH CENSUS DATA
def SS_CensusJoin(PBZ2):
    import pandas as pd
    import us
    xls = pd.ExcelFile('FILELOCATION/FILENAME.xlsx')
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
    print SSbyZip2 
    pop3 = PBZ2
    combined2010 = pop3.join(SSbyZip2, how='left')
    combined2010.to_csv('FILELOCATION/FILENAME.csv')
    print combined2010    
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
    urllib.urlretrieve(fileUrl,"FILELOCATION/FILENAME.zip")
    #unzipping only needed file
    my_dir = r"FILELOCATION"
    my_zip = r"FILELOCATION/FILENAME.zip"
    
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
    IRSdf = pd.DataFrame.from_csv("FILEPATH/10zpallnoagi.csv", header=1, index_col=None)
    IRSdf = IRSdf.iloc[:,[0,2,4]]
    #creating columns with uniform name
    IRSdf['IRS_rtrns'] = IRSdf.iloc[:,2]
    IRSdf = IRSdf[IRSdf.IRS_rtrns != 0]
    IRSdf['fips'] = IRSdf.iloc[:,0]
    IRSdf["zipCode"]=IRSdf.iloc[:,1]
    print IRSdf
    #Getting rid of no-named columns
    IRSdf = IRSdf.iloc[:,[3,4,5]]
    IRSdf.zipCode = IRSdf.zipCode.astype(int)
    IRSdf["zipCode"] =IRSdf.zipCode.map("{:05}".format)
    IRSdf.zipCode = IRSdf.zipCode.astype(str)
    IRSdf.fips = IRSdf.fips.astype(int)
    IRSdf["fips"] =IRSdf.fips.map("{:02}".format)
    IRSdf.fips = IRSdf.fips.astype(str)
    IRSdf["index"] = "C" + IRSdf.apply(lambda x:'%s%s' % (x['fips'],x['zipCode']),axis=1)
    
    #Combining IRS data with census data
    IRSdf2 = IRSdf.set_index('index')
    IRSdf2 = IRSdf2.iloc[:,0]
    
    combined2010 = COMB2010.join(IRSdf2, how='left')
    combined2010.to_csv('FILEPATH/FILENAME.csv')
    return combined2010

FIPS = GetFIPSdata()
Census = GetCensusData(FIPS)
SS = GetSSdata()
SSjoin = SS_CensusJoin(Census)
IRS = GetIRSdata()
IRSjoin = IRS_CensusJoin(SSjoin)
print IRSjoin
