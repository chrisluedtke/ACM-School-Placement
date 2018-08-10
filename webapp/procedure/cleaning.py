import pandas as pd
import numpy as np

def clean_acm_df(survey_data_path):
    acm_df = pd.read_csv(survey_data_path)
    vars_df = pd.read_excel("Survey Items to Variable Names.xlsx")

    # trim whitespace from headers
    acm_df.columns = acm_df.columns.str.strip()
    vars_df['SurveyGizmo Column Name'] = vars_df['SurveyGizmo Column Name'].str.strip()

    rename_dict = dict(zip(vars_df['SurveyGizmo Column Name'], vars_df['Expected Column Name']))
    acm_df.rename(columns=rename_dict, inplace=True)

    missing_cols = [x for x in vars_df.loc[vars_df['Required?'] == 'Required', 'Expected Column Name'] if x not in acm_df.columns]
    for x in missing_cols:
        acm_df[x] = np.nan

    acm_df['Res.Postal.Code'] = acm_df['Res.Postal.Code'].astype(str)
    acm_df.loc[acm_df['Res.Postal.Code']=='nan', 'Res.Postal.Code'] = np.nan
    acm_df['Res.Address.Line.1'] = acm_df['Res.Address.Line.1'].str.upper().str.split('#|APT|UNIT', 1).str[0]
    acm_df['Home_Address'] = acm_df[['Res.Address.Line.1','Res.City','Res.State', 'Res.Postal.Code']].apply(lambda x: x.str.cat(sep=' '), axis=1)

    #cols = [x for x in acm_df.columns if x in vars_df['Expected Column Name'].tolist() + ['Home_Address']]
    #acm_df[cols].to_csv(survey_data_path, index=False)
    acm_df.to_csv(survey_data_path, index=False)

    return missing_cols
