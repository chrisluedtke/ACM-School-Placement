from django import forms
from .models import RunParameters

class RunParametersForm(forms.ModelForm):
    class Meta:
        model = RunParameters
        fields = (
        'number_iterations',
        'used_surveygizmo',
        'prevent_roommates',
        'consider_HS_elig',
        'calc_commutes',
        'API_Key',
        'commute_factor',
        'ethnicity_factor',
        'gender_factor',
        'Edscore_factor',
        )
