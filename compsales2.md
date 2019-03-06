The previous file [compsales.md](compsales.md) ended with us having a dataset which was a joined one from Zillow
and Redfin, as a table named `compsales1` in SQL, and dataframes named `comps` in Python Pandas and R.
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
Now convert things to numbers and booleans. Let's start with the currencies. We could replace '$' and ',' with the empty string '' in a consecutive operations. Let's try on the first element.
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
And then convert it to `int` type
```python
int(re.sub(r'[$,]','',comps.Sold[0]))
```
```text
279945
```