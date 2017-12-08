# Datascraping
Wade  
December 7, 2017  

Goal: For this assignment I have decided to scrape data from a perfume/cologne database, fragrantica.com. On this website, users are able to review and rate perfumes as well as provide information about their scents. While I am not a perfume/cologne enthusiast, I think there will be a value to studying this database in the future because I am interested in how sensory products are marketed to consumers. For this assignment, I will narrow the dataset of interest to the products offered by a single brand, Chanel.

First, I'll load required packages:


```r
library(rvest)
```

```
## Warning: package 'rvest' was built under R version 3.3.3
```

```
## Loading required package: xml2
```

```
## Warning: package 'xml2' was built under R version 3.3.3
```

```r
library(tidyverse)
```

```
## Warning: package 'tidyverse' was built under R version 3.3.3
```

```
## Loading tidyverse: ggplot2
## Loading tidyverse: tibble
## Loading tidyverse: tidyr
## Loading tidyverse: readr
## Loading tidyverse: purrr
## Loading tidyverse: dplyr
```

```
## Warning: package 'ggplot2' was built under R version 3.3.3
```

```
## Warning: package 'tibble' was built under R version 3.3.2
```

```
## Warning: package 'tidyr' was built under R version 3.3.2
```

```
## Warning: package 'readr' was built under R version 3.3.3
```

```
## Warning: package 'purrr' was built under R version 3.3.3
```

```
## Warning: package 'dplyr' was built under R version 3.3.2
```

```
## Conflicts with tidy packages ----------------------------------------------
```

```
## filter(): dplyr, stats
## lag():    dplyr, stats
```

```r
library(purrr)
```

Next, I want to test my ability to pull information from a single webpage. Note that I used SelectorGadget, a Chrome extension, in order to pull the necessary tag from the webpage code.


```r
frag <- read_html("https://www.fragrantica.com/perfume/Chanel/Antaeus-616.html")
frag
```

```
## {xml_document}
## <html xmlns="http://www.w3.org/1999/xhtml" xml:lang="EN">
## [1] <head>\n<title>Antaeus Chanel cologne - a fragrance for men 1981</ti ...
## [2] <body oncopy="return false" oncut="return false">\n<div id="dialog-d ...
```

```r
name <- frag %>%
	html_node("h1 span") %>%
	html_text()
name
```

```
## [1] "Antaeus Chanel for men"
```

```r
scent <- frag %>% 
		#html_nodes("#prettyPhotoGallery div div+ div span") %>% 
		html_node("#prettyPhotoGallery div div:nth-child(2) span") %>%
		html_text()
	scent
```

```
## [1] "woody"
```

```r
rating <- frag %>% 
	html_node("#col1 div+ div p span:nth-child(1)") %>%
	html_text()
rating
```

```
## [1] "4.16"
```

```r
brand <- frag %>% 
	html_node("span a span") %>%
	html_text()
brand
```

```
## [1] "Chanel"
```

```r
description <- frag %>%
	html_node("#col1 div:nth-child(7) p") %>%
	html_text()
description
```

```
## [1] "Antaeus is the name of ancient Greek demigod. Strong, like a god, and gentle as a man, Antaeus belongs to those perfumes of expressed individuality and strong character which emphasize masculinity, what was a trend in 1980-ies. Myrtle and sage, lime and thyme have united to give the fragrance a special freshness and masculine character. The fragrance is warming up and becomes intensive at the end due to patchouli, sandal and labdanum in the base. Sharp animalistic nuance is brought in by the notes of castoreum and leather."
```

```r
print(data.frame(name, brand, scent, rating, description))
```

```
##                     name  brand scent rating
## 1 Antaeus Chanel for men Chanel woody   4.16
##                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        description
## 1 Antaeus is the name of ancient Greek demigod. Strong, like a god, and gentle as a man, Antaeus belongs to those perfumes of expressed individuality and strong character which emphasize masculinity, what was a trend in 1980-ies. Myrtle and sage, lime and thyme have united to give the fragrance a special freshness and masculine character. The fragrance is warming up and becomes intensive at the end due to patchouli, sandal and labdanum in the base. Sharp animalistic nuance is brought in by the notes of castoreum and leather.
```

