
shark <- 
  readxl::read_excel('data/Australian Shark-Incident Database Public Version.xlsx')

shark <-
  shark |>
  dplyr::filter(Incident.year >= 1900)

shark_out <- list()

shark_out$n_incidents <- nrow(shark)

# By year
shark_out$incidentsByYear <-
  shark |>
  dplyr::count(Incident.year) |>
  tidyr::complete(
    Incident.year = seq(min(Incident.year), max(Incident.year)),
    fill = list(n = 0)
  )

# Shark species
incidentsBySpecies <-
  shark |>
  dplyr::count(Shark.common.name) |>
  dplyr::arrange(dplyr::desc(n)) |>
  dplyr::mutate(pct = n / sum(n) * 100) 

shark_out$incidentsBySpecies <- list()

shark_out$incidentsBySpecies$nSpecies <- 
  nrow(incidentsBySpecies)

shark_out$incidentsBySpecies$top5PctSpecies <- 
  sum(incidentsBySpecies$pct[1:5]) |>
  round(0)

shark_out$incidentsBySpecies$data <-
  incidentsBySpecies |>
  dplyr::top_n(5) |>
  # combine others
  dplyr::bind_rows(
    incidentsBySpecies |>
      dplyr::slice(-c(1:5)) |> 
      dplyr::mutate(Shark.common.name = 'Other') |>
      dplyr::group_by(Shark.common.name) |>
      dplyr::summarise(
        dplyr::across(.cols = dplyr::everything(),
                      .fns = sum)
      )
  )


# Location
shark_out$incidentsByState <-
  shark |>
  dplyr::count(State)|>
  dplyr::arrange(dplyr::desc(n)) |>
  dplyr::mutate(pct = n / sum(n) * 100) 


# Activity
incidentsByActivity <-
  shark |>
  dplyr::count(Victim.activity) |>
  dplyr::arrange(dplyr::desc(n)) |>
  dplyr::mutate(pct = n / sum(n) * 100) 


shark_out$incidentsByActivity <-
  incidentsByActivity |>
  dplyr::top_n(5) |>
  # combine others
  dplyr::bind_rows(
    incidentsByActivity |>
      dplyr::slice(-c(1:5)) |> 
      dplyr::mutate(Victim.activity = 'Other') |>
      dplyr::group_by(Victim.activity) |>
      dplyr::summarise(
        dplyr::across(.cols = dplyr::everything(),
                      .fns = sum), 
        .groups = 'drop')
  )

# Time of day
shark_out$incidentsByTime <-
  shark |>
  dplyr::mutate(Time.of.incident = ifelse(nchar(Time.of.incident) == 3, paste0(0, Time.of.incident), Time.of.incident),
                Time.of.incident = as.POSIXct(Time.of.incident, format = '%H%M'),
                #Time.of.incident = lubridate::floor_date(Time.of.incident, unit = 'hours'),
                Time.of.incident = lubridate::floor_date(Time.of.incident, unit = lubridate::minutes(30))
                ) |>
  dplyr::count(Time.of.incident) |>
  dplyr::filter(!is.na(Time.of.incident)) |>
  tidyr::complete(Time.of.incident = seq.POSIXt(from = min(lubridate::floor_date(Time.of.incident, 'day')), 
                                                to = min(lubridate::ceiling_date(Time.of.incident, 'day')),
                                                by = 60 * 30),
                  fill = list(n = 0)) |>
  dplyr::mutate(Time.of.incident = format(Time.of.incident, '%H%M')) |>
  dplyr::slice(-dplyr::n())

shark_out |>
  jsonlite::toJSON(dataframe = 'columns', auto_unbox = TRUE) |>
  writeLines('docs/assets/data.json')








