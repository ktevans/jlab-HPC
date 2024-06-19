# ------------------------------------------------------------------------- #
# This is a multi-purpose utility script. For instance, it contains methods #
# to create job summary files for SIMC and g4sbs jobs.                      #
# ---------                                                                 #
# P. Datta <pdbforce@jlab.org> CREATED 04-20-2023                           #
# ---------                                                                 #
# ** Do not tamper with this sticker! Log any updates to the script above.  #
# ------------------------------------------------------------------------- #

import re
import sys

error_code = -9999

def read_file(infile):
    '''Reads a file and returns a list'''
    lines = []
    with open(infile, 'r') as f:
        lines = f.readlines()
    return lines

def write_file(list_of_data, outfile):
    '''Writes the content of a list to a file'''
    with open(outfile, 'w') as f:
        f.write(''.join(list_of_data));

def get_job_id(infile):
    '''Returns job id from a given input file.
       Naming convention: *_job_<jobid>.<extention>'''
    # handing non-standard file name
    if "_job_" not in infile: return error_code 
    regex = r"_job_(\d+)\.\w+"
    return re.findall(regex, infile)[0]

def grab_simc_param_value(infile, param):
    '''Grabs the value of a chosen parameter from SIMC infile'''
    lines = read_file(infile)
    value = error_code
    for line in lines:
        if param in line:
            temp = line.split(";", 1)[0]
            value = temp.split("=", 1)[1].strip()
    return value

def strip_path(filewpath):
    '''Strips the path to the directory or file'''
    lpos = filewpath.strip('/').rfind('/')
    return filewpath[lpos+1:]

def read_simc_histfile(histfile):
    '''Reads SIMC hist file and returns a dictionary'''
    result = {}
    regex = r"\s+([A-Za-z\s{0,1}\(\)/_\.>]+)\s+=\s+([0-9E?\+?\.-]+)"
    lines = read_file(histfile)
    for line in lines:
        if 'GeV^2' not in line:
            temp = re.findall(regex, line)
            if temp: result[temp[0][0].strip()] = temp[0][1]
    return result

def grab_simc_norm_factors(histfile, is_title):
    '''Grabs important normalization factors from SIMC .hist file'''
    titles = ['jobid', 'Nthrown', 'Ntried', 'genvol(MeV*sr^2)', 'luminosity(ub^-1)', 'ebeam(GeV)', 'charge(mC)', 'RndmSeed', 'UsingRS', 'MaxWtRS(ub/MeV/sr2)', 'wtGTmaxwt', 'ObsMaxWtRS']
    params = ['Ngen (request)', 'Ntried', 'genvol', 'luminosity', 'Ebeam', 'charge', 'Random Seed', 'Using RS', 'Chosen max wt (max_weight_RS)', 'No. events with wt>max_wt_RS', 'Observed max wt'] 
    if int(is_title) != 1:
        values = []
        values.append(get_job_id(histfile))
        flags = read_simc_histfile(histfile)
        for item in params: values.append(flags.get(item,0))
        return ','.join(str(e) for e in values)
    else: 
        return ','.join(str(e) for e in titles)

def read_g4sbs_csvfile(csvfile):
    '''Reads g4sbs CSV file and returns a dictionary'''
    result = {}
    regex = r"(.*),(.*)"
    lines = read_file(csvfile)
    for line in lines: 
        temp = re.findall(regex, line)
        if temp: result[temp[0][0]] = temp[0][1]
    return result

def grab_g4sbs_norm_factors(csvfile, is_title):
    '''Grabs important normalization factors from g4sbs .csv file'''
    titles = ['jobid', 'Nthrown', 'Ntried', 'genvol(sr)', 'luminosity(s^-1cm^-2)', 'ebeam(GeV)', 'ibeam(muA)']
    params = ['N_generated', 'N_tries', 'Generation_Volume', 'Luminosity_s-1_cm-2', 'Beam_Energy_GeV', 'Beam_Current_muA']
    if int(is_title) != 1:
        values = []
        values.append(get_job_id(csvfile))
        flags = read_g4sbs_csvfile(csvfile)
        for item in params: values.append(flags[item])
        return ','.join(str(e) for e in values)
    else: 
        return ','.join(str(e) for e in titles)

def remove_duplicates(infile):
    '''Removes adjacent duplicate lines. Will use to clean up root_hist'''
    outfile = infile + '_temp'
    ndotq = []
    ulines = []
    lines = read_file(infile)
    for line in lines:
        if ".q" not in line:
            ndotq.append(line)
    for l in range(len(ndotq)):
        if (l == 0): ulines.append(ndotq[l])
        elif ndotq[l-1] != ndotq[l]:
            ulines.append(ndotq[l])
    write_file(ulines, outfile)

def main(*arg):
    '''Calls the function of choice depending on its name'''
    if arg[0] == 'grab_simc_param_value':
        print(grab_simc_param_value(arg[1], arg[2]))
    elif arg[0] == 'grab_simc_norm_factors':
        print(grab_simc_norm_factors(arg[1], arg[2]))
    elif arg[0] == 'grab_g4sbs_norm_factors':
        print(grab_g4sbs_norm_factors(arg[1], arg[2]))
    elif arg[0] == 'remove_duplicates':
        print(remove_duplicates(arg[1]))

if __name__== "__main__":
    main(*sys.argv[1:])