This looks good! I have what I need to pull data from a single webpage on Fragrantica.com.

Now for the hard part: I've got to automate the process. Unfortunately, the URL for each individual perfume/cologne follows a random patter. It's not like I can just paste 1,2,3, etc. at the end of the URL. My plan is to create a list of URLs that I want to scrape data from. I can then reference this list of URLs in my scraping function.


```r
library(urltools)
```

```
## Warning: package 'urltools' was built under R version 3.3.3
```

```
## 
## Attaching package: 'urltools'
```

```
## The following object is masked from 'package:xml2':
## 
##     url_parse
```

urltools is a neat package I found that allows you to parse parts of a URL. 


```r
parsed <- url_parse("https://www.fragrantica.com/perfume/Chanel/Antaeus-616.html")
parsed
```

```
##   scheme              domain port                            path
## 1  https www.fragrantica.com <NA> perfume/Chanel/Antaeus-616.html
##   parameter fragment
## 1      <NA>     <NA>
```

```r
parsed$path
```

```
## [1] "perfume/Chanel/Antaeus-616.html"
```

This is the path that we need to view the Antaeus cologne by Chanel. We've got to find a way to pull a similar path from each of the Chanel links available, and then we can pipe these paths into a function.


```r
chanel_page <- read_html("https://www.fragrantica.com/designers/Chanel.html")
chanel_page
```

```
## {xml_document}
## <html xmlns="http://www.w3.org/1999/xhtml" xml:lang="EN">
## [1] <head>\n<title>Chanel Perfumes And Colognes</title>\n<meta http-equi ...
## [2] <body oncopy="return false" oncut="return false">\n<div id="dialog-d ...
```

```r
parse_test <- chanel_page %>%
	html_nodes(".plist a") %>%
	html_attr('href')
parse_test
```

