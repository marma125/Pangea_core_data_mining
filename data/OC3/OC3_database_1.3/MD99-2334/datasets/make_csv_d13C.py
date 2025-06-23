import pandas as pd
data = pd.read_csv('MD99-2334_d13C.tab',skiprows=13,sep='\t')
data['Age [ka BP]']=data['Age [ka BP]']*1000
data = data.rename({'Age [ka BP]': 'Age [yr BP]'}, axis=1)
data.to_csv('test.csv',index=False)

