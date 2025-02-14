import pandas as pd 

ip = {'id':[1,2,3],
      'name':['peter', 'james', 'samuel']}
df = pd.DataFrame(ip)
print(f'{df.shape} - job completed')
