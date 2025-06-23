import pandas as pd
data = pd.read_csv('MD99-2334_age-model.tab',skiprows=19,sep='\t')
data['Age dated [ka]']=data['Age dated [ka]']*1000
data['Age dated std dev [±]']=data['Age dated std dev [±]']*1000
data['Age model [ka]']=data['Age model [ka]']*1000
data['Age e [±]']=data['Age e [±]']*1000
data = data.rename({'Age dated [ka]': 'Age dated [yr]'}, axis=1)
data = data.rename({'Age model [ka]': 'Age model [yr]'}, axis=1)
data.to_csv('age-model.csv',index=False)
