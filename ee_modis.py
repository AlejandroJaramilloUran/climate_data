# install the earth engine API from the cdm
# pip install earthengine-api

import ee
ee.Authenticate() 

#use your own project
ee.Initialize(project='ee-user')

# I'm interested in MODIS temperature data for the years 2000 - 2022

collection_day = (ee.ImageCollection("MODIS/061/MOD11A2")
    .select(["LST_Day_1km", "QC_Day"])
    .filterDate('2000-01-01', '2022-12-31')
)

# Kelvin to celsius
def convert_to_celsius(img):
    lst_celsius = img.select('LST_Day_1km').multiply(0.02).subtract(273.15)
    return lst_celsius.addBands(img.select('QC_Day')) \
                      .copyProperties(img, ['system:time_start', 'system:time_end'])

LSTDay = collection_day.map(convert_to_celsius)

#years and site of interest

years = ee.List.sequence(2000, 2022)
roi = ee.Geometry.Rectangle([-75.15, 6.73, -75.05, 6.81])


# every year average and export

for year in years.getInfo():
    filtered = LSTDay.filter(ee.Filter.calendarRange(year, year, 'year'))
    annual_mean = filtered.mean().set('year', year)

    # export
    task = ee.batch.Export.image.toDrive(
        image=annual_mean.clip(roi),
        description=f'LST_Day_{year}',
        folder='earth_engine',
        scale=1000,
        region=roi,
        fileFormat='GeoTIFF',
        crs='EPSG:4326',  # WGS84
        maxPixels=1e13
    )
    
    task.start()
    print(f"Working on {year}.")







