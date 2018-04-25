from django import forms
from .models import RunParameters

class RunParametersForm(forms.ModelForm):
    class Meta:
        model = RunParameters
        fields = ('national_survey','n_iterations','prevent_roommates','consider_commutes')
