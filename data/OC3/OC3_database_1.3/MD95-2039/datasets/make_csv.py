import pandas as pd
data = pd.read_csv('MD95-2039_d13C_C-wuell.tab',skiprows=15,sep='\t')
data['Age [ka BP]']=data['Age [ka BP]']*1000
data = data.rename({'Age [ka BP]': 'Age [yr BP]'}, axis=1)
data.to_csv('test.csv',index=False)

