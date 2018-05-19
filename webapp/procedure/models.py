import datetime
from django.db import models

class RunParameters(models.Model):
    id = models.IntegerField(primary_key=True)
    run_date = models.DateTimeField('Date of run')
    used_surveygizmo = models.BooleanField('Did you use the SurzeyGizmo survey?', default=False)
    number_iterations = models.IntegerField('Number of iterations', default=100, help_text='The number of team placements that will be attempted. 10,000 or more is recommended.')
    prevent_roommates = models.BooleanField('Prevent roommates from serving on the same team?', default=True)
    consider_HS_elig = models.BooleanField('Consider High School eligibility?', default=True, help_text='ACMs are HS-eligible if they are 21+ years old (or have college experience) and are confident tutoring at least algebra-level math.')
    calc_commutes = models.BooleanField('Calcute commutes?', default=False, help_text='If you already calculated commutes in a previous run, it is not necessary to re-calculate unless you have added new ACMs or schools.')
    API_Key = models.CharField('Google API Key', blank=True, max_length=100, help_text='Required if calculating commutes.')
    commute_date = models.DateField('Travel date for commute calculations', blank=True, default=datetime.date.today, help_text='Required if calculating commutes. Choose a date that represents normal traffic.')
    commute_factor = models.IntegerField('Importance of commute', default=0, help_text='Only set greater than zero if you are calculating commutes or have already calculated commutes in a previous run.')
    ethnicity_factor = models.IntegerField('Importance of ethnic diversity', default=0)
    gender_factor = models.IntegerField('Importance of gender diversity', default=0)
    Edscore_factor = models.IntegerField('Importance of educational attainment diversity', default=0)

# class Document(models.Model):
#     document = models.FileField(upload_to='documents/')
#     uploaded_at = models.DateTimeField(auto_now_add=True)

# class Placments(models.Model):
#     tutor =
#     school =

## Down the line... (not mvp)
# Celery: kick tasks off to celery workers like a task queue (look into rabbitmq, redis)
