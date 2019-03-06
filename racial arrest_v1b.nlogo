poc-own [crime-now jail-sentence true-recidivism]
caucasians-own [crime-now jail-sentence true-recidivism]
cops-own [hm-arrested-poc hm-arrested-cau]
patches-own [ stigma
  arrested-poc arrested-caucasians
  crime-count-poc crime-count-caucasians
  n00-poc n10-poc n01-poc n11-poc n00-cau n10-cau n01-cau n11-cau]
globals [crime-rate recidivism-rate
  FPR-poc FNR-poc FPR-cau FNR-cau PPV-poc PPV-cau
  prevalence-poc prevalence-cau
  pA-poc pA-cau
  diffPPV diffFPR diffFNR
;  generation-period
;  arrested-poc-historic arrested-caucasians-historic
;  cumulative-population-poc cumulative-population-cau
  population-size arrest-proportion tau-population tau-arrest
]

breed [poc a-poc]
breed [caucasians caucasian]
breed [cops cop]

to setup
  clear-all
  ask patches [
    ifelse (pycor < 0) [ set pcolor violet - 2 ] [ set pcolor violet + 2 ]
  ]

  set population-size 100;250 was used for first resutls ;750 was good too, with 1% crime rate

  my-create-poc population-size

  my-create-caucasians population-size
  ; actually in the future i would make poc and caucasians the same breed (say, civilians
  ; but would change a property of them, like color, that determines how/where they move)

  my-create-cops 10 q0

  set crime-rate 10 ;10 if 750 population ;10 for RL and arrested scenarios

  set recidivism-rate 40

;  set generation-period 1000
;
;  set arrested-poc-historic [0]
;  set arrested-caucasians-historic [0]

  reset-ticks
end

to my-create-poc [number-to-create]
    create-poc number-to-create [
    setxy random-xcor abs random-ycor
    set color black]
end

to my-create-caucasians [number-to-create]
  create-caucasians number-to-create [
    setxy random-xcor (- abs random-ycor)
    set color white]
end

to my-create-cops [number-to-create biased-proportion]
  create-cops biased-proportion [
    setxy random-xcor max-pycor / 2 + abs random-ycor / 2
    set color blue
  ]
  create-cops number-to-create - biased-proportion [
    setxy random-xcor (min-pycor / 2 - abs random-ycor / 2)
    set color blue
  ]
end

to go
;  let nticks ticks
;  if ((nticks > 0) and ((nticks mod renewal-period) = 0)) [;new-generation
;    set arrested-poc-generational 0
;    set arrested-caucasians-generational 0]

  ask poc [
    move-poc
    crime-not-crime
  ]
  ask caucasians [
    move-caucasians
    crime-not-crime
  ]
  ask cops [
    move-cops
    arrest
  ]

;  let number-of-arrests-poc (sum [hm-arrested-poc] of cops)
;  let number-of-arrests-cau (sum [hm-arrested-cau] of cops)
;  set arrested-poc-historic lput number-of-arrests-poc arrested-poc-historic
;  set arrested-caucasians-historic lput number-of-arrests-cau arrested-caucasians-historic
;
;  ; I guess after 100 I could erase the first?
;  if length arrested-poc-historic > generation-period [ set arrested-poc-historic remove-item 0 arrested-poc-historic ]
;  if length arrested-caucasians-historic > generation-period [set arrested-caucasians-historic remove-item 0 arrested-caucasians-historic]


  set FPR-poc compute-FPR-poc
  set FPR-cau compute-FPR-cau
  set FNR-poc compute-FNR-poc
  set FNR-cau compute-FNR-cau
  set PPV-poc compute-PPV-poc
  set PPV-cau compute-PPV-cau

  ; the following should be averaged over time, maybe every 50 steps or so
  set pA-poc compute-pA-poc
  set pA-cau compute-pA-cau
  set prevalence-poc compute-prevalence-poc pA-poc
  set prevalence-cau compute-prevalence-cau pA-cau

  set diffPPV ((PPV-poc * pA-poc) - (PPV-cau * pA-cau))
  set diffFPR ( (FPR-poc * pA-poc) - (FPR-cau * pA-cau) )
  set diffFNR ( (FNR-poc * pA-poc) - (FNR-cau * pA-cau) )

  set arrest-proportion compute-arrest-proportion

  set tau-arrest compute-tau-arrest
  set tau-population compute-tau-population



  ; At the end, I think I should just have a very large population and let it run for a while (without replacing arrested), and recover one value,
  ; then reset population, change theta, leave stigma field, run again for a long period, etc.

  tick
