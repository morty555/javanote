#import "@preview/numbly:0.1.0": numbly
#import "@preview/theorion:0.3.3": *
#import cosmos.rainbow: *

#let (problem-counter, problem-box, problem, show-problem) = make-frame(
  "problem",
  "例",
  inherited-levels: 1,
  inherited-from: heading,
  render: render-fn.with(fill: rgb("#1F2421")),
)

#let (solution-counter, solution-box, solution, show-solution) = make-frame(
  "solution",
  "解",
  inherited-levels: 1,
  inherited-from: heading,
  numbering: _ => { (..x) => {} },
  render: render-fn.with(fill: rgb("216869")),
)

#let typst = {
  set text(
    size: 1.05em,
    font: "Buenard",
    weight: "bold",
    fill: rgb("#239dad"),
  )
  link("https://typst.app/", box({
    text("t")
    h(0.005em)
    text("y")
    h(0.04em)
    text("p")
    h(-0.025em)
    text("s")
    h(-0.015em)
    text("t")
  }))
}


#let template(body) = {
  set page(numbering: "1")
  set text(font: ("Libertinus Serif", "Noto Serif CJK SC"), lang: "zh")

  show title: set align(center)
  set heading(numbering: numbly(
    "{1:A}.",
    "{1:A}.{2:I}.",
    "{3}.",
  ))
  set par(justify: true)
  show table: set align(center)
  show table: block.with(width: 100%)
  show math.equation.where(block: true): block.with(
    width: 100%,
    breakable: true,
  )
  show math.equation.where(block: true): set block(breakable: true)

  show: show-theorion
  show: show-problem
  show: show-solution
  title()

  outline(depth: 2, title: none)
  set page(columns: 2)

  body

  place(
    bottom + right,
    [_Typeset by_ #h(0.15em) #typst _with_ #emoji.heart],
    float: true,
    scope: "parent",
  )
}

#let IP = math.op("IP")
#let SW = math.op("SW")
#let p10i = $(1,2,3,4,5,6,7,8,9,10)$.body
#let p8i = $(1,2,3,4,5,6,7,8)$.body
#let ticket = "Ticket"
#let TGS = "TGS"
#let r64 = "R64"
#let LD = "LD"
#let RD = "RD"
#let LE = "LE"
#let RE = "RE"
#let IV = "IV"
#let ID = "ID"
#let KR = "KR"
#let KU = "KU"
#let CV = "CV"
#let EP = "EP"
#let DP = "DP"
#let EC = "EC"
#let DC = "DC"
#let PIMD = "PIMD"
#let PI = "PI"
#let OIMD = "OIMD"
#let OI = "OI"
#let POMD = "POMD"
#let DS = "DS"
#let Sig = "Sig"
#let StreamKey = "StreamKey"
#let Request = "Request"
#let Time = "Time"
#let PKA = "PKA"
#let CA = "CA"
#let Cert = "Cert"
#let sgnData = "sgnData"

#let tag(body) = (
  box(
    outset: (y: 3pt),
    inset: (x: 3pt),
    fill: black.transparentize(95%),
    radius: 3pt,
    body,
  )
)
#let strong-tag(body) = tag(text(red.darken(20%), strong(body)))
#let exam = strong-tag("考")
#let ask = strong-tag("问")

#let blank = tag("_")

