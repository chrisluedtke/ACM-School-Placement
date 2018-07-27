from django import forms
from .models import RunParameters

class RunParametersForm(forms.ModelForm):
    class Meta:
        model = RunParameters
        fields = [
            'number_iterations',
            'prevent_roommates',
            'consider_HS_elig',
            'calc_commutes',
            'commute_date',
            'commutes_reference',
            'commute_factor',
            'ethnicity_factor',
            'gender_factor',
            'Edscore_factor',
            'Spanish_factor',
        ]
