import pandas as pd
data = pd.read_csv('MD95-2039_C-wuell_d13C_d18O.tab',skiprows=15,sep='\t')
data.to_csv('MD95-2039_C-wuell_d13C_d18O.csv',index=False)

