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