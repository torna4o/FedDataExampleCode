##################################################
##     ##     ##    ## ### ##     ##    ###     ##
#### #### ### ## ## ##  ## ## ### ## ### ## ### ##
#### #### ### ##   ### # # ## ### ## ### ## ### ##
#### #### ### ## ## ## ##  ##     ## ### ## ### ##
#### ####     ## ## ## ### ## ### ##    ###     ##
##################################################

################################################################################################################
# Bochinsky, K.R., Beaudette, D., Chamberlain, S. (2019)                                                       #
# FedData: Functions to Automate Downloading Geospatial Data Available from Several Federated Data Sources     #
# https://cran.r-project.org/web/packages/FedData/                                                             #
# https://github.com/ropensci/FedData/                                                                         #
################################################################################################################

##### PART 0: LIBRARIES

# The "sp" and "raster" libraries will be needed 
# to load and save shapefiles or raster files
# FedData is the main library for data retrieval.

library(sp)
library(FedData)
library(raster)

##### PART 1: DEFINING REGION OF INTERESTS

# Loading shapefiles 

AOI <- shapefile("./file.shp") # path to where your shapefile related files are present

# You can also define region of interest directly
# via entering coordinates, example from reference document of FedData below

vepPolygon <- polygon_from_extent(raster::extent(672800,740000,4102000,4170000),
proj4string='+proj=utm +datum=NAD83 +zone=12')

##### PART 2: DATA RTRIEVALS

#### PART 2.1: GLOBAL HISTORICAL CLIMATE NETWORK DAILY DATA

sac_ghcn <- get_ghcn_daily(AOI, # here is the shapefile to indicate your area of interest, it can be as large as one needs
		label="LABEL", # code put this label at the start of the filename
		elements = c("PRCP","SNOW","SNWD","TMAX","TMIN", "TSUN", "EVAP"), # the variables you want to retrieve,consult page 5 of FedData document for full list
		years = c(2000:2020), # the year range for data
		raw.dir = "./raw/ghcn/", # location to save initial downloads
		extraction.dir = "./extracted/ghcn/") # location to save extent/time/variable cropped data

# This function saves a shapefile for station locations and .Rds files for data.
# The following "base" Rds function read the datafile, for later .csv writing of them to introduce SWAT editor

specific file <- readRDS(file="filepath")

#### PART 2.2: NATIONAL LANDCOVER DATABASE

# For this to work, following installation is necessary

install.packages("devtools")
devtools::install_github("ropensci/FedData")

# The parts of the function are the same as above.

sac_nlcd <- get_nlcd(AOI, # This aoi might be larger, 10,000 square kilometers of areas can be retrieved
			   label="LABEL",
			   year = 2011, # Acceptable values are 2001, 2004, 2006, 2008, 2011, 2016, 2019
			   dataset= "landcover", # Available datasets: landcover, impervious, canopy
 			   raster.options = c("COMPRESS=DEFLATE", "ZLEVEL=9","INTERLEAVE=BAND"), # writeRaster related options, also "rgdal" and raster::writeRaster() function
                     force.redo = F) # if you rerun this function with same filename and directories, new one will be created when this is T

crs(sac_nlcd) # To show its coordinate referense system projection, so that user might want to change 
		  # prior to writing it to a file

# This get_nlcd returns a tiff file that can directly be written to the disk.

writeRaster(sac_nlcd, "./saclanduse.tif")

# Additionally, the following function returns a table of official land cover codes and associated colors in HEX codes
pal_nlcd()

#### PART 2.2: SSURGO

		  get_ssurgo(AOI, # This creates problem with relatively bigger aoi (such as Sacramento watershed (~72,000 km2), so chop your aoi to a few parts distributed to your overall aoi, download one by one
				 label="LABEL",
				 raw.dir = "./raw/ssurgo/",
			       extraction.dir = "./extracted/ssurgo/")

# This function returns shapefiles. Detailed info about SSURGO is in the following link:
# https://www.nrcs.usda.gov/wps/portal/nrcs/detail/soils/home/?cid=nrcs142p2_053631

#### PART 2.3: National Elevation Dataset

		 get_ned(aoi, # Again, smaller aoi might be required
			   label="label", 
			   res = "1", # 1 arc-second resolution, another option is 13 to represent 1/3 arc-second resolution
			   raw.dir = "./raw/ned/",
			   extraction.dir = "./extracted/ned/", # a tif file is generated here based on the extent you entered
			   raster.options = c("COMPRESS=DEFLATE", "ZLEVEL=9", "INTERLEAVE=BAND")) #writeRaster related options

#### PART 2.4: National Elevation Dataset

library(rgdal)
sac_nhd <-		  get_nhd(aoi, # Relatively smaller aoi is recommended, 
			  label="label",
			  extraction.dir = "./extracted/nhd/",
			  )

# It returns a tibble list with following parts: $Point, $Flowline, $Line, $Area, $Waterbody


