# Raster GIS in R Tutorial
  
Author: Evan Collins  
For IDCE30724  
5/30/2021  
  
## Tutorial 
  
The tutorial is an overview of processing and viewing a raster file in R.
Specifically the tutorial focuses on using a DEM (digital elevation model).
The tutorial is fully contained within the R file. Download the file and open it in your R environment.
I prefer R studio, which is where I created the code.
The tutorial is set up as code with comments explaining the process and what we are doing.
R code can be run line by line. In this way we may read the comments and run one line at a time to slowly work
our way through the code.   
  
## Creating a Slope Position layer
  
Slop position describes what type of slope an area is. This includes: valleys, toe slopes, mid slopes, top slopes, ridges, and flat ground.  
We create this layer by going through a process of creating other layers, recclassifying, and selecting values.  
Each step can be easily visualized in R, using the plot function.  
At the end, we create a colorscheme, and a couple visualiztions of the slope position layer we create. 

## Data
  
For this tutorial weonly need 1 USGS DEM. It is in the repository, but you also download it from USGS
at https://www.sciencebase.gov/catalog/item/5f7784f982ce1d74e7d6cbce. It is USGS 1/3 arc-second tile n43w072, 1 x 1 degree.
It covers a space of 1 x 1 degree, in the region of central and eastern Massachusetts and southern New Hampshire. 
We will clip the tile to only use the Massachusetts portion. Many other DEMs can be found free to download using USGS national map
at https://apps.nationalmap.gov/downloader/#/.
