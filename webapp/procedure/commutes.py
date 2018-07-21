import pandas as pd
import datetime
import requests

def clean_commute_inputs(survey_data_path, school_data_path, commute_date):
    acm_df = pd.read_csv(survey_data_path)
    school_df = pd.read_excel(school_data_path)

    acm_df['acm_id'] = range(1, len(acm_df)+1)
    acm_df['Home_Address'] = acm_df[['Res.Address.Line.1','Res.City','Res.State', 'Res.Postal.Code']].apply(lambda x: x.str.cat(sep=' '), axis=1)

    school_df['sch_id'] = range(1, len(school_df)+1)
    school_df.rename(columns={'Address': 'School_Address'}, inplace=True)

    school_df['ArrivalTime'] = commute_date + ' ' + school_df['ACM Start Time (Eastern Time)'].str.replace('AM', '').str.replace('A M', '').str.replace('A.M.', '')
    school_df['ArrivalTime'] = pd.to_datetime(school_df['ArrivalTime'])
    school_df['ArrivalTime'] = school_df['ArrivalTime'].dt.tz_localize('US/Eastern').dt.tz_convert('GMT').dt.tz_convert(None)
    school_df['ArrivalTime'] = (school_df['ArrivalTime']-datetime.datetime(1970,1,1)).astype('timedelta64[s]').astype(int)
    # subtract 3 mins to arrive on time
    school_df['ArrivalTime'] = school_df['ArrivalTime'] - 180

    acm_df['Travel.Method'].fillna('', inplace=True)
    acm_df.loc[acm_df['Travel.Method'].str.lower().str.contains('driving'), 'Travel.Method'] = "driving"
    acm_df.loc[~acm_df['Travel.Method'].str.lower().str.contains('driving'), 'Travel.Method'] = "transit"

    return acm_df, school_df

def gmapsdistance(origin, destination, mode, arrival_time, api):
    url = f"https://maps.googleapis.com/maps/api/distancematrix/json?origins={origin}&destinations={destination}&mode={mode}&units=imperial&arrival_time={arrival_time}&avoid=tolls&key={api}"

    response = requests.get(url, timeout=5)
    response_status = response.json()['status']

    commute_dict = {}

    if response_status == "OK":
        response_elems = response.json()['rows'][0]['elements'][0]
        commute_status = response_elems['status']
        if commute_status == "OK":
            commute_dict['Home.Address'] = response.json()['origin_addresses'][0]
            commute_dict['School.Address'] = response.json()['destination_addresses'][0]
            commute_dict['Distance.Miles'] = response_elems['distance']['value']/5280
            commute_dict['Time.Mins'] = response_elems['duration']['value']/60
            commute_dict['Status'] = commute_status
    else:
        commute_dict['Home.Address'] = origin
        commute_dict['School.Address'] = destination
        commute_dict['Distance.Miles'] = None
        commute_dict['Time.Mins'] = None
        commute_dict['Status'] = response_status

    return commute_dict

def commute_procedure(acm_df, school_df, api, commute_path):
    # Ensure each school address has a valid location according to Google
    school_df.fillna(value='', inplace=True)
    for index, row in school_df.iterrows():
        url = f"https://maps.googleapis.com/maps/api/geocode/json?address={row['School_Address']}&key={api}"
        response = requests.get(url, timeout=5)
        response_status = response.json()['status']

        if response_status != "OK":
            raise Exception(f"Error during commute calculation: while searching for {row['School']} (address: {row['School_Address']}), Google Maps returned: {response_status}.")

    acm_df = acm_df.loc[~acm_df['Home_Address'].isnull() & (acm_df['Home_Address'] != '')]

    acm_df['tmp'] = 1
    school_df['tmp'] = 1
    commute_schl_df = acm_df.merge(school_df, on ='tmp'); del commute_schl_df['tmp']

    commute_schl_df['id_dest'] = commute_schl_df['acm_id'].astype(str) + '_' + commute_schl_df['sch_id'].astype(str)

    commutes_list = []
    for index, row in commute_schl_df.iterrows():
        commute_result = gmapsdistance(origin = row['Home_Address'],
                                       destination = row['School_Address'],
                                       mode = row['Travel.Method'],
                                       arrival_time = str(row['ArrivalTime']),
                                       api = api)

#         if commute_result['Status'] == 'ROUTE_NOT_FOUND' and row['Travel.Method'] == 'transit':
#             # if no route found for transit, find driving distance, but keep the status. This is done so we have a loose idea of which schools are nearby.
#             commute_result = gmapsdistance(origin = row['AddressCleanQuery_acm'],
#                                            destination = row['AddressCleanQuery_school'],
#                                            mode = 'driving',
#                                            arrival_time = str(row['ArrivalTime']),
#                                            api = api)
#             commute_result['Status'] = 'ROUTE_NOT_FOUND'
        commute_result['id_dest'] = row['id_dest']
        commutes_list.append(commute_result)

    commutes_df = pd.DataFrame(commutes_list)
    commutes_df = commute_schl_df[['Full.Name', 'School', 'Travel.Method', 'id_dest']].merge(commutes_df, on='id_dest', how='right')
    del commutes_df['id_dest']

    commutes_df['Time.Mins'] = pd.to_numeric(commutes_df['Time.Mins'], errors='coerce')
    commutes_df['Rank'] = commutes_df.groupby('Full.Name')['Time.Mins'].rank()
    commutes_df.loc[commutes_df['Status'] != 'OK', 'Time.Mins'] = 999

    commutes_df[['Full.Name', 'School', 'Home.Address', 'School.Address', 'Travel.Method', 'Time.Mins', 'Distance.Miles', 'Rank', 'Status']].to_csv(commute_path, index=False)
