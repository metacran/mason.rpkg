
#' This is a Mason template for a generic R package
#'
#' The template somewhat leans towards GitHub, actually,
#' so it is best for packages developed at GitHub.
#'
#' @export
#' @importFrom ask questions

survey <- questions(

  ## DESCRIPTION file
  name = input("Name:", default = basename(getwd())),
  title = input("Title:", default = answers$name),
  version = input("Version:", default = "1.0.0"),
  author = input("Author:", default = default_author()),
  maintainer = input("Maintainer:", default = default_maintainer(answers)),
  description = input("Description:", default = answers$title),
  license = choose("License:", licenses, default = "MIT"),
  url = input("URL:", default = default_url(answers)),
  bugreports = input("BugReports:", default = default_bugreports(answers)),

  ## Others
  testing = choose("Testing framework:", choices = c("testthat", "none"),
    default = 1),
  readme = confirm("README.md file:", default = TRUE),
  readme_rmd = confirm("README.Rmd file:", default = TRUE,
    when = function(a) a$readme),
  news = confirm("NEWS.md file:", default = TRUE),
  cis = checkbox("Continuous integration:", choices = cis,
    default = c("Travis", "Appveyor")),

  ## git and GitHub stuff
  create_git_repo = confirm("Create git repo?", default = TRUE),
  create_gh_repo = confirm("Create repo on GitHub?", default = TRUE,
    when = function(a) a$create_git_repo),
  gh_username = input("GitHub username:", default = whoami::gh_username(),
    when = function(a) a$create_git_repo && a$create_gh_repo),
  push_to_github = confirm("Push initial version to GitHub?",
    default = FALSE, when = function(a) a$create_gh_repo)
)

licenses <- c("MIT",
              "AGPL-3",
              "Artistic-2.0",
              "BSD_2_clause",
              "BSD_3_clause",
              "GPL-2",
              "GPL-3",
              "LGPL-2",
              "LGPL-2.1",
              "LGPL-3",
              "Other")

cis <- c("Travis", "Appveyor")

#' @importFrom whoami fullname
#' @importFrom falsy try_quietly %||%

default_author <- function() {
  try_quietly(fullname()) %||% ""
}

#' @importFrom whoami email_address
#' @importFrom falsy try_quietly

default_maintainer <- function(answers) {
  n <- default_author() %||% answers$author
  e <- try_quietly(email_address()) %||% ""
  paste0(n, " <", e, ">")
}

#' @importFrom whoami gh_username

default_url <- function(answers) {
  gh <- try_quietly(gh_username()) %||% "<gh-username>"
  name <- answers$name
  paste0("https://github.com/", gh, "/", name)
}

default_bugreports <- function(answers) {
  paste0(answers$url, "/issues")
}

#' @rdname survey
#' @export
#' @importFrom httr POST stop_for_status
#' @param answers The answers the builder operates on.

build <- function(answers) {

  ## Create Git/GitHub repos
  if (answers$create_git_repo) {
    ok <- create_git_repo(answers)
    if (!inherits(ok, "try-error") && answers$create_gh_repo) {
      token <- Sys.getenv("GITHUB_TOKEN")
      if (token != "") {
        create_gh_repo(answers, token)
      }
    }
  }
}

create_git_repo <- function(answers) {
  try({
    system("git init .")
    system("git add .")
    system("git commit -m \"Initial commit of Mason template\"")
  })
}

#' @importFrom httr POST add_headers status_code

create_gh_repo <- function(answers, token) {

  url <- "https://api.github.com/user/repos"
  auth <- c("Authorization" = paste("token", token))
  data <- paste0('{ "name": "', answers$name, '",',
                 '   "description": "', answers$title, '" }')
  response <- POST(
    url,
    body = data,
    add_headers("user-agent" = "https://github.com/gaborcsardi/mason",
                'accept' = 'application/vnd.github.v3+json',
                .headers = auth)
  )

  sc <- status_code(response)
  if (sc == 422) {
    warning("GitHub repository already exists")

  } else if (sc != 201) {
    warning("Could not create GitHub repository")

  }

  ok <- try({
    cmd <- paste0("git remote add origin git@github.com:",
                  answers$gh_username, "/", answers$name, ".git")
    system(cmd)
  })

  if (!inherits(cmd, "try-error") && answers$push_to_github) {
    try({
      system("git push -u origin master")
    })
  }
}