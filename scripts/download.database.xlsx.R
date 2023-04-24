#' Download Australian Shark Incident Database from zenodo.org
#' 
#' Download the public Australian Shark-Incident Database Public Version.xlsx and 
#' save to the data/ folder


shark_database_url <- 'https://zenodo.org/record/7608411/files/Australian%20Shark-Incident%20Database%20Public%20Version.xlsx?download=1'
destintation_path <- file.path('data', URLdecode('Australian%20Shark-Incident%20Database%20Public%20Version.xlsx'))

download.file(shark_database_url, destfile = destintation_path, mode = 'wb')

file.exists(destintation_path)

rm(list = c('shark_database_url', 'destintation_path'))
