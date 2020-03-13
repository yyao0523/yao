install.packages("leaflet")
install.packages("tidyverse")
library(leaflet)
library(tidyverse)

install.packages("tidycensus")
library(tidycensus)

# add census API key
census_api_key("7088032db5159d6b35650d8ce1a56511ae4202ac", overwrite = FALSE, install = FALSE)

# access census data
m90 <- get_decennial(geography = "state", variables = "H043A001", year = 1990)

# chart our rent data
m90 %>% 
  ggplot(aes(x = value, y = reorder(NAME, value))) +
  geom_point()

# get ACS data
transpo <- get_acs(geography = "state", variables = "B08006_008", geometry = FALSE, survey = "acs5", year = 2017)
glimpse(transpo)

# get more ACS data
transpo_total <- get_acs(geography = "state", variables = "B08006_001", geometry = FALSE, survye = "acs5", year = 2017)
909679 / 179589758

# join our data
transpo <- transpo %>% left_join(transpo_total, by = "NAME")

# do our commuting share math
transpo$rate <- transpo$estimate.x / transpo$estimate.y * 100
head(transpo)

install.packages("rgdal")
library(rgdal)
states <- readOGR("/cloud/project/",
                  layer = "tl_2019_us_state", GDAL1_integer64_policy = TRUE)

states_with_rate <- sp::merge(states, transpo, by = "NAME")

qpal <- colorQuantile("PiYG", states_with_rate$rate, 9)

states_with_rate %>% leaflet() %>% addTiles() %>%
  addPolygons(weight = 1, smoothFactor = 0.5, opacity = 1.0, fillOpacity = 0.5,
              color = ~qpal(rate),
              highlightOptions = highlightOptions(color = "white", weight = 2,
                                                  bringToFront = TRUE))