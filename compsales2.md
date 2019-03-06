The previous file [compsales.md](compsales.md) ended with us having a dataset which was a joined one from Zillow
and Redfin, as a table named `compsales1` in SQL, and dataframes named `comps` in Python Pandas and and `compsales` R.
(see also the ipython/jupyter notebook [CompSales.ipynb](CompSales.ipynb) for the python part only)
```python
print(comps[:5])
```
Here's the data
```text
                  Address      Sold  BR   BA    Lot  YearBuilt Zestimate  \
0   9306 RHODE ISLAND Ave  $279,945   4  2.0  7,248       1986       NaN   
1            9727 51st Pl  $334,000   4  2.0  5,501       1950  $335,092   
2            9010 50th Pl  $303,000   4  1.5  5,597       1973  $301,068   
3  9702 Narragansett Pkwy  $325,000   4  2.5  5,928       1964  $330,824   
4        5007 Iroquois St  $285,000   3  2.0  5,000       1961  $293,851   

     Sold_r   SQFT  DateSold RedFinEstimate InWorksheet  
0  $279,945  1,232  10/26/18       $374,424           N  
1  $334,000  1,176   1/28/19       $347,308           N  
2  $303,000  1,180  11/23/18       $328,600           N  
3  $325,000  1,078    6/8/18       $362,718           N  
4  $285,000  1,760  10/29/18       $368,991           N  
```
Now convert things to numbers and booleans. Let's start with the currencies. We could replace '$' and ',' with the empty string '' in a consecutive operations. Let's try on the first element. In python indexing starts with 0, so first element has index 0
```python
print(comps.Sold[0])
print(comps.Sold[0].replace('$',''))
print(comps.Sold[0].replace('$','').replace(',',''))
```
```text
$279,945
279,945
279945
```
It works but it's more convenient to use regular expressions, which you have probably either used or saw in Sololearn, for that
```python
import re
print(re.sub(r'[$,]','',comps.Sold[0]))
```
```text
'279945'
```
The regular expression meeans "either $ or ,". Another possibility would be `'[^0-9]'` or equivalent `'[^\d]'`. Which means "anything that's not a digit". 
We also need to convert the result it to `int` type.
```python
int(re.sub(r'[^0-9]','',comps.Sold[0]))
```
```text
279945
```
Now we need to apply this to each element of the column. Sometimes in python you can call a function directly on the whole column. That works for some functions and some arguments, especially, lists and numpy arrays. But in this case we need to apply the same function (i.e. `re.sub(....)`) to every element of the column. In programming, this is called mapping operation, since you map one array/vector/list/column to another one, using the same mapping function for each element. Standard python way to to that is to use [`map`](http://book.pythontips.com/en/latest/map_filter.html) function (also [official doc](https://docs.python.org/3/library/functions.html#map)), but pandas has `apply` function [just for that](https://pandas.pydata.org/pandas-docs/stable/reference/api/pandas.DataFrame.apply.html). We make use of anonymous functions, or [lambdas](https://www.w3schools.com/python/python_lambda.asp), which I saw introduced in SoloLearn pretty early.
```python
print(comps.Sold.apply(lambda x: int(re.sub(r'[$,]', '', x))))
```
```text
0     279945
1     334000
2     303000
3     325000
4     285000
5     360000
6     298000
7     319000
8     345000
9     295000
10    359000
11    315000
12    346609
13    300000
14    377000
15    345000
16    285000
17    320000
18    305000
19    290000
20    299900
21    299000
Name: Sold, dtype: int64
```

The syntax of `.apply(f)` means "apply function f to each element", or, "for each element `x` return `f(x)`". We could have defined `f(x)` as a regular python function, but used anonymous for convenience: `f(x)` is `lambda x: int(re.sub(r'[$,]', '', x)`
The standard function would have been
```python
def f(x):
    return int(re.sub(r'[$,]', '', x)
```
after which we would have called `comps.Sold.apply(f)`

So, let's convert all columns as we need. Create a new dataframe for it.
We add conversion to string before applying 're.sub" since pandas reads NaN directly as not-a-number values, and then convert sting not-a-number back to math.nan, and convert to real number (float)

```python
import math
comps1 = pd.DataFrame()
for colname in ['Sold', 'Sold_r', 'Zestimate', 'RedFinEstimate', 'SQFT', 'Lot', 'BR', 'BA', 'YearBuilt']:
    comps1[colname] = comps[colname].apply(lambda x: re.sub(r'[$,]', '', str(x)))
    comps1[colname] = comps1[colname].apply(lambda x: math.nan if x=='nan' else float(x))

comps1['Address'] = comps.Address
comps1['InWorksheet'] = comps.InWorksheet.apply(lambda x: True if x=='Y' else False)
```

```text
        Sold    Sold_r  Zestimate  RedFinEstimate    SQFT      Lot   BR   BA  \
0   279945.0  279945.0        NaN        374424.0  1232.0   7248.0  4.0  2.0   
1   334000.0  334000.0   335092.0        347308.0  1176.0   5501.0  4.0  2.0   
2   303000.0  303000.0   301068.0        328600.0  1180.0   5597.0  4.0  1.5   
3   325000.0  325000.0   330824.0        362718.0  1078.0   5928.0  4.0  2.5   
4   285000.0  285000.0   293851.0        368991.0  1760.0   5000.0  3.0  2.0   
5   360000.0  360000.0   350331.0        377555.0  1247.0   7575.0  6.0  3.5   
6   298000.0  298000.0   299344.0        346241.0   716.0   5030.0  3.0  2.0   
7   319000.0  319000.0   322248.0        327307.0  1232.0   7548.0  3.0  2.0   
8   345000.0  345000.0   374496.0        377983.0  2246.0   5951.0  3.0  3.0   
9   295000.0  295000.0   313414.0        364472.0  1248.0   6573.0  5.0  2.0   
10  359000.0  359000.0   333680.0        358237.0  1601.0   5279.0  4.0  2.0   
11  315000.0  315000.0        NaN        317426.0  1280.0   6250.0  3.0  1.5   
12  346609.0  346609.0   346609.0        349965.0  1650.0   6385.0  3.0  2.0   
13  300000.0  300000.0   337267.0        340746.0  1920.0  11761.0  3.0  2.0   
14  377000.0  377000.0   336089.0        375051.0  1822.0   5000.0  3.0  2.0   
15  345000.0  345000.0   325574.0        349965.0  1514.0   6098.0  3.0  2.0   
16  285000.0  285000.0   290023.0        301606.0   896.0   5227.0  3.0  1.0   
17  320000.0  320000.0   327522.0        342751.0   945.0   6886.0  5.0  2.0   
18  305000.0  305000.0   323356.0        343445.0  1680.0   5000.0  5.0  2.0   
19  290000.0  290000.0   297552.0        306017.0  1080.0   9648.0  3.0  1.0   
20  299900.0  299900.0   306275.0        360797.0  1248.0   7500.0  3.0  2.0   
21  299000.0  299000.0   305375.0        316713.0  1325.0   6520.0  3.0  1.5   

    YearBuilt                 Address  InWorksheet  
0      1986.0   9306 RHODE ISLAND Ave        False  
1      1950.0            9727 51st Pl        False  
2      1973.0            9010 50th Pl        False  
3      1964.0  9702 Narragansett Pkwy        False  
4      1961.0        5007 Iroquois St        False  
5      1949.0        5105 Iroquois St        False  
6      1945.0           9109 49th Ave        False  
7      1983.0           9501 49th Ave        False  
8      1946.0             4818 Fox St        False  
9      1935.0          5017 Indian Ln        False  
10     1952.0            5002 Cree Ln        False  
11     1934.0          5004 Apache St        False  
12     1936.0       4711 Hollywood Rd        False  
13     1963.0          4908 Indian Ln         True  
14     1907.0           5005 Huron St         True  
15     1954.0   9430 Rhode Island Ave         True  
16     1954.0           9606 52nd Ave         True  
17     1956.0        5106 Iroquois St         True  
18     1946.0            5009 Erie St         True  
19     1955.0   9202 Rhode Island Ave         True  
20     1932.0        5008 Iroquois St         True  
21     1892.0           9400 52nd ave         True  
```

Check that Sold prices are the same. = sign is all and well since we know that prices were integer initially, but for floating point numbers, 'equal' really means that absolute value of the difference is less than a very small number. Or we can sum those if we want a single number/bool to look at.

```python
print(comps1.Sold==comps1.Sold_r)
print(abs(comps1.Sold-comps1.Sold_r)<1e-7)
print("Sum: ", sum(abs(comps1.Sold-comps1.Sold_r)))
```
```text
0     True
1     True
2     True
3     True
4     True
5     True
6     True
7     True
8     True
9     True
10    True
11    True
12    True
13    True
14    True
15    True
16    True
17    True
18    True
19    True
20    True
21    True
dtype: bool
0     True
1     True
2     True
3     True
4     True
5     True
6     True
7     True
8     True
9     True
10    True
11    True
12    True
13    True
14    True
15    True
16    True
17    True
18    True
19    True
20    True
21    True
dtype: bool
Sum:  0.0
```
```python
print(comps1.RedFinEstimate - comps1.Zestimate)
```
```text
0         NaN
1     12216.0
2     27532.0
3     31894.0
4     75140.0
5     27224.0
6     46897.0
7      5059.0
8      3487.0
9     51058.0
10    24557.0
11        NaN
12     3356.0
13     3479.0
14    38962.0
15    24391.0
16    11583.0
17    15229.0
18    20089.0
19     8465.0
20    54522.0
21    11338.0
dtype: float64
```

We see that RedFin estimate is ALWAYS higher. Let's see which one is closer to the actual sale.
```python
comps1['RFDev'] = comps1.RedFinEstimate - comps1.Sold
comps1['ZDev'] = comps1.Zestimate - comps1.Sold
comps1[['Sold','RFDev','ZDev']]
```
```text
        Sold    RFDev     ZDev
0   279945.0  94479.0      NaN
1   334000.0  13308.0   1092.0
2   303000.0  25600.0  -1932.0
3   325000.0  37718.0   5824.0
4   285000.0  83991.0   8851.0
5   360000.0  17555.0  -9669.0
6   298000.0  48241.0   1344.0
7   319000.0   8307.0   3248.0
8   345000.0  32983.0  29496.0
9   295000.0  69472.0  18414.0
10  359000.0   -763.0 -25320.0
11  315000.0   2426.0      NaN
12  346609.0   3356.0      0.0
13  300000.0  40746.0  37267.0
14  377000.0  -1949.0 -40911.0
15  345000.0   4965.0 -19426.0
16  285000.0  16606.0   5023.0
17  320000.0  22751.0   7522.0
18  305000.0  38445.0  18356.0
19  290000.0  16017.0   7552.0
20  299900.0  60897.0   6375.0
21  299000.0  17713.0   6375.0
```
```python
print(f"Mean Zillow miss: {abs(comps1['ZDev']).mean()}, mean RedFin miss {abs(comps1['RFDev']).mean()}")
```
```text
Mean Zillow miss: 12699.85, mean RedFin miss 29922.18181818182
```

In R, some of these operations might be less tedious. You can do regexp substitution without applying an anonymous
mapping function to all elements, but just giving your column as argument to `gsub`
First element (R indexing starts with 1)
```R
gsub('[$,]','',compsales$Sold)[1]
```
```text
"279945"
```
```R
gsub('[$,]','',compsales$Sold)
```
```text
[1] "279945" "334000" "303000" "325000" "285000" "360000" "285000" "298000" "319000" "345000" "295000" "359000"
[13] "315000" "346609" "300000" "377000" "345000" "285000" "320000" "305000" "290000" "299900" "299000"
```
It also deals with 'NA'/'NaN' more automatically.
Here's full code for R to get a dataframe with all numeric entries
```R
library(dplyr)
zillow = read.csv("zillowcomps.csv")
redfin = read.csv("redfincomps.csv")
compsales = left_join(zillow, redfin, by="Address")
compsales = compsales %>%
  mutate(Zestimate=Estimate.x, RedfinEstimate=Estimate.y, Sold=Sold.x, SoldR=Sold.y) %>%
  select(c('Address','Sold','BR','BA','Lot','YearBuilt','Zestimate','SoldR','SQFT','DateSold','RedfinEstimate','InWorksheet'))
for (colname in c('Sold', 'SoldR', 'SQFT', 'Lot', 'Zestimate', 'RedfinEstimate', 'BR', 'BA', 'YearBuilt')) {
  compsales[[colname]] <- as.numeric(gsub('[^0-9]', '', compsales[[colname]]))
}
print(head(compsales))
```
The operations for comparisons are similar, `compsales$Sold == compsales$SoldR` or equivalent `compsales[['Sold']] == compsales[['SoldR']]`,
as is finding mean misses of both sites:
```R
compsales$ZDev = abs(compsales$Zestimate-compsales$Sold)
compsales$RFDev = abs(compsales$RedfinEstimate-compsales$Sold)
print(paste("Z miss:", mean(compsales$ZDev, na.rm = TRUE)))
print(paste("RedFin miss:", mean(compsales$RFDev, na.rm = TRUE)))
```
output:
```text
[1] "Z miss: 12699.85"
[1] "RedFin miss: 29922.1818181818"
```

Here's the pull python code from the beginning to the dataframe with all numeric entries converted to numeric format
```python
import pandas as pd
import re
import math

zillow = pd.read_csv('zillowcomps.csv')
redfin = pd.read_csv('redfincomps.csv') 
comps = zillow.join(redfin.set_index("Address"), on="Address", rsuffix="_r")
comps = comps[['Address','Sold','BR','BA','Lot','YearBuilt','Estimate','Sold_r','SQFT','DateSold','Estimate_r','InWorksheet']]
comps = comps.rename(index=str, columns = {"Estimate":"Zestimate", "Estimate_r":"RedFinEstimate"})
comps1 = pd.DataFrame()
for colname in ['Sold', 'Sold_r', 'Zestimate', 'RedFinEstimate', 'SQFT', 'Lot', 'BR', 'BA', 'YearBuilt']:
    comps1[colname] = comps[colname].apply(lambda x: re.sub(r'[^\d]', '', str(x)))
    comps1[colname] = comps1[colname].apply(lambda x: math.nan if x=='' else float(x))

comps1['Address'] = comps.Address
comps1['InWorksheet'] = comps.InWorksheet.apply(lambda x: True if x=='Y' else False)
```

Let's look at SQL
```sql
SELECT REPLACE(REPLACE(Sold,'$',''),',','') FROM compsales1 LIMIT 5;
```
```text
279945
334000
303000
325000
285000
```
Some SQL servers support regular expressions, but not SQLite, which I have, at least not without installing
some add-ons. And it looks like they support regex matching, but not simple substitution which we want here.
So it's going to be something like this:

```sql
CREATE TABLE compsales2 AS
    SELECT 
        CAST(REPLACE(REPLACE(Sold,'$',''),',','') AS REAL) AS Sold,
        CAST(REPLACE(REPLACE(RedfinSold,'$',''),',','') AS REAL) AS RedfinSold,
        CAST(REPLACE(REPLACE(Zestimate,'$',''),',','') AS REAL) AS Zestimate,
        CAST(REPLACE(REPLACE(RedFinEstimate,'$',''),',','') AS REAL) AS RedFinEstimate,
        CAST(REPLACE(REPLACE(SQFT,'$',''),',','') AS REAL) AS SQFT,
        CAST(REPLACE(REPLACE(YearBuilt,'$',''),',','') AS REAL) AS YearBuilt,
        CAST(REPLACE(REPLACE(BR,'$',''),',','') AS REAL) AS BR,
        CAST(REPLACE(REPLACE(BA,'$',''),',','') AS REAL) AS BA,
        Address,
        InWorksheet
    FROM compsales1 

SELECT * FROM compsales2 LIMIT 5;
```

```text
279945.0,279945.0,0.0,374424.0,1232.0,1986.0,4.0,2.0
334000.0,334000.0,335092.0,347308.0,1176.0,1950.0,4.0,2.0
303000.0,303000.0,301068.0,328600.0,1180.0,1973.0,4.0,1.5
325000.0,325000.0,330824.0,362718.0,1078.0,1964.0,4.0,2.5
285000.0,285000.0,293851.0,368991.0,1760.0,1961.0,3.0,2.0
```

```sql
sqlite> .schema compsales2
CREATE TABLE compsales2(
  Sold REAL,
  RedfinSold REAL,
  Zestimate REAL,
  RedFinEstimate REAL,
  SQFT REAL,
  YearBuilt REAL,
  BR REAL,
  BA REAL,
  Address TEXT,
  InWorksheet TEXT
);
```
(Apparently, SQLite doesn't have IF and has something else instead, like CASE, but I don't want to bother and figure it out
for this illustration so left "InWorksheet" field as a string rather than converting to BOOLEAN).

