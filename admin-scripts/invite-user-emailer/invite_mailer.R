# Create coresops.bioconductor.org invitations 
library(jsonlite)
library(tidyverse)
library(lubridate)

path_to_repo <- "~/Projects/bioc-core-sops"
path_to_repo <- "~/Projects/bioc-core-sops"
target_file <- "~/Downloads/invite_list.tsv"
site_name = "bioc-core-sops"
subscription = "25f05b47-1212-4dc5-b131-ddbe8c7b8c60"
resource_group = "bioc-core-sops"

site_desc = str_glue("-n {site_name} --subscription {subscription} --resource-group {resource_group}")

create_invitation <- function(UserId, Provider = "GitHub") {
  x <- str_glue(
    "az staticwebapp users invite {site_desc} --user-details {UserId} --role verified --domain core-sops.bioconductor.org --authentication-provider {Provider} --invitation-expiration-in-hours 120 --output json"
    )
  fromJSON(system(x, intern = TRUE))
}

setwd(path_to_repo)

coreteam <- fromJSON("data/members.json")
list_users_cmd <- str_glue("az staticwebapp users list {site_desc} --output json")
currentmemebers <- fromJSON(system(list_users_cmd, intern = TRUE))

# Invite everyone who doesn't already have a github identity
x <- coreteam |> 
  filter(!(GithubId %in% currentmemebers$displayName)) 
x <- x |>  cbind(map_dfr(x$GithubId, create_invitation) |> mutate(name = NULL))
x$expiresOn <- str_glue("{as.character(parse_datetime(x$expiresOn))} EST")

write_tsv(x, target_file)
