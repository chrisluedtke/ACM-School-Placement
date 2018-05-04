import csv
import os
from django.conf import settings
from django.core.files.storage import FileSystemStorage
from django.http import HttpResponseRedirect, HttpResponse
from django.shortcuts import render, reverse
from django.utils import timezone
from .forms import RunParametersForm
from .models import RunParameters
from openpyxl import load_workbook

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
    # Upload ACM data
    if request.method == 'POST' and 'upload' in request.POST:
        file_path = os.path.join(settings.MEDIA_ROOT, "documents/ACM_Placement_Survey_Data.csv")
        if os.path.exists(file_path):
            os.remove(file_path)
        filename = FileSystemStorage().save(file_path, request.FILES['myfile'])
        return HttpResponseRedirect(reverse('step3'))
    return render(request, 'procedure/step2.html', {})

def step3(request):
    # Save Options
    if request.method == 'POST' and 'save' in request.POST:
        form = RunParametersForm(request.POST)
        if form.is_valid():
            params = form.save(commit=False)
            params.run_date = timezone.now()
            params.save()

            # Write parameters to csv
            params = RunParameters.objects.last()
            params_fields = params._meta.get_fields()
            field_list = ','.join([field.name for field in params_fields])
            value_list = [getattr(params, field.name) for field in params_fields]
            value_list_str = ','.join([str(e) for e in value_list])

            with open('media/documents/params.csv', 'w') as file:
                file.write(field_list)
                file.write('\n')
                file.write(value_list_str)
                file.write('\n')
            # Alternatively, pass arguments to R script like:
            # os.system(f'Rscript launch_alg.R {value_list_str}')
            # either way, will need to explicitly set data types in R
            # https://www.r-bloggers.com/passing-arguments-to-an-r-script-from-command-lines/
            # TODO: load intermediate page (wait)
            return HttpResponseRedirect(reverse('run'))
    else:
        form = RunParametersForm()
    return render(request, 'procedure/step3.html', {'form': form})

def run(request):
    with open(os.path.join(settings.MEDIA_ROOT, 'documents/ACM_Placement_Survey_Data.csv'),"r") as f:
        reader = csv.reader(f,delimiter = ",")
        data = list(reader)
        n_acms = len(data)-1

    wb = load_workbook(os.path.join(settings.MEDIA_ROOT, 'documents/ACM_Placement_School_Data.xlsx'))
    sheet = wb.worksheets[0]
    n_schools = sheet.max_row

    params = RunParameters.objects.last()
    if params.calc_commutes == True:
        and_text = ' and calculating commutes'
    else:
        and_text = ''

    run_time = params.number_iterations/30 # filler: assumed 30 iterations per second
    if params.calc_commutes == True:
        run_time = run_time + n_acms*n_schools*0.5 # 0.5 seconds per API request
    run_time_mins = round(run_time/60, 0)

    if request.method == 'POST' and 'run' in request.POST:
        return HttpResponseRedirect(reverse('dash'))
    return render(request, 'procedure/run.html', {'n_acms': n_acms, 'n_schools': n_schools, 'run_time_mins':run_time_mins, 'and_text':and_text})

def wait(request):
    #TODO: display progress
    return render(request, 'procedure/wait.html', {})

def dash(request):
    # download placements
    if request.method == 'POST' and 'download' in request.POST:
        file_path = os.path.join(settings.MEDIA_ROOT, "documents/outputs/Output_Placements.csv")
        if os.path.exists(file_path):
            with open(file_path, 'rb') as fh:
                response = HttpResponse(fh.read(), content_type="application/vnd.ms-excel")
                response['Content-Disposition'] = 'inline; filename=' + os.path.basename(file_path)
                return response

    os.system('Rscript launch_alg.R')

    return render(request, 'procedure/dash.html', {})