```
##   [1] "/perfume/Chanel/Antaeus-616.html"                                     
##   [2] "/perfume/Chanel/Bois-Noir-34568.html"                                 
##   [3] "/perfume/Chanel/Chanel-No-46-22520.html"                              
##   [4] "/perfume/Chanel/Gabrielle-43718.html"                                 
##   [5] "/perfume/Chanel/Le-1940-Beige-de-Chanel-45188.html"                   
##   [6] "/perfume/Chanel/Le-1940-Bleu-de-Chanel-45187.html"                    
##   [7] "/perfume/Chanel/Le-1940-Rouge-de-Chanel-45186.html"                   
##   [8] "/perfume/Chanel/Une-Fleur-de-Chanel-4689.html"                        
##   [9] "/perfume/Chanel/Allure-502.html"                                      
##  [10] "/perfume/Chanel/Allure-eau-de-parfum-176.html"                        
##  [11] "/perfume/Chanel/Allure-Eau-Fraichissante-Pour-l-Ete-12448.html"       
##  [12] "/perfume/Chanel/Allure-Hair-Mist-46217.html"                          
##  [13] "/perfume/Chanel/Allure-Homme-Eau-Fraichissante-Pour-l-Ete-12447.html" 
##  [14] "/perfume/Chanel/Allure-Homme-Edition-Blanche-2653.html"               
##  [15] "/perfume/Chanel/Allure-Homme-Edition-Blanche-Eau-de-Parfum-28942.html"
##  [16] "/perfume/Chanel/Allure-Homme-Sport-607.html"                          
##  [17] "/perfume/Chanel/Allure-Homme-Sport-Cologne-Sport-1004.html"           
##  [18] "/perfume/Chanel/Allure-Homme-Sport-Eau-Extreme-14669.html"            
##  [19] "/perfume/Chanel/Allure-Parfum-33506.html"                             
##  [20] "/perfume/Chanel/Allure-Pour-Homme-523.html"                           
##  [21] "/perfume/Chanel/Allure-Sensuelle-606.html"                            
##  [22] "/perfume/Chanel/Allure-Sensuelle-Eau-de-Toilette-28682.html"          
##  [23] "/perfume/Chanel/Allure-Sensuelle-Parfum-28683.html"                   
##  [24] "/perfume/Chanel/Bleu-de-Chanel-9099.html"                             
##  [25] "/perfume/Chanel/Bleu-de-Chanel-Eau-de-Parfum-25967.html"              
##  [26] "/perfume/Chanel/Chance-Eau-de-Parfum-31351.html"                      
##  [27] "/perfume/Chanel/Chance-Eau-de-Toilette-610.html"                      
##  [28] "/perfume/Chanel/Chance-Eau-Fraiche-1483.html"                         
##  [29] "/perfume/Chanel/Chance-Eau-Fraiche-Hair-Mist-46214.html"              
##  [30] "/perfume/Chanel/Chance-Eau-Tendre-8069.html"                          
##  [31] "/perfume/Chanel/Chance-Eau-Tendre-Hair-Mist-46215.html"               
##  [32] "/perfume/Chanel/Chance-Eau-Vive-30796.html"                           
##  [33] "/perfume/Chanel/Chance-Eau-Vive-Hair-Mist-46216.html"                 
##  [34] "/perfume/Chanel/Chance-Hair-Mist-46213.html"                          
##  [35] "/perfume/Chanel/Chance-Parfum-31350.html"                             
##  [36] "/perfume/Chanel/Chanel-No-19-Eau-de-Parfum-12345.html"                
##  [37] "/perfume/Chanel/Chanel-No-19-Parfum-12346.html"                       
##  [38] "/perfume/Chanel/Chanel-No-19-Poudre-12424.html"                       
##  [39] "/perfume/Chanel/Chanel-N-19-11.html"                                  
##  [40] "/perfume/Chanel/Chanel-No-5-Eau-de-Cologne-11638.html"                
##  [41] "/perfume/Chanel/Chanel-No-5-Eau-de-Parfum-40069.html"                 
##  [42] "/perfume/Chanel/Chanel-No-5-Eau-de-Toilette-10856.html"               
##  [43] "/perfume/Chanel/Chanel-No-5-Eau-Premiere-2015--31172.html"            
##  [44] "/perfume/Chanel/Chanel-No-5-Hair-Mist-46212.html"                     
##  [45] "/perfume/Chanel/Chanel-No-5-L-Eau-38543.html"                         
##  [46] "/perfume/Chanel/Chanel-No-5-Parfum-28711.html"                        
##  [47] "/perfume/Chanel/Chanel-N-5-608.html"                                  
##  [48] "/perfume/Chanel/Chanel-N-5-Eau-Premiere-1360.html"                    
##  [49] "/perfume/Chanel/Chanel-N-5-Elixir-Sensuel-4687.html"                  
##  [50] "/perfume/Chanel/Coco-Eau-de-Parfum-609.html"                          
##  [51] "/perfume/Chanel/Coco-Eau-de-Toilette-31353.html"                      
##  [52] "/perfume/Chanel/Coco-Mademoiselle-611.html"                           
##  [53] "/perfume/Chanel/Coco-Mademoiselle-Eau-de-toilette-612.html"           
##  [54] "/perfume/Chanel/Coco-Mademoiselle-Hair-Mist-46211.html"               
##  [55] "/perfume/Chanel/Coco-Mademoiselle-L-Extrait-14957.html"               
##  [56] "/perfume/Chanel/Coco-Mademoiselle-Parfum-6928.html"                   
##  [57] "/perfume/Chanel/Coco-Noir-15963.html"                                 
##  [58] "/perfume/Chanel/Coco-Noir-Extrait-27496.html"                         
##  [59] "/perfume/Chanel/Coco-Parfum-31354.html"                               
##  [60] "/perfume/Chanel/Cristalle-Eau-de-Parfum-31352.html"                   
##  [61] "/perfume/Chanel/Cristalle-Eau-de-Toilette-12.html"                    
##  [62] "/perfume/Chanel/Cristalle-Eau-Verte-5909.html"                        
##  [63] "/perfume/Chanel/Egoiste-613.html"                                     
##  [64] "/perfume/Chanel/Egoiste-Cologne-Concentree-17293.html"                
##  [65] "/perfume/Chanel/Egoiste-Platinum-614.html"                            
##  [66] "/perfume/Chanel/1932-Eau-de-Parfum-41778.html"                        
##  [67] "/perfume/Chanel/31-Rue-Cambon-Eau-de-Parfum-41785.html"               
##  [68] "/perfume/Chanel/Beige-Eau-de-Parfum-41779.html"                       
##  [69] "/perfume/Chanel/Bel-Respiro-Eau-de-Parfum-41782.html"                 
##  [70] "/perfume/Chanel/Bois-des-Iles-1006.html"                              
##  [71] "/perfume/Chanel/Bois-des-Iles-Eau-de-Parfum-41787.html"               
##  [72] "/perfume/Chanel/Boy-Chanel-37473.html"                                
##  [73] "/perfume/Chanel/Chanel-N-22-1007.html"                                
##  [74] "/perfume/Chanel/Coromandel-Eau-de-Parfum-41783.html"                  
##  [75] "/perfume/Chanel/Cuir-de-Russie-Eau-de-Parfum-41786.html"              
##  [76] "/perfume/Chanel/Gardenia-936.html"                                    
##  [77] "/perfume/Chanel/Gardenia-Eau-de-Parfum-41788.html"                    
##  [78] "/perfume/Chanel/Jersey-Eau-de-Parfum-41776.html"                      
##  [79] "/perfume/Chanel/La-Pausa-Eau-de-Parfum-41781.html"                    
##  [80] "/perfume/Chanel/Les-Exclusifs-de-Chanel-1932-17388.html"              
##  [81] "/perfume/Chanel/Les-Exclusifs-de-Chanel-1932-Parfum-24445.html"       
##  [82] "/perfume/Chanel/Les-Exclusifs-de-Chanel-28-La-Pausa-7131.html"        
##  [83] "/perfume/Chanel/Les-Exclusifs-de-Chanel-31-Rue-Cambon-7150.html"      
##  [84] "/perfume/Chanel/Les-Exclusifs-de-Chanel-Beige-4686.html"              
##  [85] "/perfume/Chanel/Les-Exclusifs-de-Chanel-Beige-Parfum-24446.html"      
##  [86] "/perfume/Chanel/Les-Exclusifs-de-Chanel-Bel-Respiro-7141.html"        
##  [87] "/perfume/Chanel/Les-Exclusifs-de-Chanel-Coromandel-7145.html"         
##  [88] "/perfume/Chanel/Les-Exclusifs-de-Chanel-Cuir-de-Russie-7144.html"     
##  [89] "/perfume/Chanel/Les-Exclusifs-de-Chanel-Cuir-de-Russie-1924-98.html"  
##  [90] "/perfume/Chanel/Les-Exclusifs-de-Chanel-Eau-de-Cologne-7130.html"     
##  [91] "/perfume/Chanel/Les-Exclusifs-de-Chanel-Jersey-12425.html"            
##  [92] "/perfume/Chanel/Les-Exclusifs-de-Chanel-Jersey-Parfum-24447.html"     
##  [93] "/perfume/Chanel/Les-Exclusifs-de-Chanel-Misia-29676.html"             
##  [94] "/perfume/Chanel/Les-Exclusifs-de-Chanel-No-18-7147.html"              
##  [95] "/perfume/Chanel/Les-Exclusifs-de-Chanel-No-22-7142.html"              
##  [96] "/perfume/Chanel/Les-Exclusifs-de-Chanel-Sycomore-4688.html"           
##  [97] "/perfume/Chanel/Misia-Eau-de-Parfum-41777.html"                       
##  [98] "/perfume/Chanel/No-18-Eau-de-Parfum-41784.html"                       
##  [99] "/perfume/Chanel/No-22-Eau-de-Parfum-41789.html"                       
## [100] "/perfume/Chanel/Sycomore-Eau-de-Parfum-41780.html"                    
## [101] "/perfume/Chanel/Pour-Monsieur-615.html"                               
## [102] "/perfume/Chanel/Pour-Monsieur-Concentree-3131.html"                   
## [103] "/perfume/Chanel/Pour-Monsieur-Eau-de-Parfum-43001.html"
```

