# Description ------------------------------------------------------------------
### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ###
# Author: Max Marklein
# University of Bremen
# Last updated: 23.06.2025
# 
# This tasks deals with the identification of sediment core material suitable for 
# sedaDNA sampling within the GeoB Core repository of the University of Bremen. 
# Main requirements are the identification of cores without any national jurisdiction, 
# and avaiability of evironmental data. 
# The package Pangear should be used for automated data extraction.
# 
### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ###

# Set Up -----------------------------------------------------------------------

## Set Working directory ----
setwd("~/Wichtiges/Studium/Jobs/AG-Kucera/Pangea_core_data_mining")

## clear environment ----
rm(list=ls())
dev.new()

## Libraries ----
library(tidyverse)
library(lubridate)
library(pangaear)
library(sf)
library(rnaturalearth)
library(rnaturalearthdata)

# Data retrieval examples ------------------------------------------------------

## Search ----
pg_search(query = 'water', bbox = c(-124.2, 41.8, -116.8, 46.1), count = 3)

## Get data
res <- pg_data(doi = '10.1594/PANGAEA.807580')

### Search and pass ----
res <- pg_search(query = 'water', bbox = c(-124.2, 41.8, -116.8, 46.1), count = 3)
pg_data(res$doi[3])[1:3]

# Start mining -----------------------------------------------------------------

## Load GeoB core list and cores used in PALMOD
core_list <- read.csv("~/Wichtiges/Studium/Jobs/AG-Kucera/Pangea_core_data_mining/data/All_GeoB_Events_DIS_Export_20240905.csv") %>%
  drop_na() %>% 
  rename("SiteName" = "GEOB_NR") %>% 
  filter(GEAR == "GC") %>% # Filter for only Gravity cores
  mutate(YEAR = str_extract(DATE, "\\d{4}") %>% as.integer()) #%>%
  #filter(YEAR >= 2000) # Filter out everything before the year 2000

### Convert to sf format
core_sf <- core_list %>%
  st_as_sf(coords = c("LONGITUDE_DEC", "LATITUDE_DEC"), crs = 4326)

## Load cores that has been used in PALMOD
palmod_SST_LGM <- read.csv("~/Wichtiges/Studium/Jobs/AG-Kucera/Pangea_core_data_mining/data/sst_0_25.csv") %>% 
  mutate(period = "LGM")
palmod_SST_MIS5 <- read.csv("~/Wichtiges/Studium/Jobs/AG-Kucera/Pangea_core_data_mining/data/sst_80_150.csv") %>% 
  mutate(period = "MIS5")

palmod_SST <- bind_rows(palmod_SST_LGM, palmod_SST_MIS5) %>% 
  mutate(SiteName = str_replace_all(SiteName, "_", "-"))
rm(palmod_SST_LGM, palmod_SST_MIS5)

## EEZ from marineregions.org
eez <- st_read("~/Wichtiges/Studium/Jobs/AG-Kucera/Pangea_core_data_mining/data//EEZ/EEZ_land_union_v4_202410.shp") %>% 
  st_make_valid()

## Spatial join to see which points fall within EEZs ----
cores_in_eez <- st_join(core_sf, eez, left = FALSE)

### Find core out of EZZ ----
cores_outside_eez <- core_sf %>%
  anti_join(st_drop_geometry(cores_in_eez), by = "SiteName")

### World data ----
world <- ne_countries(scale = "medium", returnclass = "sf")

ggplot() +
  geom_sf(data = world, fill = "gray90", color = "black", size = 0.3) +       # country boundaries
  geom_sf(data = cores_in_eez, color = "black", size = 2, alpha = 0.7) +       # cores inside EEZ (blue)
  geom_sf(data = cores_outside_eez, color = "darkgreen", size = 2, alpha = 1) +   # cores outside EEZ (red)
  theme_minimal() +
  labs(title = "GeoB cores after year 2000 - 10% outside of EZZ",
       caption = "Blue = inside EEZ (1943), Red = outside EEZ (196)") +
  coord_sf(crs = "+proj=robin")  # Robinson projection

ggsave("plots/GeoB_outEZZ_after2000.pdf", width = 30, height = 20, units = "cm")

nrow(cores_outside_eez) / nrow(cores_in_eez) * 100
# 10% (196) of all GeoB cores after 2000 where taken outside of EEZs

## Check which cores are in PALMOD ----
check_palmod <- palmod_SST %>% 
  inner_join(st_drop_geometry(cores_outside_eez), by = join_by(SiteName)) %>% 
  dplyr::select(SiteName, period, YEAR)
# After the year 2000 there is no core available in PALMOD that is outside of EZZ
# In total there are 9 GeoB cores in PALMOD
print(check_palmod)
