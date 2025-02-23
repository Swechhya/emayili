REGEX_BARE_LINEFEED = "(?<!\r)\n"

#' Pipe operator
#'
#' \link[magrittr]{%>%}
#'
#' @name %>%
#' @rdname pipe
#' @keywords internal
#' @export
#' @importFrom magrittr %>%
#' @usage lhs \%>\% rhs
NULL

# For adding elements to a list using %>%.
#
set <- .Primitive("[[<-")

#' Compare vectors
#'
#' Returns \code{TRUE} wherever elements are the same (including \code{NA}),
#' and \code{FALSE} everywhere else.
#'
#' @param lhs LHS of operation.
#' @param rhs RHS of operation.
#'
#' @return A Boolean value.
compare <- function(lhs, rhs) {
  same <- (lhs == rhs) | (is.na(lhs) & is.na(rhs))
  same[is.na(same)] <- FALSE
  same
}

#' Read entire text file into character vector
#'
#' @noRd
#'
#' @inheritParams stringr::str_c
#' @param path Relative or absolute file path. This can also be a vector of
#'             paths, in which case their content is concatenated.
#'
#' @return A character vector
read_text <- function(path, collapse = "\n") {
  map_chr(path, function(p) {
    if (!file.exists(p)) stop("Unable to find file: ", p, ".")
    readChar(p, file.info(p)$size)
  }) %>%
    str_c(collapse = collapse)
}

#' Read entire binary file into character vector
#'
#' @noRd
#'
#' @param path Relative or absolute file path
#'
#' @return A character vector
read_bin <- function(path) {
  readBin(path, "raw",  file.info(path)$size)
}

#' Normalise file path
#'
#' @noRd
#'
#' @param path Relative or absolute file path
#'
#' @return An absolute file path (if the file exists) or \code{NA}.
normalise_filepath <- function(path) {
  possibly(normalizePath, NA_character_)(path, mustWork = TRUE)
}

#' Check if character vector is a file name or file path
#'
#' @noRd
#'
#' @param path A character vector (which might also be a file path)
#'
#' @return If it is a file path, then return \code{TRUE}, otherwise return \code{FALSE}.
is_filepath <- function(path) {
  !is.na(normalise_filepath(path))
}

hexkey <- function(object = runif(1), algorithm="crc32") {
  digest(object, algorithm)
}

#' Drape line feeds
#'
#' Replace empty line-feeds, "\n", with carriage-return and line-feed, "\r\n".
#'
#' @noRd
drape_linefeed <- function(txt) {
  str_replace_all(txt, REGEX_BARE_LINEFEED, "\r\n")
}

#' Remove comments from CSS
#'
#' Will handle comments with the following form:
#'
#' - /* ... */
#' - /*! ... */
#'
#' @noRd
css_remove_comment <- function(css) {
  str_replace_all(css, "/\\*!?(\\*(?!/)|[^\\*])*\\*/", "")
}

#' Remove gratuitous whitespace from HTML
#'
#' @param html HTML content as character vector.
#'
#' @noRd
html_squish <- function(html) {
  html %>%
    # Remove duplicate \n (when surrounded by whitespace and tags).
    #
    # <div>\n\n\n<p>foo \n\n bar</p>\n\n</div> -> <div>\n<p>foo \n\n bar</p>\n</div>
    #
    str_replace_all("(?<=>) *(\n)+ *(?=<)", "\n") %>%
    # Remove just whitespace between tags.
    #
    # <div>  <p>foo    bar</p>  </div>         -> <div><p>foo    bar</p></div>
    #
    str_replace_all("(^|(?<=>)) +($|(?=<))", "")
}

mime_base64encode <- function(raw, linewidth = 76L) {
  if (is.raw(raw)) {
    log_debug("Input is already raw.")
  } else {
    if (file.exists(raw)) {
      log_debug("Assuming that input is a file.")
    } else {
      log_debug("Assuming that input is not a file.")
      if (is.character(raw)) {
        raw <- charToRaw(raw)
      } else {
        raw <- as.raw(raw)
      }
    }
  }

  base64encode(
    raw,
    linewidth,
    "\r\n"
  )
}

#' Generate MD5 checksum for Content-MD5 header field
#'
#' The MD5 checksum is a 128 bit digest. This corresponds to 16 bytes (octets)
#' of binary data. These 16 bytes are then Base64 encoded.
#'
#' @noRd
#'
#' @param object An arbitrary R object.
#'
#' @return Base64 encoded MD5 checksum.
#'
#' @examples
#' # Result should be "XrY7u+Ae7tCTyyK7j1rNww==".
#' md5("hello world")
md5 <- function(object) {
  digest(object, algo = "md5", serialize = FALSE, raw = TRUE) %>%
    mime_base64encode()
}

parse_datetime <- function(datetime, tz) {
  as.POSIXct(datetime, tz)
}

#' Format date
#'
#' Format like "Fri, 08 Oct 2021 22:06:39 -0700 (PDT)".
#'
#' @noRd
format_datetime <- function(datetime) {
  strftime(datetime, "%a, %d %b %Y %H:%M:%S %z (%Z)")
}

#' Enclose in angle brackets
#'
#' @noRd
wrap_angle_brackets <- function(x) {
  if (!grepl("^<", x)) x <- paste0("<", x)
  if (!grepl(">$", x)) x <- paste0(x, ">")
  x
}


#' Test if list is nested or flat
#'
#' @noRd
#' @param x A list.
#' @return A Boolean.
is.nested <- function(x) {
  stopifnot(is.list(x))
  any(sapply(x, function(x) any(class(x) == "list")))
}
