from django.db import models

class RunParameters(models.Model):
    id = models.IntegerField(primary_key=True)
    run_date = models.DateTimeField('Date of run')
    used_surveygizmo = models.BooleanField('Did you use the nation-wide survey?', default=False)
    number_iterations = models.IntegerField('How many iterations?', default=100)
    prevent_roommates = models.BooleanField('Prevent roommates from serving on the same team?', default=True)
    consider_HS_elig = models.BooleanField('Consider High School eligibility?', default=True)
    calc_commutes = models.BooleanField('Calcute commute times? If you already calculated commutes in a previous run, re-calculating is not necessary.', default=False)
    API_Key = models.CharField('Google API Key (required to calculate commutes)', default='', max_length=100)
    commute_factor = models.IntegerField('Importance of commute', default=0)
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