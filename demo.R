library(elmer)

# OPENAI_API_KEY environment variable comes from .Renviron
chat <- chat_openai()

#' Fetches the web page at the given URL and returns the body as a string.
#' @param url The URL to fetch.
get_webpage <- function(url, plaintext = FALSE) {
  resp <- httr2::request(url) |>
    httr2::req_perform()

  resp_str <- httr2::resp_body_string(resp)

  # Is the response text/html?
  if (isTRUE(plaintext) &&
    grepl("^text/html", httr2::resp_headers(resp)$`content-type`)) {
    # Load the HTML into rvest
    doc <- xml2::read_html(resp_str)
    # Extract the text
    rvest::html_text2(doc)
  } else {
    resp_str
  }
}

chat$register_tool(ToolDef(
  fun = get_webpage,
  name = "get_webpage",
  description = "Fetches the web page at the given URL and returns the body as a string.",
  arguments = list(
    url = ToolArg(
      type = "string",
      description = "The URL to fetch."
    ),
    plaintext = ToolArg(
      type = "boolean",
      description = "If true, fetches the page as plaintext. Defaults to false.",
      required = FALSE
    )
  )
))

# chat$chat("Summarize https://www.gutenberg.org/cache/epub/67098/pg67098.txt in 800 words")
