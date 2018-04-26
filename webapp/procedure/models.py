from django.db import models

class RunParameters(models.Model):
    id = models.IntegerField(primary_key=True)
    run_date = models.DateTimeField('Date of run')
    national_survey = models.BooleanField('Did you use the nation-wide survey?', default=True)
    n_iterations = models.IntegerField('How many iterations?', default=1000)
    prevent_roommates = models.BooleanField('Prevent roommates from serving on the same team?', default=True)
    consider_HS_elig = models.BooleanField('Consider High School eligibility?', default=True)
    consider_commutes = models.BooleanField('Consider commute times?', default=False)
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
