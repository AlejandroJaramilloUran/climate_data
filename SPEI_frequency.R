#load points of interest
points <- read.csv("points.csv", sep = ";")

#I'm using a drought file obtained from here: https://essd.copernicus.org/articles/15/5449/2023/

spei_06 <- nc_open("spei06.nc")

#filter with coordinates and time of interest 
lonidx <- which(spei_06$dim$lon$vals < -74.5 & spei_06$dim$lon$vals > -75.5)
latidx <- which(spei_06$dim$lat$vals < 7.2 & spei_06$dim$lat$vals > 6.5)

#number of days since 1980 - 01 - 01
timeidx <- which(spei_06$dim$time$vals > 8765 & spei_06$dim$time$vals < 15691)

#ncvar_get function allows to reads data from an existing netCDF file
spei_06_recortado <- ncvar_get(nc = spei_06, 
                               varid = spei_06$var$spei, 
                               start = c(lonidx[1], latidx[1], timeidx[1]), 
                               count = c(length(lonidx), length(latidx), length(timeidx)),
                               verbose = T)

lon_recortada <- spei_06$dim$lon$vals[spei_06$dim$lon$vals < -74.5 & spei_06$dim$lon$vals > -75.5]
lat_recortada <- spei_06$dim$lat$vals[spei_06$dim$lat$vals < 7.2 & spei_06$dim$lat$vals > 6.5]

#I'm interest in this particular dates
time <- ncvar_get(spei_06, "time")
time2 <- as.Date("1980-01-01") + time
time_interest <- time2[277:504]

#Function to extract the values
series_spei_06 <- function(coordenadas, spei){
  
  unique_plots <- unique(coordenadas$plot)
  for (plot in unique_plots) {
    coords_parcela <- coordenadas[coordenadas$PLOT == plot, ]
    lon <- coords_parcela$lon[1]
    lat <- coords_parcela$lat[1]
    
    lon_spei <- which.min(abs(lon_recortada - lon))
    lat_spei <- which.min(abs(lat_recortada - lat))
    
    serie <- spei[lon_spei, lat_spei, ]
    df <- data.frame(time_interest, serie)
    
    nombre <- paste0("spei06_", plot, ".csv")
    write.csv(df, nombre, row.names = F)
  }
}

series_spei_06(points, spei_06_recortado)
