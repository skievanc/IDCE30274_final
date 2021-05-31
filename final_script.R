require(raster)
require(rgdal)
require(sp)

#This script created by Evan Collins for IDCE30274
##

#This is a simple tutorial of processing and representing of a DEM
#R is a powerful environment for fast geoprocessing, and easy representation
#In this tutorial we will create and display a slope position layer from a DEM


#Load in our DEM -Digital Elevation Model- using the raster function
#Replace the text with the location of the raster on your computer, including .tif

DEM = raster('YOUR_RASTER_FILE_LOCATION.tif')


#Now let's look in the object to see its values, such as extent
#To open the object click on it in the sidebar - it will open a new tab
#Min and Max pixel values are not known, here we can set them
#Once you set them, reopen the object to look at the min and max within the data drop down

DEM = setMinMax(DEM)


#Lets explore the distribution of pixel values
#Defining maxpixels let's us represent all the pixel values - normally hist() is capped at 100,000
#Remeber a DEM shows elevation, so the histogram shows us distribution of elevations in this region

hist(DEM, main="Distribution of Pixel Values",maxpixels=116899344)


#We can also plot out DEM in to look at it
#Since this is a DEM this shows us the distribution and amount of terrain at different elevations

plot(DEM,"MA/NH DEM")


#Now that we have taken a look at our DEM we are going to do some processing to make a few new layers
#Our goal is to make a slope position layer - which is a categorization of area by what part of a slope it is
#We must make a few other layers first to do this
#Before we do any processing we will crop our DEM to a quarter of the size, to focus in on one area

cropbox=c(-72.0,-71.5,42.0,42.5)  #Define the bounding box of the crop
DEM_crop=crop(DEM,cropbox)  #This crop focuses the panel to central MA
plot(DEM_crop, "Central Mass DEM")

#The first step of our processing is create a TPI (terrain position index)
#The TPI of a pixel is equal to its elevation minus the mean elevation of its neighbors
#Focal statistics allow us to run a neighborhood mean function on every pixel
#Here we use a large 29x29 square moving window for the neighborhood (290x290meters)
#Pixels in this DEM are 10m
#Each pixel is added at its elevation value, then averaged, and that value assigned to the center pixel

elev_mean = focal(DEM_crop,w=matrix(1,nrow=29,ncol=29),fun=mean)  #Create mean elevation layer

DEM_TPI = DEM_crop - elev_mean  #Calculate the TPI as elevation - mean elevation
plot(DEM_TPI)  #Take a look

#Its pretty hard to tell what's what - we'll make that easier when we classify it

#Take a look at the distribution of pixel values now
#They range mostly within -3 through 3 
#These different values represent types of terrain 
#A low value means pixels in the neighborhood are on average a higher elevation
#A high value means pixels in the neighborhood are on average a lower elevation
#A value near zero means pixels in the neighborhood are on average a similar elevation

hist(DEM_TPI, breaks=100, main="Distribution of Pixel Values",maxpixels=116899344)




#Define a reclass to more easily interact with the TPI
#From looking at the histogram we can discern breakpoints for our classes
#For this tutorial, we will simply do ours symmetrically around zero
#We are classifying the pixels into groups which represent their terrain
#We will assign a numeric valley that represents the terrain type

reclass_df=c(-Inf,-3,-2,  #Lowest values - Valleys, -2
             -3,-1,-1,    #Low values - Toe slopes, -1
             -1,1,0,      #Zero values - Similar elevation slopes, 0
             1,3,1,       #High values - Top slopes, 1
             3,Inf,2)     #Highest values - Ridges, hilltops, 2

reclass_m=matrix(reclass_df,ncol=3,byrow=TRUE)  #Create the reclass matrix from the dataframe
tpi_5class = reclassify(DEM_TPI,reclass_m)  #Create the reclassified layer

plot(tpi_5class)  #Take a look


#We are not done yet
#Now we want to turn the TPI into a complete Slope Position index
#This means we need to develop our class 0 into two separate classes
#Two slopes types return near 0 in a TPI, flat ground, and middle slopes (not at the bottom or top of the slope)
#To differentiate these we must calculate slope, and combine it with our 0 class


#We can compute slope simply with the 'terrain' function
#We calculate slope as degrees, with the queens case method (8 neighbors)
slope=terrain(DEM_crop,pot='slope',unit='degrees',neighbors=8)
image(slope)  #Take a look

#We could also have computed the TPI with the terrain function
#The terrain function has a few common terrain processes built into it

#Now that we have slope, lets specify just flat ground. 
#We will say everything 1 degree and less is flat. 
#We simply select the values we want, and assign it to a new layer

slope_zero= slope <= 1

#The resulting map has all slope <=1 as a value of 1, and everything else as 0 value
plot(slope_zero)  #Take a look

#Now we combine our zero slope and TPI layer to figure out what part of class 0 is flat
#We select 0 for tpi_5class, and 1 for slope_zero

flat = tpi_5class==0 & slope_zero==1
plot(flat)  #Take a look


#Now we can combine these two layers to create our final slope position layer
#We use the mask function to reclass all pixels in tpi_5class that are of value 1 in the
#   flat layer.
#We change them to value 3
#Now class 0 is only middle slopes, and value 3 is flat ground

slope_pos = mask(tpi_5class, flat, maskvalue=1,updatevalue=3)

#Take a look at the histogram to see how the pixels are distibuted into our 6 classes
hist(slope_pos, main="Distribution of Pixel Values",maxpixels=116899344)

#Notice there are a lot of 0 value pixels
#This means many pixels have been classified as middle slopes
#This may be a result of us using a large neighborhood for the TPI
#Changing the TPI neighborhood size would give different results

#Now lets display our new layer
#First we determine a color palette
#Here we use a hcl (hue-chroma-luminance) palette, designating 6 classes

col=hcl.colors(6)

plot(slope_pos,col=col,main='Slope Position of a Region in Central MA')

#Notice something strange about our 'flat' class?
#It is not only representing flat ground - but also waterbodies
#If we didn't want this we could get a layer of waterbodies and do more processing.


#Lets take a closer look at one section of the image
#We can make a new crop that is smaller and more focused 
#This region is northern central Massachusetts

smallcrop=c(-72.0,-71.8,42.3,42.5)  #Define the bounding box of the crop
slope_pos_zoom=crop(slope_pos,smallcrop)

plot(slope_pos_zoom,col=col,main='Slope Position of a Region in Central MA')


#If you want to practice this method, try downloading a new DEM and reproducing the process.



