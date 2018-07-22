import datetime
from django.db import models

class RunParameters(models.Model):
    id = models.IntegerField(primary_key=True)
    run_date = models.DateTimeField('Date of run')
    number_iterations = models.IntegerField('Number of iterations', default=10000, help_text='The number of team placements that will be attempted. 10,000 or more is recommended.')
    prevent_roommates = models.BooleanField('Prevent roommates from serving on the same team?', default=True)
    consider_HS_elig = models.BooleanField('Apply High School eligibility rule?', default=True, help_text='ACMs are eligible to serve in High School if they are 21+ years old (or have college experience) and are confident tutoring at least algebra-level math.')
    # HS_elig_age = models.IntegerField('Minimum Age to Serve in High School', default=21)
    # HS_elig_ed = models.IntegerField('Minimum Education to Serve in High School', default=21)
    calc_commutes = models.BooleanField('Calculate commutes?', default=True, help_text="Commute calculations cost HQ a small amount and take time to complete. For 100 ACMs and 10 schools, the cost is $5 and takes about 10 minutes.")
    commute_date = models.DateField('Travel date for commute calculations', blank=True, default=(datetime.date.today() + datetime.timedelta(days=1)), help_text='Required if calculating commutes. Choose a date that represents normal traffic.')
    commutes_reference = models.FileField(upload_to='documents/outputs', blank=True, help_text="After placements are made, you can download a 'Output_Commute_Reference.csv' spreadsheet. If you want to run additional placement processes, upload that file here to avoid commute calculation wait time and cost.")
    ## FACTORS ##
    commute_factor = models.IntegerField('Importance of commute', default=1)
    ethnicity_factor = models.IntegerField('Importance of ethnic diversity', default=1)
    gender_factor = models.IntegerField('Importance of gender diversity', default=1)
    Edscore_factor = models.IntegerField('Importance of educational attainment diversity', default=1)

# class Document(models.Model):
#     document = models.FileField(upload_to='documents/')
#     uploaded_at = models.DateTimeField(auto_now_add=True)

# class Placments(models.Model):
#     tutor =
#     school =