This returns the latter part of the URLs which can later be appended to the base URL. Each of these parsed URL tails correspond to a unique cologne or perfume webpage.


```r
base_URL <- rep('https://www.fragrantica.com', length(parse_test))
```

Here I have created a list that simply consists of the base URL repeated several times, according to the number of rows in my list of parsed URL tails.


```r
URL_DF <- paste(base_URL,parse_test)
head(URL_DF)
```

```
## [1] "https://www.fragrantica.com /perfume/Chanel/Antaeus-616.html"                  
## [2] "https://www.fragrantica.com /perfume/Chanel/Bois-Noir-34568.html"              
## [3] "https://www.fragrantica.com /perfume/Chanel/Chanel-No-46-22520.html"           
## [4] "https://www.fragrantica.com /perfume/Chanel/Gabrielle-43718.html"              
## [5] "https://www.fragrantica.com /perfume/Chanel/Le-1940-Beige-de-Chanel-45188.html"
## [6] "https://www.fragrantica.com /perfume/Chanel/Le-1940-Bleu-de-Chanel-45187.html"
```

I have now created a dataframe of URLs. Unfortunately, the pasting has left a space right in the middle of each URL.


```r
URL_DF <- gsub(" ","", URL_DF, fixed = TRUE)
```

This appears to have fixed the issue. I have successfully created a dataframe of URLs to use for scraping. Now we just have to reference these URLs in a datascraping function.

