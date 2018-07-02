import pandas as pd

def rename_headers(survey_data_path):
    acm_df = pd.read_csv(survey_data_path)
    vars_df = pd.read_excel("Survey Items to Variable Names.xlsx")

    # trim whitespace from headers
    acm_df.columns = acm_df.columns.str.strip()
    vars_df['SurveyGizmo Column Name'] = vars_df['SurveyGizmo Column Name'].str.strip()

    rename_dict = dict(zip(vars_df['SurveyGizmo Column Name'], vars_df['Expected Column Name']))
    acm_df.rename(columns=rename_dict, inplace=True)

    missing_cols = [x for x in vars_df.loc[vars_df['Required?'] == 'Required', 'Expected Column Name'] if x not in acm_df.columns]
    for x in missing_cols:
        acm_df[x] = ''

    cols = [x for x in acm_df.columns if x in vars_df['Expected Column Name'].tolist()]
    acm_df[cols].to_csv(survey_data_path, index=False)

    return missing_cols