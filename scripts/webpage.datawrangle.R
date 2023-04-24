
shark <- 
  readxl::read_excel('data/Australian Shark-Incident Database Public Version.xlsx')

shark <-
  shark |>
  dplyr::filter(Incident.year >= 1900)

shark_out <- list()

shark_out$n_incidents <- nrow(shark)

shark_out$incidentsByYear <-
  shark |>
  dplyr::count(Incident.year) |>
  tidyr::complete(
    Incident.year = seq(min(Incident.year), max(Incident.year)),
    fill = list(n = 0)
  )


# The vast majority of these incidents (X %) have been assocaited with just 5
# shark species

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

shark_out |>
  jsonlite::toJSON(dataframe = 'columns', auto_unbox = TRUE) |>
  writeLines('australian-shark-incidents/assets/data.json')

# Location
shark |>
  dplyr::count(State)|>
  dplyr::arrange(dplyr::desc(n))

# Activity
shark |>
  dplyr::count(Victim.activity) |>
  dplyr::arrange(dplyr::desc(n))

# Time of day
shark |>
  dplyr::count(Time.of.incident)
