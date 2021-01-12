from convert_acq_data import acq_to_text

filenames = ['E016_IAPS_pre_stress.acq',
             'E024C_IAPS_pre_stress',
             'E163_IAPS_pre_stress',
             'E194_IAPS_pre_stress',
             'E273_IAPS_pre_stress',
             'E604_IAPS_pre_stress',
             'E606_IAPS_pre',
             'E607_IAPS_pre_stress',
             'E907_IAPS_pre_stress',
             'E917_IAPS_pre_stress']

for file in filenames:
    print("Working on file " + file)
    acq_to_text('/Users/juusu53/Documents/projects/femg/data/raw',file, '/Users/juusu53/Documents/projects/femg/data/preprocessed')

print('done with conversion')