end

; ##### ::::: Fairness Metrics ::::: #####
to-report compute-arrest-proportion
  ifelse (sum [arrested-caucasians] of patches) > 0 [
    report ( (sum [arrested-poc] of patches) / (sum [arrested-caucasians] of patches) ) ] [
    report 0
  ]
end

to-report compute-tau-arrest
  let f1 0
  let f2 0
  let f3 0
  if FPR-cau > 0 [set f1 abs(1 - FPR-poc / FPR-cau)]
  if FNR-cau > 0 [set f2 abs(1 - FNR-poc / FNR-cau)]
  if PPV-cau > 0 [set f3 abs(1 - PPV-poc / PPV-cau)]
  report ( f1 + f2 + f3 )
end

to-report compute-tau-population
  let f1 0
  let f2 0
  let f3 0
  if FPR-cau > 0 [set f1 abs(1 - arrest-proportion * (FPR-poc / FPR-cau))]
  if FNR-cau > 0 [set f2 abs(1 - arrest-proportion * (FNR-poc / FNR-cau))]
  if PPV-cau > 0 [set f3 abs(1 - (PPV-poc / PPV-cau))]
  report ( f1 + f2 + f3 )
end

to-report compute-pA-poc
  report (sum [arrested-poc] of patches) / population-size
;  report (sum [arrested-poc] of patches) / (100 + cumulative-population-poc)

  ;report (sum arrested-poc-historic) / 100

;  ifelse ticks < generation-period [
;    report (sum [arrested-poc] of patches) / 100 ] [
;;    let last-index (length arrested-poc-historic) - 1
;;    let arrested-window sublist arrested-poc-historic (last-index - generation-period) last-index
;    report (sum arrested-poc-historic) / 100 ]
end

to-report compute-pA-cau
  report (sum [arrested-caucasians] of patches) / population-size
;  report (sum [arrested-caucasians] of patches) / (100 + cumulative-population-cau)

  ;report (sum arrested-caucasians-historic) / 100

;  ifelse ticks < generation-period [
;    report (sum [arrested-caucasians] of patches) / 100 ] [
;;    let last-index (length arrested-caucasians-historic) - 1
;;    let arrested-window sublist arrested-caucasians-historic (last-index - generation-period) last-index
;    report (sum arrested-caucasians-historic) / 100 ]
end

to-report compute-prevalence-poc [pa]
  ;report (sum [n11-poc] of patches + sum [n01-poc] of patches) / 100 ;idem
  report recidivism-rate * pa
end

to-report compute-prevalence-cau [pa]
  ;report (sum [n11-cau] of patches + sum [n01-cau] of patches) / 100 ;idem
  report recidivism-rate * pa
end

to-report compute-PPV-poc
  let njail-poc (sum [n11-poc] of patches + sum [n10-poc] of patches)
  ifelse (njail-poc > 0) [
    report (( sum [n11-poc] of patches ) / njail-poc)] [
    report 0]
end

to-report compute-PPV-cau
  let njail-cau (sum [n11-cau] of patches + sum [n10-cau] of patches)
  ifelse (njail-cau > 0) [
    report (( sum [n11-cau] of patches ) / njail-cau)] [
    report 0]
end

to-report compute-FPR-poc
  let n0-poc (sum [n10-poc] of patches + sum [n00-poc] of patches)
  ifelse (n0-poc > 0) [
    report ((sum [n10-poc] of patches) / n0-poc) ] [
    report 0]
end

to-report compute-FPR-cau
  let n0-cau (sum [n10-cau] of patches + sum [n00-cau] of patches)
  ifelse (n0-cau > 0) [
    report ( (sum [n10-cau] of patches) / n0-cau ) ] [
    report 0]
end

to-report compute-FNR-poc
  let n1-poc ( sum [n01-poc] of patches + sum [n11-poc] of patches )
  ifelse (n1-poc > 0) [
    report ( (sum [n01-poc] of patches) / n1-poc ) ] [
    report 0 ]
end

to-report compute-FNR-cau
  let n1-cau ( sum [n01-cau] of patches + sum [n11-cau] of patches )
  ifelse ( n1-cau > 0 ) [
    report ( (sum [n01-cau] of patches) / n1-cau ) ] [
    report 0]
end


