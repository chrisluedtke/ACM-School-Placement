# Generated by Django 2.0.4 on 2018-04-26 00:59

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('procedure', '0005_remove_document_description'),
    ]

    operations = [
        migrations.DeleteModel(
            name='Document',
        ),
        migrations.AddField(
            model_name='runparameters',
            name='Edscore_factor',
            field=models.IntegerField(default=0, verbose_name='Importance of educational attainment diversity'),
        ),
        migrations.AddField(
            model_name='runparameters',
            name='commute_factor',
            field=models.IntegerField(default=0, verbose_name='Importance of commute'),
        ),
        migrations.AddField(
            model_name='runparameters',
            name='consider_HS_elig',
            field=models.BooleanField(default=True, verbose_name='Consider High School eligibility?'),
        ),
        migrations.AddField(
            model_name='runparameters',
            name='ethnicity_factor',
            field=models.IntegerField(default=0, verbose_name='Importance of ethnic diversity'),
        ),
        migrations.AddField(
            model_name='runparameters',
            name='gender_factor',
            field=models.IntegerField(default=0, verbose_name='Importance of gender diversity'),
        ),
    ]
