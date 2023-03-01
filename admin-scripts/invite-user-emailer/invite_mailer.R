# Create coresops.bioconductor.org invitations 
library(jsonlite)
library(tidyverse)
library(lubridate)

path_to_repo <- "~/bioc-core-sops"
target_file <- "~/Downloads/invite_list.tsv"

create_invitation <- function(UserId, Provider = "GitHub") {
  x <- str_glue(
    "az staticwebapp users invite -n bioc-core-sops --authentication-provider {Provider} --user-details {UserId} --role verified --domain coresops.bioconductor.org --invitation-expiration-in-hours 120 --output json"
    )
  fromJSON(system(x, intern = TRUE))
  
}

setwd(path_to_repo)

coreteam <- fromJSON("data/members.json")
list_users_cmd <- "az staticwebapp users list -n bioc-core-sops --output json"
currentmemebers <- fromJSON(system(list_users_cmd, intern = TRUE))

# Invite everyone who doesn't already have a github identity
x <- coreteam |> 
  filter(!(GithubId %in% currentmemebers$displayName)) 
x <- x |>  cbind(map_dfr(x$GithubId, create_invitation) |> mutate(name = NULL))
x$expiresOn <- str_glue("{as.character(parse_datetime(x$expiresOn))} EST")

write_tsv(x, target_file)
