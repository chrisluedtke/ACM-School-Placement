from django import forms
from .models import RunParameters

class RunParametersForm(forms.ModelForm):
    class Meta:
        model = RunParameters
        fields = (
        'used_surveygizmo',
        'number_iterations',
        'prevent_roommates',
        'consider_HS_elig',
        'consider_commutes',
        'commute_factor',
        'ethnicity_factor',
        'gender_factor',
        'Edscore_factor',
        )
