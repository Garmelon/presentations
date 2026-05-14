import VersoSlides
import Slides

open VersoSlides

def main (args : List String) : IO UInt32 := do
  let config : Config := { center := false, margin := 0 }
  let rc ← slidesMain (config := config) (doc := %doc Slides) (args := args)
  let outputDir := config.outputDir
  let cssContents ← IO.FS.readFile "../static/custom.css"
  let overrideContents ← IO.FS.readFile "overrides.css"
  IO.FS.writeFile (outputDir / "custom.css") (cssContents ++ "\n" ++ overrideContents)
  let logoBytes ← IO.FS.readBinFile "../static/lean-logo.png"
  IO.FS.writeBinFile (outputDir / "lean-logo.png") logoBytes
  let logoLargeBytes ← IO.FS.readBinFile "../static/lean-logo-large.png"
  IO.FS.writeBinFile (outputDir / "lean-logo-large.png") logoLargeBytes
  let miLogoBytes ← IO.FS.readBinFile "../static/mathlib-initiative-logo.svg"
  IO.FS.writeBinFile (outputDir / "mathlib-initiative-logo.svg") miLogoBytes
  let htmlPath := outputDir / "index.html"
  let html ← IO.FS.readFile htmlPath
  let html := html.replace "</head>" "<link rel=\"stylesheet\" href=\"custom.css\">\n    </head>"
  let html := html.replace "Reveal.initialize({" "Reveal.initialize({\n        disableLayout: true,"
  let titleSlideOld := "<section>\n          <h2>\n            Mathlib adaptation and downstream testing</h2>\n          <p>\n            Kim Morrison, Marcelo Lynch, Joscha Mennicken</p>\n          <p>\n            FRO + Mathlib offsite, 20 May 2026</p>\n          </section>"
  let titleSlideNew := "<section class=\"title-slide\">\n          <div class=\"top-area\"><img class=\"logo\" src=\"lean-logo-large.png\" alt=\"Lean Logo\"><img class=\"logo\" src=\"mathlib-initiative-logo.svg\" alt=\"Mathlib Initiative Logo\" style=\"margin-left: 1.5em;\"></div>\n          <div class=\"blue-band\"><h1>Mathlib adaptation and downstream testing</h1>\n          <div class=\"meta\"><strong>Kim Morrison, Marcelo Lynch, Joscha Mennicken</strong></div>\n          <div class=\"date\">FRO + Mathlib offsite | 20 May 2026</div>\n          </div></section>"
  let html := html.replace titleSlideOld titleSlideNew
  let slideHeader := "<div class=\"slide-header\"><img src=\"lean-logo.png\" alt=\"Lean\"></div>"
  let html := html.replace "<section>\n" s!"<section>\n          {slideHeader}\n"
  let html := html.replace "<section data-transition=\"fade\">\n" s!"<section data-transition=\"fade\">\n          {slideHeader}\n"
  -- On Hopscotch slides, swap the standard slide-header for an MI-themed one
  -- (logo on the right, green divider).
  let miHeader := "<div class=\"slide-header slide-header--mi\"><img src=\"mathlib-initiative-logo.svg\" alt=\"Mathlib Initiative\"></div>"
  let html := html.replace s!"{slideHeader}\n          <h2>\n            Hopscotch" s!"{miHeader}\n          <h2>\n            Hopscotch"
  IO.FS.writeFile htmlPath html
  return rc