; ###### Dynamics #####
to move-poc
  right random 360
  if (dy > 0 and ycor > max-pycor - 1) or (dy < 0 and ycor < 1 ) [ set heading 180 - heading ]
  forward 1
end

to move-caucasians
  right random 360
  if (dy > 0 and ycor > (- 1) ) or (dy < 0 and ycor < min-pycor + 1 ) [set heading 180 - heading ]
  forward 1
end

to move-cops
  if (random 100 < theta) [
    uphill stigma
  ]
  right random 360
  ifelse (random 100 < 10) [forward 3] [forward 1] ;definitely edit these parameters
end

to crime-not-crime
  ifelse (random 1000 < crime-rate) [
    set crime-now 1
    set color red
    ifelse (breed = poc) [
      set crime-count-poc crime-count-poc + 1 ] [
      set crime-count-caucasians crime-count-caucasians + 1]
    ] [
    set crime-now 0
    ifelse (breed = poc) [ set color black ] [set color white]
  ]
end

to arrest
  set hm-arrested-poc count ((poc-on neighbors) with [crime-now = 1])
  ask (poc-on neighbors) with [crime-now = 1] [
    go-prison
  ]

  set hm-arrested-cau count ((caucasians-on neighbors) with [crime-now = 1])
  ask (caucasians-on neighbors) with [crime-now = 1] [
    go-prison
  ]
end

to go-prison
  add-stigma

  add-arrested-count

  be-judged

  do-recidivate

  update-n-matrix

  be-replaced ; only after some amount of ticks?

  die
end

to update-n-matrix
  ifelse (breed = poc) [
    ifelse (true-recidivism = 0) [
      ifelse (jail-sentence = 1) [set n10-poc n10-poc + 1] [set n00-poc n00-poc + 1] ] [
      ifelse (jail-sentence = 1) [set n11-poc n11-poc + 1] [set n01-poc n01-poc + 1]
    ]
  ] [
    ifelse (true-recidivism = 0) [
      ifelse (jail-sentence = 1) [set n10-cau n10-cau + 1] [set n00-cau n00-cau + 1] ] [
      ifelse (jail-sentence = 1) [set n11-cau n11-cau + 1] [set n01-cau n01-cau + 1]
    ]
  ]

end

to be-judged
;  let pos-classif-rate ( (sum [arrested-poc] of patches) / (sum [arrested-poc] of patches + sum [arrested-caucasians] of patches) )
;  ifelse (breed = poc) [
;    ifelse (random 100 < (100 * pos-classif-rate)) [
;      set jail-sentence 1 ] [
;      set jail-sentence 0 ]
;  ] [
;    ifelse (random 100 < 100 * (1 - pos-classif-rate) )[
;      set jail-sentence 1] [
;      set jail-sentence 0 ]
;    ]

  ; simple indep rand classifier:
  let classif-rate 30
  ifelse (random 100 < classif-rate) [
    set jail-sentence 1] [
    set jail-sentence 0]

end

to do-recidivate
  ifelse (random 100 < recidivism-rate) [
    set true-recidivism 1 ] [
    set true-recidivism 0 ]
end

to add-stigma
  ifelse (breed = poc) [
    set stigma stigma + 3 ; Even with same stgma field increase we get inequality. try 6-3, 3-1, and 3-1, 3-1
    ask neighbors [set stigma stigma + 1] ] [
    set stigma stigma + 3
    ask neighbors [set stigma stigma + 1 ] ]
end

to add-arrested-count
  ifelse (breed = poc) [
    set arrested-poc arrested-poc + 1 ] [
    set arrested-caucasians arrested-caucasians + 1 ]
end

to new-generation
  let new-poc (100 - count poc)
  ask n-of new-poc patches [
    sprout-poc 1 [
    setxy random-xcor abs random-ycor
    set color black]  ]

  let new-cau (100 - count caucasians)
  ask n-of new-cau patches [
    sprout-caucasians 1 [
    setxy random-xcor (- abs random-ycor)
    set color white ] ]
end

to be-replaced
  ifelse (breed = poc) [
    ask n-of 1 patches [
      sprout-poc 1 [
        setxy random-xcor abs random-ycor
        set color black
  ] ]
;    set cumulative-population-poc (cumulative-population-poc + 1)
  ] [
    ask n-of 1 patches [
      sprout-caucasians 1 [
        setxy random-xcor (- abs random-ycor)
        set color white
  ] ]
;    set cumulative-population-cau (cumulative-population-cau + 1)
  ]
