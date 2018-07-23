import datetime
import csv
import os
import pandas as pd
import shutil

from .cleaning import *
from .commutes import *
from django.conf import settings
from django.core.files.storage import FileSystemStorage
from django.http import HttpResponseRedirect, HttpResponse
from django.shortcuts import render, reverse
from django.utils import timezone
from .forms import RunParametersForm
from .models import RunParameters

outputs_dir = os.path.join(settings.MEDIA_ROOT, "documents/outputs")
plcmt_path = os.path.join(outputs_dir, "Output_Placements.csv")
trace_path = os.path.join(outputs_dir, "Output_Trace.csv")
commute_path = os.path.join(outputs_dir, "Output_Commute_Reference.csv")
error_path = os.path.join(outputs_dir, "errors.txt")
rm8_path = os.path.join(outputs_dir, "nvalid Roommate and Prior Relationship Names.csv")
zip_path = os.path.join(outputs_dir, "ACM_Placement_Result.zip")

inputs_dir = os.path.join(settings.MEDIA_ROOT, "documents/inputs")
params_path = os.path.join(inputs_dir, "params.csv")
survey_data_path = os.path.join(inputs_dir, "ACM_Placement_Survey_Data.csv")
school_data_path = os.path.join(inputs_dir, "ACM_Placement_School_Data.xlsx")
school_data_csv_path = os.path.join(inputs_dir, "ACM_Placement_School_Data.csv")

templates_dir = os.path.join(settings.MEDIA_ROOT, "documents/templates")
dashboard_template_path = os.path.join(templates_dir, "ACM_Placement_Dashboard.pbit")
school_data_template_path = os.path.join(templates_dir, "ACM_Placement_School_Data.xlsx")

dir_to_zip = os.path.join(settings.MEDIA_ROOT, "documents/to_zip")

def clear_dir(folder):
    for file in os.listdir(folder):
        file_path = os.path.join(folder, file)
        if os.path.isfile(file_path):
            os.remove(file_path)

def reset_files():
    clear_dir(inputs_dir)
    clear_dir(outputs_dir)
    clear_dir(dir_to_zip)

def write_output_zip():
    # save school data as csv
    school_df = pd.read_excel(school_data_path)
    school_df.to_csv(school_data_csv_path, index=False)

    for file in [plcmt_path, trace_path, commute_path, school_data_csv_path]:
        if os.path.exists(file):
            dst = os.path.join(dir_to_zip, os.path.basename(file))
            if os.path.exists(dst):
                os.remove(dst)
            shutil.copy(file, dst)
    shutil.make_archive(os.path.splitext(zip_path)[0], 'zip', dir_to_zip)

# Views begin here
def welcome(request):
    return render(request, 'procedure/welcome.html')

def step1(request):
    reset_files()

    # user download school data template
    if request.method == 'POST' and 'download' in request.POST:
        with open(school_data_template_path, 'rb') as fh:
            response = HttpResponse(fh.read(), content_type="application/vnd.ms-excel")
            response['Content-Disposition'] = 'inline; filename=' + os.path.basename(school_data_template_path)
            return response

    # user upload school data template
    if request.method == 'POST' and 'upload' in request.POST and 'myfile' in request.FILES and '.xlsx' in request.FILES['myfile'].name:
        filename = FileSystemStorage().save(school_data_path, request.FILES['myfile'])
        return HttpResponseRedirect(reverse('step2'))

    return render(request, 'procedure/step1.html', {})

def step2(request):
    if os.path.exists(survey_data_path):
        os.remove(survey_data_path)
    # Upload and clean ACM data
    if request.method == 'POST' and 'upload' in request.POST and 'myfile' in request.FILES and '.csv' in request.FILES['myfile'].name:
        filename = FileSystemStorage().save(survey_data_path, request.FILES['myfile'])
        missing_cols = clean_acm_df(survey_data_path)
        if missing_cols:
            return render(request, 'procedure/oops.html', {'error_list': ['Warning: the following columns could not be resolved from your survey file. These columns will be filled with blanks if you choose to continue:']+missing_cols, 'continue':True, 'continue_to':'step3'})
        else:
            return HttpResponseRedirect(reverse('step3'))
    return render(request, 'procedure/step2.html', {})

