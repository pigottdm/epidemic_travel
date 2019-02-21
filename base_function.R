#function for estimating travel time from one set of locations to another

#initiated by David Pigott February 21st 2019
#last updated by David Pigott February 21st 2019

#inspired by blog post by Amelia Bertozzi-Villa, heavily making use of original research 
#by Daniel Weiss

#install relevant packages
library(raster)
library(gdistance)
library(abind)
library(rje)
library(ggplot2)
library(malariaAtlas)

#define the location - must be an ISO3 code
location<-NA
#define set of points - dataframe with columns "latitude" & "longitude"
points<-NA


#set of functions which need to be incorporated

loc.shp <-
  malariaAtlas::getShp(ISO = "TZA")
friction <-
  malariaAtlas::getRaster(surface = "A global friction surface enumerating land-based travel speed for a nominal year 2015",
                          shp = loc.shp)

malariaAtlas::autoplot_MAPraster(friction)

#still not 100% clear why this step is required
T <- gdistance::transition(friction, function(x)
  1 / mean(x), 8)
T.GC <- gdistance::geoCorrection(T)

#convert binary risk raster into a points layer (this will be our dataset for distance to)
points_ebov <-
  rasterToPoints(
    ebov,
    fun = function(r) {
      r == 1
    },
    spatial = FALSE
  )

points_ebov <- data.frame(points_ebov)

coordinates(points_ebov) <- ~ x + y
proj4string(points_ebov) <- proj4string(loc.shp)

points <- as.matrix(points_ebov@coords)

points_metadata<-over(points_ebov, loc.shp)

#subset points_ebov to only those with iso
points_crop<-points_ebov[-which(is.na(points_metadata$iso)),]

access.raster <- gdistance::accCost(T.GC, points)