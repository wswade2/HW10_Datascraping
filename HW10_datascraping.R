
# https://nycdatascience.com/blog/student-works/recipes-scraping-top-20-recipes-allrecipes/

# https://www.youtube.com/watch?v=4IYfYx4yoAI
# https://www.youtube.com/watch?v=MFQTHrCiAxA
# https://www.youtube.com/watch?v=82s8KdZt5v8 more advanced

# Our goal is to scrape the descriptions of dessert recipes from allrecipes.com
# I am using rvest and a chrome extension called selector gadget

library(rvest)
library(tidyverse)

all_recipes <- read_html("http://allrecipes.com/search/results/?wt=dessert&sort=re&page=2")
all_recipes

description <- all_recipes %>% 
	html_nodes(".rec-card__description") %>% 
	html_text()
description


# New goal- scrape fragrantica

frag <- read_html("https://www.fragrantica.com/perfume/Chanel/Antaeus-616.html")
frag

name <- frag %>%
	html_node("h1 span") %>%
	html_text()
name

scent <- frag %>% 
		#html_nodes("#prettyPhotoGallery div div+ div span") %>% 
		html_node("#prettyPhotoGallery div div:nth-child(2) span") %>%
		html_text()
	scent
	
description <- frag %>%
	html_node("#col1 div:nth-child(7) p") %>%
	html_text()
description
	
data.frame(name, scent, description)	

View(data.frame(name, scent, description))