Despite the name, URL_DF is actually a list. We'll need to fix that in order to properly apply a function to it. 


```r
URL_DF <- as_data_frame(URL_DF)
names(URL_DF) <- "Link"
```

And here's the actual function. It looks simple, but took quite a bit of effort and troubleshooting!


```r
DF_PARF <- URL_DF %>%
	mutate(raw_page = map(Link,read_html),
		name = map(raw_page, ~ .x %>% html_node("h1 span") %>% html_text()),
				 brand = map(raw_page, ~ .x %>% html_node("span a span") %>% html_text()),
		scent = map(raw_page, ~ .x %>% html_node("#prettyPhotoGallery div div:nth-child(2) span") %>% html_text()),
		rating = map(raw_page, ~ .x %>% html_node("#col1 div+ div p span:nth-child(1)") %>% html_text()),
		description = map(raw_page, ~ .x %>% html_node("#col1 div:nth-child(7) p") %>% html_text())
		)
```

And here we have it, our scraped data:


```r
glimpse(DF_PARF)
```

```
## Observations: 103
## Variables: 7
## $ Link        <chr> "https://www.fragrantica.com/perfume/Chanel/Antaeu...
## $ raw_page    <list> [<html xmlns="http://www.w3.org/1999/xhtml" xml:l...
## $ name        <list> ["Antaeus Chanel for men", "Bois Noir Chanel for ...
## $ brand       <list> ["Chanel", "Chanel", "Chanel", "Chanel", "Chanel"...
## $ scent       <list> ["woody", "woody", "woody", "citrus", "white flor...
## $ rating      <list> ["4.16", " ", " ", "2.95", " ", " ", " ", " ", " ...
## $ description <list> ["Antaeus is the name of ancient Greek demigod. S...
```








<h3>Process:</h3>

I used several websites to help me out with this project:
<a href=https://www.youtube.com/watch?v=4IYfYx4yoAI>https://www.youtube.com/watch?v=4IYfYx4yoAI</a>
<a href=https://www.youtube.com/watch?v=MFQTHrCiAxA>https://www.youtube.com/watch?v=MFQTHrCiAxA</a>
<a href=https://www.youtube.com/watch?v=82s8KdZt5v8>https://www.youtube.com/watch?v=82s8KdZt5v8</a>
<a href=https://cran.r-project.org/web/packages/urltools/vignettes/urltools.html>https://cran.r-project.org/web/packages/urltools/vignettes/urltools.html</a>

I also got help from the TA's, especially for the actual function that scrapes the data. There are a lot of nuances that go into datascraping functions. All in all, this was one of my preferred assignment because I got to choose which data to scrape and it's such a potentially useful skill to learn.