end
@#$#@#$#@
GRAPHICS-WINDOW
1146
468
1409
732
-1
-1
7.73
1
10
1
1
1
0
1
0
1
-16
16
-16
16
1
1
1
ticks
30.0

BUTTON
56
14
119
47
NIL
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
166
13
229
47
NIL
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
0

PLOT
1036
55
1295
229
arrested people
NIL
NIL
0.0
10.0
0.0
10.0
true
true
"" ""
PENS
"POC" 1.0 0 -16777216 true "" "plot sum [arrested-poc] of patches"
"Cau" 1.0 0 -13345367 true "" "plot sum [arrested-caucasians] of patches"

SLIDER
55
62
227
95
theta
theta
0
100
100.0
1
1
NIL
HORIZONTAL

PLOT
62
138
336
326
FPR
NIL
NIL
0.0
10.0
0.0
0.5
true
true
"" "set-plot-y-range -.1 .1"
PENS
"old" 1.0 0 -2674135 true "" "plot FPR-poc - FPR-cau"
"new" 1.0 0 -13345367 true "" "plot (FPR-poc * pA-poc - FPR-cau * pA-cau)"

PLOT
63
331
335
509
FNR
NIL
NIL
0.0
10.0
0.0
1.0
true
true
"" "set-plot-y-range -.1 .1"
PENS
"old" 1.0 0 -2674135 true "" "plot FNR-poc - FNR-cau"
"new" 1.0 0 -13345367 true "" "plot (FNR-poc * pA-poc - FNR-cau * pA-cau)"

PLOT
61
522
336
696
PPV
NIL
NIL
0.0
10.0
0.0
1.0
true
true
"" "set-plot-y-range .05 .07"
PENS
"old" 1.0 0 -2674135 true "" "plot PPV-poc - PPV-cau"
"new" 1.0 0 -13345367 true "" "plot diffPPV"

PLOT
1243
337
1403
457
probability of arrest pA
NIL
NIL
0.0
10.0
0.0
1.0
true
true
"" ""
PENS
"poc" 1.0 0 -13345367 true "" "plot pA-poc"
"cau" 1.0 0 -2674135 true "" "plot pA-cau"

PLOT
407
14
815
294
ERB and PP
NIL
NIL
0.0
10.0
0.0
0.01
true
true
"" "set-plot-y-range -.2 1"
PENS
"Delta-FPR" 1.0 0 -2674135 true "" "plot FPR-poc - FPR-cau"
"Delta-FNR" 1.0 0 -13840069 true "" "plot FNR-poc - FNR-cau"
"Delta-ppv" 1.0 0 -13345367 true "" "plot PPV-poc - PPV-cau"

PLOT
430
567
775
708
Proportion arrested
NIL
NIL
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -2674135 true "" "plot arrest-proportion"

PLOT
413
315
685
474
Arrest Proportions
NIL
NIL
0.0
10.0
0.0
10.0
true
true
"" ""
PENS
"Tau_A" 1.0 0 -2674135 true "" "plot tau-arrest"

PLOT
784
316
1067
471
Population Proportions
NIL
NIL
0.0
10.0
0.0
10.0
true
true
"" ""
PENS
"Tau_P" 1.0 0 -2674135 true "" "plot tau-population"

SLIDER
55
98
227
131
q0
q0
5
10
8.0
1
1
NIL
HORIZONTAL

@#$#@#$#@
## WHAT IS IT?

(a general understanding of what the model is trying to show or explain)

## HOW IT WORKS

(what rules the agents use to create the overall behavior of the model)

## HOW TO USE IT

(how to use the model, including a description of each of the items in the Interface tab)

## THINGS TO NOTICE

(suggested things for the user to notice while running the model)

## THINGS TO TRY

(suggested things for the user to try to do (move sliders, switches, etc.) with the model)

## EXTENDING THE MODEL

(suggested things to add or change in the Code tab to make the model more complicated, detailed, accurate, etc.)

## NETLOGO FEATURES

(interesting or unusual features of NetLogo that the model uses, particularly in the Code tab; or where workarounds were needed for missing features)

## RELATED MODELS

(models in the NetLogo Models Library and elsewhere which are of related interest)

## CREDITS AND REFERENCES

(a reference to the model's URL on the web if it has one, as well as any other necessary credits, citations, and links)
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.0.2
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180
@#$#@#$#@
0
@#$#@#$#@