def step3(request):
    # Save Options
    if request.method == 'POST' and 'save' in request.POST:
        form = RunParametersForm(request.POST, request.FILES)
        if form.is_valid():
            params = form.save(commit=False)
            params.run_date = timezone.now()
            # If commutes uploaded, over-ride calc_commutes
            if params.commutes_reference.name:
                params.calc_commutes = False
            if not params.commutes_reference.name and params.calc_commutes == False:
                params.commute_factor = 0
            params.save()

            # Write parameters to csv
            params_fields = params._meta.get_fields()
            field_list = [field.name for field in params_fields]
            value_list = [str(getattr(params, field.name)) for field in params_fields]
            with open(params_path,'w', newline='') as f:
                w = csv.writer(f)
                w.writerow(field_list)
                w.writerow(value_list)

            # place Output_Commute_Reference.csv
            if params.commutes_reference.name and (os.path.normpath(params.commutes_reference.path) != os.path.normpath(commute_path)):
                if os.path.exists(commute_path):
                    os.remove(commute_path)
                os.rename(params.commutes_reference.path, commute_path)
            return HttpResponseRedirect(reverse('run'))
    else:
        form = RunParametersForm()
    return render(request, 'procedure/step3.html', {'form': form})

def run(request):
    # TODO: fails for certain encoding (like ANSI encoding with certain characters)
    acm_df = pd.read_csv(survey_data_path)
    school_df = pd.read_excel(school_data_path)

    n_acms = len(acm_df)
    n_schools = len(school_df)

    params = RunParameters.objects.last()

    run_time = 12 # in seconds, base time required for 1 iteration and no commutes
    run_time += params.number_iterations/4.38 # 4.38 iterations per second
    if params.calc_commutes == True:
        n_acm_addresses = len(acm_df.loc[~acm_df['Home_Address'].isnull() & (acm_df['Home_Address'] != '')])

        and_text = ' and calculating commutes'
        and_cost_text = ' and cost HQ '
        and_cost = f'${round(n_acm_addresses * n_schools * 0.005, 2)}'

        run_time += (n_acm_addresses*n_schools)/1.73 # 1.73 API requests per second
    else:
        and_text, and_cost_text, and_cost = '', '', ''

    run_time_mins = round(run_time/60, 1)

    if request.method == 'POST' and 'run' in request.POST:
        return HttpResponseRedirect(reverse('dash'))

    return render(request, 'procedure/run.html', {'n_acms': n_acms, 'n_schools': n_schools, 'run_time_mins':run_time_mins, 'and_text':and_text, 'and_cost_text':and_cost_text, 'and_cost':and_cost})

def wait(request):
    #TODO: display progress
    return render(request, 'procedure/wait.html', {})

def dash(request):
    # user download zip placements
    if request.method == 'POST' and 'download_results' in request.POST:
        if os.path.exists(zip_path):
            response = HttpResponse(open(zip_path, 'rb').read(), content_type='application/x-zip-compressed')
            response['Content-Disposition'] = 'attachment; filename="%s"' % os.path.split(zip_path)[-1]
            return response

    # user download power bi template
    if request.method == 'POST' and 'download_powerbi' in request.POST:
        if os.path.exists(dashboard_template_path):
            response = HttpResponse(open(dashboard_template_path, 'rb').read(), content_type='application/force-download')
            response['Content-Disposition'] = 'attachment; filename="%s"' % os.path.split(dashboard_template_path)[-1]
            return response

    # Run Placement Process
    start_time = datetime.datetime.now()
    params = RunParameters.objects.last()
    # acm_df cleaned on upload
    # commutes in python:
    if params.calc_commutes == True:
        api = open('gdm_api_key.txt').readline()
        try:
            commute_schl_df = clean_commute_inputs(survey_data_path, school_data_path, api, params.commute_date.strftime("%Y-%m-%d"))
        except Exception as e:
            return render(request, 'procedure/oops.html', {'error_list': [str(e)], 'continue':False})

        try:
            commute_procedure(commute_schl_df, api, commute_path)
        except Exception as e:
            return render(request, 'procedure/oops.html', {'error_list': [str(e)], 'continue':False})

    # algorithm in R:
    os.system(f'Rscript --no-restore --no-save launch_alg.R > {error_path} 2>&1')
    run_time=round((datetime.datetime.now()-start_time).seconds/60, 1)
    # check for errors
    error_list = []
    with open(error_path) as error_text:
        for line in error_text:
            if line not in ['[[1]]\n', '[1] TRUE\n']:
                error_list.append(line)
    if 'execution halted' in str(error_list).lower():
        return render(request, 'procedure/oops.html', {'error_list': error_list, 'continue':False, 'commute_ref_present':os.path.exists(commute_path)})
    else:
        write_output_zip()
        return render(request, 'procedure/dash.html', {'commute_ref_present':os.path.exists(commute_path), 'run_time':run_time})

def oops(request):
    # download commutes
    if request.method == 'POST' and 'download_commutes' in request.POST:
        if os.path.exists(commute_path):
            with open(commute_path, 'rb') as fh:
                response = HttpResponse(fh.read(), content_type="application/vnd.ms-excel")
                response['Content-Disposition'] = 'inline; filename=' + os.path.basename(commute_path)
                return response
    return render(request, 'procedure/oops.html', {})
