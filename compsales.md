The purpose of this writeup is to show similarities between operations on data in the shape of DataFrames/relational 
database tables, using SQL, Python or R. Essentially, thinking about it in terms of SQL queries is very helpful for
doing that in Python or R, but in those there are additional convenient tools as well. So the only thing to learn
is the syntax of particular commands, but it is well documented and is easily available on the Web, and easy to
forget anyway. So once you know the flow of the data operations, it doesn't really matter which tool to use,
it become a matter of convenience, availability and other considerations.

Imagine we have two SQL tables, showing sales of houses in neighborhood, `zillow` and `redfin`, based 
on Zillow and Redfin respectively. (In reality, I made them from the web for tax assessment appeal, in
a single Excel file, which I saved in csv and then split into two, for the purpose of this demonstration,
and then imported those files as tables in SQLite which I happened to have installed on my Mac some time ago,
I don't remember for what purpose).
```bash
sqlite> .import zillowcomps.csv zillow
sqlite> .import redfincomps.csv redfin
```

Zillow tables looks like 
```sql
sqlite> .schema zillow
CREATE TABLE zillow(
  "" TEXT,
  "Address" TEXT,
  "Sold" TEXT,
  "BR" TEXT,
  "BA" TEXT,
  "Lot" TEXT,
  "YearBuilt" TEXT,
  "Estimate" TEXT,
  "Link" TEXT
);
```
Redfin table looks like
```sql
sqlite> .schema redfin
CREATE TABLE redfin(
  "" TEXT,
  "Address" TEXT,
  "Sold" TEXT,
  "SQFT" TEXT,
  "DateSold" TEXT,
  "Estimate" TEXT,
  "Link" TEXT,
  "InWorksheet" TEXT
);
```
Since they have different fields/columns/variables, let's join them to have full information on each sale:
```sql
CREATE TABLE compsales AS
    SELECT * 
    FROM zillow 
    LEFT JOIN redfin 
    ON zillow.Address=redfin.Address;
```
Let's see what we got:
```sql
SELECT * FROM compsales LIMIT 5;
```
gives the output
```
0,"9306 RHODE ISLAND Ave","$279,945",4,2.0,"7,248",1986,"",https://www.zillow.com/homes/9306-rhode-island-ave_rb/,0,"9306 RHODE ISLAND Ave","$279,945","1,232",10/26/18,"$374,424",https://www.redfin.com/MD/College-Park/9306-Rhode-Island-Ave-20740/home/11098366,N
1,"9727 51st Pl","$334,000",4,2.0,"5,501",1950,"$335,092",https://www.zillow.com/homes/9727-51-pl_rb/,1,"9727 51st Pl","$334,000","1,176",1/28/19,"$347,308",https://www.redfin.com/MD/College-Park/9727-51st-Pl-20740/home/11089947,N
2,"9010 50th Pl","$303,000",4,1.5,"5,597",1973,"$301,068",https://www.zillow.com/homes/9010-50th-Pl_rb/,2,"9010 50th Pl","$303,000","1,180",11/23/18,"$328,600",https://www.redfin.com/MD/College-Park/9010-50th-Pl-20740/home/11081825,N
3,"9702 Narragansett Pkwy","$325,000",4,2.5,"5,928",1964,"$330,824",https://www.zillow.com/homes/9702-Narragansett-Pkwy_rb/,3,"9702 Narragansett Pkwy","$325,000","1,078",6/8/18,"$362,718",https://www.redfin.com/MD/College-Park/9702-Narragansett-Pkwy-20740/home/11099523,N
4,"5007 Iroquois St","$285,000",3,2.0,"5,000",1961,"$293,851",https://www.zillow.com/homedetails/5007-Iroquois-St-College-Park-MD-20740/37563783_zpid/?fullpage=true,4,"5007 Iroquois St","$285,000","1,760",10/29/18,"$368,991",https://www.redfin.com/MD/College-Park/5007-Iroquois-St-20740/home/11100773,N
```
And the schema is
```sql
sqlite> .schema compsales
CREATE TABLE compsales(
  "" TEXT,
  Address TEXT,
  Sold TEXT,
  BR TEXT,
  BA TEXT,
  Lot TEXT,
  YearBuilt TEXT,
  Estimate TEXT,
  Link TEXT,
  ":1" TEXT,
  "Address:1" TEXT,
  "Sold:1" TEXT,
  SQFT TEXT,
  DateSold TEXT,
  "Estimate:1" TEXT,
  "Link:1" TEXT,
  InWorksheet TEXT
);
```
We can select only the fields we need, while renaming along the way
```sql
CREATE TABLE compsales1 AS 
    SELECT 
        Address, Sold, BR, BA, YearBuilt, 
        Estimate AS Zestimate, "Sold:1" as RedfinSold, 
        SQFT, DateSold, "Estimate:1" AS RedFinEstimate, InWorksheet 
    FROM compsales;
```

In order to use any of that, we'll need to convert the numeric fields form text to int etc, but for now let's
see how to do the same things in Python.

In Python (and in R too), in this context operating with data like that, the main object/concept is the DataFrame.
DataFrame is essentially the same as table in SQL database: a 2D table with Rows (corresponding to records) and
columns (also known as fields or variables) that can be of any type (text, number, boolean etc.).
In Python, the most popular and the most supported package for operating the DataFrames is calles `Pandas`.
So the first thing we do is import it
```python
import pandas as pd
```
The `as pd` allows to use `pd` as shortcut further on, and in the case of `Pandas` it's conventional. I have
my data saved on the local disk as `zillowcomps.csv`
```python
zillow = pd.read_csv('zillowcomps.csv')
redfin = pd.read_csv('redfincomps.csv')    
```
Let's look at first 5 rows:
```python
print(zillow[:5])
```
yields the output:
```   
Unnamed: 0                 Address      Sold  BR   BA    Lot  YearBuilt  \
0           0   9306 RHODE ISLAND Ave  $279,945   4  2.0  7,248       1986   
1           1            9727 51st Pl  $334,000   4  2.0  5,501       1950   
2           2            9010 50th Pl  $303,000   4  1.5  5,597       1973   
3           3  9702 Narragansett Pkwy  $325,000   4  2.5  5,928       1964   
4           4        5007 Iroquois St  $285,000   3  2.0  5,000       1961   

   Estimate                                               Link  
0       NaN  https://www.zillow.com/homes/9306-rhode-island...  
1  $335,092        https://www.zillow.com/homes/9727-51-pl_rb/  
2  $301,068      https://www.zillow.com/homes/9010-50th-Pl_rb/  
3  $330,824  https://www.zillow.com/homes/9702-Narragansett...  
4  $293,851  https://www.zillow.com/homedetails/5007-Iroquo... 
```

The `print(zillow.columns)` and `print(redfin.columns)` give the following output:

```python
Index(['Unnamed: 0', 'Address', 'Sold', 'BR', 'BA', 'Lot', 'YearBuilt',
       'Estimate', 'Link'],
      dtype='object')
```
and
```python
Index(['Unnamed: 0', 'Address', 'Sold', 'SQFT', 'DateSold', 'Estimate', 'Link',
       'InWorksheet'],
      dtype='object')
```

So, to join, we do (and, of course, I did not remember it, and read it in Pandas manual on the 
page https://pandas.pydata.org/pandas-docs/stable/reference/api/pandas.DataFrame.join.html where I got 
by Googling "pandas join")

The code
```python
comps = zillow.join(redfin.set_index("Address"), on="Address", rsuffix="_r")
print(comps[:5])
```
creates new dataframe `comps` and prints its first 5 rows:
```
   Unnamed: 0                 Address      Sold  BR   BA    Lot  YearBuilt  \
0           0   9306 RHODE ISLAND Ave  $279,945   4  2.0  7,248       1986   
1           1            9727 51st Pl  $334,000   4  2.0  5,501       1950   
2           2            9010 50th Pl  $303,000   4  1.5  5,597       1973   
3           3  9702 Narragansett Pkwy  $325,000   4  2.5  5,928       1964   
4           4        5007 Iroquois St  $285,000   3  2.0  5,000       1961   

   Estimate                                               Link  Unnamed: 0_r  \
0       NaN  https://www.zillow.com/homes/9306-rhode-island...             0   
1  $335,092        https://www.zillow.com/homes/9727-51-pl_rb/             1   
2  $301,068      https://www.zillow.com/homes/9010-50th-Pl_rb/             2   
3  $330,824  https://www.zillow.com/homes/9702-Narragansett...             3   
4  $293,851  https://www.zillow.com/homedetails/5007-Iroquo...             4   

     Sold_r   SQFT  DateSold Estimate_r  \
0  $279,945  1,232  10/26/18   $374,424   
1  $334,000  1,176   1/28/19   $347,308   
2  $303,000  1,180  11/23/18   $328,600   
3  $325,000  1,078    6/8/18   $362,718   
4  $285,000  1,760  10/29/18   $368,991   

                                              Link_r InWorksheet  
0  https://www.redfin.com/MD/College-Park/9306-Rh...           N  
1  https://www.redfin.com/MD/College-Park/9727-51...           N  
2  https://www.redfin.com/MD/College-Park/9010-50...           N  
3  https://www.redfin.com/MD/College-Park/9702-Na...           N  
4  https://www.redfin.com/MD/College-Park/5007-Ir...           N
```

Selecting only columns that we need, and rename some (I looked up the renaming since I don't remember):
```python
comps = comps[['Address','Sold','BR','BA','Lot','YearBuilt','Estimate','Sold_r','SQFT','DateSold','Estimate_r','InWorksheet']]
comps = comps.rename(index=str, columns = {"Estimate":"Zestimate", "Estimate_r":"RedFinEstimate"})
```

Let's see:
```python
print(comps[:5])
```
Prints the following
```
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

R primarily operates with dataframes without any packages, but there are many to enchance or speed
up the functionality. My favorite (and as I understand, very popular) is called `dplyr`. It is said to
be essentially "parallel" to SQL in function. So, to do the same things: load the package, load the files and
look at them we do the following:

```R
library(dplyr)
zillow = read.csv("zillowcomps.csv")
redfin = read.csv("redfincomps.csv")
print(head(zillow))
print(head(redfin))
```

and get the following output

```
  X                Address     Sold BR  BA   Lot YearBuilt Estimate
1 0  9306 RHODE ISLAND Ave $279,945  4 2.0 7,248      1986         
2 1           9727 51st Pl $334,000  4 2.0 5,501      1950 $335,092
3 2           9010 50th Pl $303,000  4 1.5 5,597      1973 $301,068
4 3 9702 Narragansett Pkwy $325,000  4 2.5 5,928      1964 $330,824
5 4       5007 Iroquois St $285,000  3 2.0 5,000      1961 $293,851
6 5       5105 Iroquois St $360,000  6 3.5 7,575      1949 $350,331
                                                                                                    Link
1                                                 https://www.zillow.com/homes/9306-rhode-island-ave_rb/
2                                                            https://www.zillow.com/homes/9727-51-pl_rb/
3                                                          https://www.zillow.com/homes/9010-50th-Pl_rb/
4                                                https://www.zillow.com/homes/9702-Narragansett-Pkwy_rb/
5 https://www.zillow.com/homedetails/5007-Iroquois-St-College-Park-MD-20740/37563783_zpid/?fullpage=true
6 https://www.zillow.com/homedetails/5105-Iroquois-St-College-Park-MD-20740/37558718_zpid/?fullpage=true



  X                Address     Sold  SQFT DateSold Estimate
1 0  9306 RHODE ISLAND Ave $279,945 1,232 10/26/18 $374,424
2 1           9727 51st Pl $334,000 1,176  1/28/19 $347,308
3 2           9010 50th Pl $303,000 1,180 11/23/18 $328,600
4 3 9702 Narragansett Pkwy $325,000 1,078   6/8/18 $362,718
5 4       5007 Iroquois St $285,000 1,760 10/29/18 $368,991
6 5       5105 Iroquois St $360,000 1,247  1/29/19 $377,555
                                                                               Link InWorksheet
1  https://www.redfin.com/MD/College-Park/9306-Rhode-Island-Ave-20740/home/11098366           N
2           https://www.redfin.com/MD/College-Park/9727-51st-Pl-20740/home/11089947           N
3           https://www.redfin.com/MD/College-Park/9010-50th-Pl-20740/home/11081825           N
4 https://www.redfin.com/MD/College-Park/9702-Narragansett-Pkwy-20740/home/11099523           N
5       https://www.redfin.com/MD/College-Park/5007-Iroquois-St-20740/home/11100773           N
6       https://www.redfin.com/MD/College-Park/5105-Iroquois-St-20740/home/11085972           N
```

Let's join them (I looked up by gooling "dplyr join", but if I didn't know about the "dplyr", I'd
google "R join" or "R join dataframes" and would found documentation on `merge` function which does 
the same thing without needing to import `dplyr`)

```R
compsales = left_join(zillow, redfin, by="Address")
print(head(compsales))
```

Output
```
  X                Address     Sold BR  BA   Lot YearBuilt Estimate
1 0  9306 RHODE ISLAND Ave $279,945  4 2.0 7,248      1986         
2 1           9727 51st Pl $334,000  4 2.0 5,501      1950 $335,092
3 2           9010 50th Pl $303,000  4 1.5 5,597      1973 $301,068
4 3 9702 Narragansett Pkwy $325,000  4 2.5 5,928      1964 $330,824
5 4       5007 Iroquois St $285,000  3 2.0 5,000      1961 $293,851
6 5       5105 Iroquois St $360,000  6 3.5 7,575      1949 $350,331
                                                                                                    Link
1                                                 https://www.zillow.com/homes/9306-rhode-island-ave_rb/
2                                                            https://www.zillow.com/homes/9727-51-pl_rb/
3                                                          https://www.zillow.com/homes/9010-50th-Pl_rb/
4                                                https://www.zillow.com/homes/9702-Narragansett-Pkwy_rb/
5 https://www.zillow.com/homedetails/5007-Iroquois-St-College-Park-MD-20740/37563783_zpid/?fullpage=true
6 https://www.zillow.com/homedetails/5105-Iroquois-St-College-Park-MD-20740/37558718_zpid/?fullpage=true
  X                Address     Sold  SQFT DateSold Estimate
1 0  9306 RHODE ISLAND Ave $279,945 1,232 10/26/18 $374,424
2 1           9727 51st Pl $334,000 1,176  1/28/19 $347,308
3 2           9010 50th Pl $303,000 1,180 11/23/18 $328,600
4 3 9702 Narragansett Pkwy $325,000 1,078   6/8/18 $362,718
5 4       5007 Iroquois St $285,000 1,760 10/29/18 $368,991
6 5       5105 Iroquois St $360,000 1,247  1/29/19 $377,555
                                                                               Link InWorksheet
1  https://www.redfin.com/MD/College-Park/9306-Rhode-Island-Ave-20740/home/11098366           N
2           https://www.redfin.com/MD/College-Park/9727-51st-Pl-20740/home/11089947           N
3           https://www.redfin.com/MD/College-Park/9010-50th-Pl-20740/home/11081825           N
4 https://www.redfin.com/MD/College-Park/9702-Narragansett-Pkwy-20740/home/11099523           N
5       https://www.redfin.com/MD/College-Park/5007-Iroquois-St-20740/home/11100773           N
6       https://www.redfin.com/MD/College-Park/5105-Iroquois-St-20740/home/11085972           N
  X.x                Address   Sold.x BR  BA   Lot YearBuilt Estimate.x
1   0  9306 RHODE ISLAND Ave $279,945  4 2.0 7,248      1986           
2   1           9727 51st Pl $334,000  4 2.0 5,501      1950   $335,092
3   2           9010 50th Pl $303,000  4 1.5 5,597      1973   $301,068
4   3 9702 Narragansett Pkwy $325,000  4 2.5 5,928      1964   $330,824
5   4       5007 Iroquois St $285,000  3 2.0 5,000      1961   $293,851
6   5       5105 Iroquois St $360,000  6 3.5 7,575      1949   $350,331
                                                                                                  Link.x X.y   Sold.y  SQFT DateSold
1                                                 https://www.zillow.com/homes/9306-rhode-island-ave_rb/   0 $279,945 1,232 10/26/18
2                                                            https://www.zillow.com/homes/9727-51-pl_rb/   1 $334,000 1,176  1/28/19
3                                                          https://www.zillow.com/homes/9010-50th-Pl_rb/   2 $303,000 1,180 11/23/18
4                                                https://www.zillow.com/homes/9702-Narragansett-Pkwy_rb/   3 $325,000 1,078   6/8/18
5 https://www.zillow.com/homedetails/5007-Iroquois-St-College-Park-MD-20740/37563783_zpid/?fullpage=true   4 $285,000 1,760 10/29/18
6 https://www.zillow.com/homedetails/5105-Iroquois-St-College-Park-MD-20740/37558718_zpid/?fullpage=true   5 $360,000 1,247  1/29/19
  Estimate.y                                                                            Link.y InWorksheet
1   $374,424  https://www.redfin.com/MD/College-Park/9306-Rhode-Island-Ave-20740/home/11098366           N
2   $347,308           https://www.redfin.com/MD/College-Park/9727-51st-Pl-20740/home/11089947           N
3   $328,600           https://www.redfin.com/MD/College-Park/9010-50th-Pl-20740/home/11081825           N
4   $362,718 https://www.redfin.com/MD/College-Park/9702-Narragansett-Pkwy-20740/home/11099523           N
5   $368,991       https://www.redfin.com/MD/College-Park/5007-Iroquois-St-20740/home/11100773           N
6   $377,555       https://www.redfin.com/MD/College-Park/5105-Iroquois-St-20740/home/11085972           N
```
And then rename some columns and select only those we need:

```R
compsales = compsales %>%
  mutate(Zestimate=Estimate.x, RedfinEstimate=Estimate.y, Sold=Sold.x, SoldR=Sold.y) %>%
  select(c('Address','Sold','BR','BA','Lot','YearBuilt','Zestimate','SoldR','SQFT','DateSold','RedfinEstimate','InWorksheet'))
```

Output:
```
                 Address     Sold BR  BA   Lot YearBuilt Zestimate    SoldR  SQFT DateSold RedfinEstimate InWorksheet
1  9306 RHODE ISLAND Ave $279,945  4 2.0 7,248      1986           $279,945 1,232 10/26/18       $374,424           N
2           9727 51st Pl $334,000  4 2.0 5,501      1950  $335,092 $334,000 1,176  1/28/19       $347,308           N
3           9010 50th Pl $303,000  4 1.5 5,597      1973  $301,068 $303,000 1,180 11/23/18       $328,600           N
4 9702 Narragansett Pkwy $325,000  4 2.5 5,928      1964  $330,824 $325,000 1,078   6/8/18       $362,718           N
5       5007 Iroquois St $285,000  3 2.0 5,000      1961  $293,851 $285,000 1,760 10/29/18       $368,991           N
6       5105 Iroquois St $360,000  6 3.5 7,575      1949  $350,331 $360,000 1,247  1/29/19       $377,555           N
```

## TO BE CONTINUED!

Then I want to do some operations, like make sure that "Sold" price is the same from both data sets and then
compare Zestimates, RedFinEstimates and Sold price, and then maybe even do a linear regression and see what it
shows for the price of my house, so that I have more arguments for the tax assessor I have appointment with on
Thurdsay :)
