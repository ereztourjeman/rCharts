#' Publish a list of files as a gist
#' 
#' @param gdir directory of files to post
#' @param description brief description of gist
#' @param public whether gist is public (defaults to TRUE)
#' @importFrom RCurl postForm
#' @importFrom rjson fromJSON
#' 
#' @examples
#' \dontrun{
#' gist = create_gist(gfiles, description = 'description', public = T)
#' }
post_gist_oauth <- function(gist, 
    viewer = getOption('GIST_VIEWER', 'http://pagist.github.io')){
  if (is.null(getOption('github.username'))){
    username <- readline("Please enter your github username: ")
    options(github.username = username)
  }
  if (is.null(getOption('github.password'))){
    password <- readline("Please enter your github password: ")
    options(github.password = password)
  }
  token = get_token(getOption('github.username'), getOption('github.password'))
  response = postForm(
    uri = 'https://api.github.com/gists',
    .opts = list(
      postFields = gist,
      httpheader = c('Authorization' = paste('token', token))
    )
  ) 
  html_url = fromJSON(response[1])$html_url
  message('Your gist has been published')
  message('View chart at ', paste(viewer, basename(html_url), sep = "/"))
}


#' Function that takes a list of files and creates payload for API
#'
#' @param filenames names of files to post
#' @param description brief description of gist (optional)
#' @param public whether gist is public (defaults to TRUE)
create_gist <- function(filenames, description = "", public = TRUE){
  files = lapply(filenames, function(file){
    x = list(content =  paste(readLines(file, warn = F), collapse = "\n"))
  })
  names(files) = basename(filenames)
  body = list(description = description, public = public, files = files)
  toJSON(body)
}

#' Get basic authorization token from Github using curl
#' 
#' Source: https://help.github.com/articles/creating-an-oauth-token-for-command-line-use
get_token <- function(username, pwd){
  require(RCurl); require(rjson)
  response = postForm(
    uri = 'https://api.github.com/authorizations',
    .opts = list(
      postFields = '{"scopes": ["user", "gist"]}',
      userpwd = paste(username, pwd, sep = ":"),
      httpauth = 1L
    )
  )
  return(fromJSON(response[1])$token)
}

post_gist <- function(gist, viewer = getOption('GIST_VIEWER', 'http://pagist.github.io')){
  require(httr)
  if (is.null(getOption('github.username'))){
    username <- readline("Please enter your github username: ")
    options(github.username = username)
  }
  if (is.null(getOption('github.password'))){
    password <- readline("Please enter your github password: ")
    options(github.password = password)
  }
  response = POST(
    url = 'https://api.github.com/gists',
    body = gist,
    config = c(
      authenticate(
        getOption('github.username'), 
        getOption('github.password'), 
        type = 'basic'
      ),
      add_headers("User-Agent" = "Dummy")
    )
  )
  html_url = content(response)$html_url
  message('Your gist has been published')
  message('View chart at ', paste(viewer, basename(html_url), sep = "/"))
}
