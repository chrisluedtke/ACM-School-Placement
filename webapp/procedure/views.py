from django.conf import settings
from django.core.files.storage import FileSystemStorage
from django.http import HttpResponseRedirect, HttpResponse
from django.shortcuts import render, reverse
from django.utils import timezone
import os
from .forms import RunParametersForm

# Create your views here.
def welcome(request):
    return render(request, 'procedure/welcome.html')

def step1(request):
    # download school data template
    if request.method == 'POST' and 'download' in request.POST:
        file_path = os.path.join(settings.MEDIA_ROOT, "documents/template/ACM_Placement_School_Data.xlsx")
        if os.path.exists(file_path):
            with open(file_path, 'rb') as fh:
                response = HttpResponse(fh.read(), content_type="application/vnd.ms-excel")
                response['Content-Disposition'] = 'inline; filename=' + os.path.basename(file_path)
                return response
    # upload school data template
    if request.method == 'POST' and 'upload' in request.POST:
        ## Method 1
        file_path = os.path.join(settings.MEDIA_ROOT, "documents/ACM_Placement_School_Data.xlsx")
        if os.path.exists(file_path):
            os.remove(file_path)
        filename = FileSystemStorage().save(file_path, request.FILES['myfile'])
        return HttpResponseRedirect(reverse('step2'))
    return render(request, 'procedure/step1.html', {})

def step2(request):
    if request.method == 'POST' and 'upload' in request.POST:
        file_path = os.path.join(settings.MEDIA_ROOT, "documents/ACM_Placement_Survey_Data.csv")
        if os.path.exists(file_path):
            os.remove(file_path)
        filename = FileSystemStorage().save(file_path, request.FILES['myfile'])
        return HttpResponseRedirect(reverse('step3'))
    return render(request, 'procedure/step2.html', {})

def step3(request):
    if request.method == 'POST' and 'run' in request.POST:
        form = RunParametersForm(request.POST)
        if form.is_valid():
            params = form.save(commit=False)
            params.run_date = timezone.now()
            params.save()
            # load intermediate page (wait)
            return HttpResponseRedirect(reverse('dash'))
    else:
        form = RunParametersForm()
    return render(request, 'procedure/step3.html', {'form': form})

def wait(request):
    # display progress
    return render(request, 'procedure/wait.html', {})

def dash(request):
    if request.method == 'POST' and 'download' in request.POST:
        file_path = os.path.join(settings.MEDIA_ROOT, "documents/outputs/Output_Placements.csv")
        if os.path.exists(file_path):
            with open(file_path, 'rb') as fh:
                response = HttpResponse(fh.read(), content_type="application/vnd.ms-excel")
                response['Content-Disposition'] = 'inline; filename=' + os.path.basename(file_path)
                return response

    # trigger algorithm with given parameters
    os.system('Rscript launch_alg.R')

    return render(request, 'procedure/dash.html', {})
