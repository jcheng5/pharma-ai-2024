library(elmer)
library(gt)

show_table <- . %>%
  gt() %>%
  fmt_markdown() %>%
  tab_style(cell_text(v_align = "top"), cells_body())

reviews <- tibble::tibble(
  review = c(
"I got this amp to drive Polk outdoor speakers. It combines a unique set of features including coax optical and RCA inputs plus it supports Bluetooth Aptx. The detail and imaging is excellent with a lot of subtlety. bass is clear and defined. Dynamics are very good. I have other amps such Arcam, Naim and Cambridge audio. Each cost 3x to 4x this unit and while they drive the tower 4 ohms speakers better this tiny amp holds its own especially for 8 ohm speakers ( bookshelf and smaller towers or outdoor speakers) the output is higher than the rated 35W and I can’t hear any distortion at high volumes.

The remote is basic but gets the job done. Think of this as a portable amp you can take with you. Perfect for outdoor use as it is light and small … easy to make a housing for. Alas remote fits in the pocket and easy to carry around. Also can put on desktop for driving headphones

The only con at this price is lack of USB input which is a shame given the high quality DAC.

Overall would recommend this NAD without hesitation.",
"I would love to have a reasonable stereo in a sleek 9\" x 9\" x 2\" box! It's a delight to set up.

I thought it sounded fine. I rated it at the level of a Marantz PM6006 and an $80 Micca Origain. Better than a Cambridge Topaz AM-10 and an Emotiva A-100, pretty disappointing that.) The DAC is fine, at the level of my HifiBerry Dac + Pro. That said, I don't really get what Stereophile Magazine was so excited about a few years ago.

The NAD lacked the power to drive KEF q100s to more than medium loud. (The Micca Origain did about the same, others could get louder, a 50W Rotel circa 2000 easily gets them past that.

Oddly, even when using the NAD as a preamp (pre-out, no speakers attached) for said Rotel the volume is similarly limited. Also oddly, the NAD generated much more heat as a preamp than the Rotel did as a power amp.",
"Muy buenos acabados. Ofrece muy buena calidad de sonido para el precio. Buena conectividad (USB, bluetooth, óptica...). La siguiente version (V2 3020) carece de entrada USB, por lo que prefería este.
Ocupa realmente muy poco, ideal para un PC o para quien no tenga espacio. Aunque soló son 30W de potencia, suelen ser suficientes para unos monitores de estudio de tamaño pequeño o mediano. Los tengo emparejados con unos Monitor Audio Bronze 2 y la combinación funciona perfectamente.",
"昔流行った「ネットブック」のタブレット版と考えればよいでしょう。
動画見るとかブラウザ使うとか、業務用途でもAndroidアプリがあるものなら、同じスペックでも動作が軽いAndroidタブレットを選んだほうが快適です。
この機器の一番のメリットは、Windows11のProfessionalエディションであること。
どうしてもWindowsでないといけない、でもノートパソコンではなくタブレットで、というときには有力な選択肢になります。
ただしスペックは本当に最小限なので、動作の遅さは覚悟してください。
２つ以上のアプリやウィンドウを同時に開くのも避けたほうがよいでしょう。"
  )
)

show_table(reviews)

predict_rating <- function(str_input) {
  lapply(str_input, function(str) {
    chat <- chat_openai(
      model = "gpt-4o",
      system_prompt = "Analyze each user message for sentiment. Grade from 0 (most negative) to 10 (most positive). Return the number, followed by a newline, followed by your reasoning (in concise English) for picking that value.\n\nExample response:\n\n9\nVery positive, with effusive praise for all aspects except for a minor inconvenience when replacing the battery."
    )
    resp <- chat$chat(str, echo = FALSE)
    lines <- strsplit(resp, "\n")[[1]]
    rating <- as.numeric(lines[[1]])
    if (is.na(rating)) {
      stop("Unexpected response format: ", resp)
    }
    rating_desc <- paste(tail(lines, -1), collapse = "\n")
    tibble::tibble_row(rating, rating_desc)
  }) |> dplyr::bind_rows()
}

df <- dplyr::bind_cols(reviews, predict_rating(reviews$review))
show_table(df)
