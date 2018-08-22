# -*- coding: utf-8 -*-

import pandas as pd
import os


cwd = os.getcwd()
filename = 'ny_ev.csv'

ciap_gis = pd.read_csv(os.path.join(cwd, filename))

clean_data = ciap_gis.dropna()

df = pd.DataFrame( {'INCOME': clean_data['EST_INCOME'], 'ADULTS': clean_data['NUM_ADULTS'], 'CHILD': clean_data['NUM_CHILD'],
                    'VEH_PUR_INT': clean_data['VEHICLE_PURCHASE_INTENT'], 'EDU': clean_data['EDUCATION'], 'ASIAN': clean_data['ASN'],
                    'BLACK': clean_data['BLK'], 'WHITE': clean_data['WHT'], 'HISP': clean_data['HISP'],
                    'AMER_IND': clean_data['AMERIND'],'NUM_CARS': clean_data['NUM_CARS'],'SOLAR': clean_data['SOLAR'],
                    'HOMEVAL': clean_data['HOMEVAL'],'POP': clean_data['MA.POPULATION/10000'],
                    'POP_SQMI': clean_data['MA.POP_SQMI/1000'],'EV': clean_data['TOT_EV']})
writer = pd.ExcelWriter('train.xlsx', engine='openpyxl')
df.to_excel(writer, sheet_name='train')
writer.save()
 