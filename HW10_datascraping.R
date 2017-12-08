
# https://nycdatascience.com/blog/student-works/recipes-scraping-top-20-recipes-allrecipes/

# https://www.youtube.com/watch?v=4IYfYx4yoAI
# https://www.youtube.com/watch?v=MFQTHrCiAxA
# https://www.youtube.com/watch?v=82s8KdZt5v8 more advanced
# https://cran.r-project.org/web/packages/urltools/vignettes/urltools.html

# Our goal is to scrape the descriptions of dessert recipes from allrecipes.com
# I am using rvest and a chrome extension called selector gadget

library(rvest)
library(tidyverse)
library(purrr)

# Goal- scrape fragrantica

frag <- read_html("https://www.fragrantica.com/perfume/Chanel/Antaeus-616.html")
frag

name <- frag %>%
	html_node("h1 span") %>%
	html_text()
name

scent1 <- frag %>% 
		#html_nodes("#prettyPhotoGallery div div+ div span") %>% 
		html_node("#prettyPhotoGallery div div:nth-child(2) span") %>%
		html_text()
	scent1

		
rating <- frag %>% 
	html_node("#col1 div+ div p span:nth-child(1)") %>%
	html_text()
rating


		
brand <- frag %>% 
	html_node("span a span") %>%
	html_text()
brand

description <- frag %>%
	html_node("#col1 div:nth-child(7) p") %>%
	html_text()
description

View(data.frame(name, brand, scent, rating, description))

# Now let's try to automate the process


library(urltools)
?urltools

# We'll use urltools to parse the URL
# this should enable us to look at more than one webpage once we write our function

parsed <- url_parse("https://www.fragrantica.com/perfume/Chanel/Antaeus-616.html")
parsed

parsed$path
# This is the path that we need to view the Antaeus cologne by Chanel.
# We've got to find a way to pull a similar path from each of the Chanel links available
# then we can pipe these paths into a function

# (may look into jump_to function)
chanel_page <- read_html("https://www.fragrantica.com/designers/Chanel.html")
chanel_page

parse_test <- chanel_page %>%
	html_nodes(".plist a") %>%
	html_attr('href')
parse_test
# this returns the latter part of the URLs which can be appended to the base URL

base_URL <- rep('https://www.fragrantica.com', length(parse_test))
base_URL

# I'll use the paste function to combine the base URL with it's unique path

URL_DF <- paste(base_URL,parse_test)
URL_DF

# I have a list of URLs, but there is a space in the middle of each URL 
# that needs to be removed

URL_DF <- gsub(" ","", URL_DF, fixed = TRUE)
View(URL_DF)
# We have successfully created a dataframe of URLs to use for scraping.
# Now we just have to reference these URLs in a datascraping function 

### Creating the function

## Logic:
# function 1 creates a dataframe of complete urls.
# It will be of the form: col1 = 1,2,3; col2 = url1, url2, url3
# 
# 
# Function 2 does the actual scraping and should culminate in a dataframe with brand name,
# description, product rating, etc.
# You can call the URLS from function 1 using the format DF1 (i, 2), which tells R to select
# the element located in row i, column 2.

for (i in 1:length(URL_DF)) {
	 #i <- 2
	pagehtml <- read_html(URL_DF[i])
	output_data <- data.frame(name = html_node(pagehtml,"h1 span") %>%
						 	html_text(),
						 brand = html_node(pagehtml,"span a span") %>%
						 	html_text(),
						 scent = html_node(pagehtml,"#prettyPhotoGallery div div:nth-child(2) span") %>%
						 	html_text(),
						 rating = html_node(pagehtml,"#col1 div+ div p span:nth-child(1)") %>%
						 	html_text(),
						 description = html_node(pagehtml,"#col1 div:nth-child(7) p") %>%
						 	html_text()
						 )
}

URL_DF <- as_data_frame(URL_DF)
names(URL_DF) <- "Link"

DF_PARF <- URL_DF %>%
	mutate(raw_page = map(Link,read_html),
		name = map(raw_page, ~ .x %>% html_node("h1 span") %>% html_text()),
				 brand = map(raw_page, ~ .x %>% html_node("span a span") %>% html_text()),
		scent = map(raw_page, ~ .x %>% html_node("#prettyPhotoGallery div div:nth-child(2) span") %>% html_text()),
		rating = map(raw_page, ~ .x %>% html_node("#col1 div+ div p span:nth-child(1)") %>% html_text()),
		description = map(raw_page, ~ .x %>% html_node("#col1 div:nth-child(7) p") %>% html_text())
		)

View(DF_PARF)

glimpse(DF_PARF)
