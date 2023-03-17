breed [passengers passenger]
breed [fire-spots a-fire-spot]
breed [smokes smoke]
globals [ max-separate-turn minimum-separation i]

passengers-own [
  safe-passenger?
  health
  energy
  target-exit
  other-passengers         ;; agentset of nearby turtles
  nearest-neighbor   ;; closest one of our flockmates
  exit-sign
  target-door
  ignore-doors
  passed-patches
  trajectory-color
  see-exit?
  see-sign?
  see-door?
  self-vision
  bound-forcex
  bound-forcey
  wall-forcex
  wall-forcey
  sign-forcex
  sign-forcey
  door-forcex
  door-forcey
  explore-forcex
  explore-forcey
  avoid-smokex
  avoid-smokey
  exit-forcex
  exit-forcey
  fire-forcex
  fire-forcey
  pre-dir-forcex
  pre-dir-forcey
  fx
  fy
  speedx
  speedy
  expect-speed
  pre-dir
  mass
  r
  m
]

smokes-own[
  level
]

patches-own[
  exits-patch?
  sign-patch?
  door-patch?
  busy-patch?
  wall-patch?
  accessible-patch?
  withFire-patch?
  direction
]

to setup-map
  __clear-all-and-reset-ticks
  set max-separate-turn 10
  set minimum-separation 1.5
  resize-world -120 120 -60 60
  initialize-map
  reset-ticks
end

to setup-selfdefine
  __clear-all-and-reset-ticks
  set max-separate-turn 10
  set minimum-separation 1.5
  resize-world -120 120 -60 60
  import-pcolors "images/blank.bmp"
  reset-ticks
end

to set-agent
  initialize-passengers
  initialize-fire
end

to go
  spread-fire
  spread-smoke
  move-passengers
  tick
end

to initialize-map
  import-pcolors "images/map.png"
  ask patches [
  if pcolor < 9.9 or pcolor = 127.1
    [set wall-patch? True
      set pcolor 0]
  if pcolor = 137.1
    [set pcolor pink
    set exits-patch? True]
  if 14 < pcolor and pcolor < 18
    [
      set sign-patch? True
      set direction 180; set direction to down
      ifelse show-sign = True
      [set pcolor 14.8]
      [set pcolor 9.9]]
  if 35 < pcolor and pcolor < 44
    [
      set sign-patch? True
      set direction 90; set direction to right
      ifelse show-sign = True
      [set pcolor 40]
      [set pcolor 9.9]]
  if 55 < pcolor and pcolor < 64
    [
      set sign-patch? True
      set direction 360; set direction to up
      ifelse show-sign = True
      [set pcolor 57]
      [set pcolor 9.9]]
  if 104 < pcolor and pcolor < 110
    [
      set sign-patch? True
      set direction 270; set direction to left
      ifelse show-sign = True
      [set pcolor 107]
      [set pcolor 9.9]]
  if 44 < pcolor and pcolor < 49
    [
      set door-patch? True
      set direction 180; set direction to down
      ifelse show-sign = True
      [set pcolor 46]
      [set pcolor 9.9]
]
  if 66 < pcolor and pcolor < 69.1
    [
      set door-patch? True
      set direction 270; set direction to left
      ifelse show-sign = True
      [set pcolor 67]
      [set pcolor 9.9]]
  if 117 < pcolor and pcolor < 120
    [
      set door-patch? True
      set direction 360; set direction to up
      ifelse show-sign = True
      [set pcolor 118]
      [set pcolor 9.9]]
  ]

    ask patches [
    ifelse pcolor = white and pcolor = cyan and pcolor = pink
    [
      set accessible-patch? true
    ]
    [ set accessible-patch? false
    ]
  ]
end

to initialize-passengers

  create-passengers  passenger-count[
    set shape "person business"
    set color brown
    setxy random-xcor random-ycor
    set trajectory-color random-float 255
    set size 3
    set r 1
    set m 1
    set health 100
    set energy 100
    set safe-passenger? True
    set self-vision vision
    set color yellow
    set ignore-doors list (patch 0 0) (patch 1 1)
    set speedx random-float 2
    set speedy random-float 2
    set mass 40 + random 40
    move-to one-of patches with [ pcolor = white and pxcor < 0  ]
    set passed-patches list patch-here patch-ahead 1
  ]

end

to initialize-fire
ask n-of fire-count patches with [pcolor = white and pxcor < 0]
  [
      sprout-fire-spots 1
      [
      set shape "fire"
      set color red
      set size 2
      set withFire-patch? true
      ]
  ]
end

to create-wall ; create obstacle using mouse click
  if timer > .2 and mouse-down?[
    reset-timer
    ask patch mouse-xcor mouse-ycor
    [
    set pcolor black
    set wall-patch? True
    ]
    ask patch (mouse-xcor + 120) mouse-ycor
    [
    set pcolor black
    set wall-patch? True
    ]
  ]
  display
end

to create-exit ; create obstacle using mouse click
  if timer > .2 and mouse-down?[
    reset-timer
    ask patch mouse-xcor mouse-ycor
    [
    set pcolor pink
    set exits-patch? True
    ]
    ask patch (mouse-xcor + 120) mouse-ycor
    [
    set pcolor pink
    set exits-patch? True
    ]
  ]
  display
end

to delete-wall ; create obstacle using mouse click
  if timer > .2 and mouse-down?[
    reset-timer
    ask patch mouse-xcor mouse-ycor
    [
    set pcolor white
    set exits-patch? False
    ]
    ask patch (mouse-xcor + 120) mouse-ycor
    [
    set pcolor white
    set exits-patch? False
    ]
  ]
  display
end

to delete-exit ; create obstacle using mouse click
  if timer > .2 and mouse-down?[
    reset-timer
    ask patch mouse-xcor mouse-ycor
    [
    set pcolor white
    set exits-patch? False
    ]
    ask patch (mouse-xcor + 120) mouse-ycor
    [
    set pcolor white
    set exits-patch? False
    ]
  ]
  display
end

to spread-fire
  ask n-of 100 patches with [pcolor = white or pcolor = grey]
  [
    if any? neighbors with [count fire-spots-here > 0] [
      sprout-fire-spots 1 [
        set shape "fire"
        set color red
        set size 2
        set withFire-patch? true
      ]
    ]
  ]
end

to spread-smoke
  ask fire-spots [
    ask neighbors with [pcolor != black][
      let seed random 200
      if seed > spread-speed[
        ifelse any? smokes-here
        [
          ask smokes-here
          [
            set level 100
          ]
        ]
        [
          sprout-smokes 1 [
            set shape "circle"
            set color 5
            set color lput 50 extract-rgb color
            set size 2
            set level 100
          ]
        ]
      ]
    ]
  ]
  ask smokes [
    set level level - 0.1
    if level <= 5
    [die]
    set color ((100 - level) / 20)
    set color lput 50 extract-rgb color
    let lev level
    ask neighbors with [pcolor != black][
      let seed random 200
      if seed > spread-speed[
        ifelse any? smokes-here
        [
          ask smokes-here
          [
            set level max list level lev - spread-cost
          ]
        ]
        [
          sprout-smokes 1 [
            set shape "circle"
            set color 5
            set color lput 50 extract-rgb color
            set size 2
            set level lev - spread-cost
          ]
        ]
      ]
    ]
  ]

end

;to set-target-exists
;  set target-exit min-one-of patches with [pcolor = 137.1] [distance myself]
;end
;
;to set-exit-sign
;  set exit-sign patches with [direction > 0]
;end

to move-passengers
  ask passengers with [safe-passenger? = True]
  [
    if ticks = 50 * r
    [
    set r r + 1
    set pre-dir random 360
    ]
    if ticks = 300 * m
    [
    set m m + 1
    set passed-patches list patch-here patch-ahead 1
    set ignore-doors list (patch 0 0) (patch 1 1)
    ]
    set expect-speed panic-rate * speed-init + speed-init
    set expect-speed energy * expect-speed / 100
    update-force
    update-health
    update-energy
    bonding-force
    update-object-inview
    ifelse see-exit?
    [
      go-exits
    ]
    [
      ifelse see-door? and see-sign?
      [
        ifelse distance target-door > distance exit-sign
        [
          go-with-sign
        ]
        [
          go-with-door
        ]
      ]
      [
        if see-sign?
        [
          go-with-sign
        ]
        if see-door?
        [
          go-with-door
        ]
      ]
    ]
    if count smokes in-radius self-vision > 500
    [
      avoid-smoke
    ]
    explore-path 0.02
    if see-fire
    [
      avoid-fire
    ]
    avoid-fire
    no-wall
    let colour trajectory-color
    if Trajectory = True and who < 10
    [
    ask patch (xcor + 120) ycor [set pcolor colour]
    ]
    go-toward-exits
  ]
end

to update-force
  set bound-forcex 0
  set bound-forcey 0
  set wall-forcex 0
  set wall-forcey 0
  set sign-forcex 0
  set sign-forcey 0
  set explore-forcex 0
  set explore-forcey 0
  set exit-forcex 0
  set exit-forcey 0
  set door-forcex 0
  set door-forcey 0
  set fire-forcex 0
  set fire-forcey 0
  set pre-dir-forcex 0
  set pre-dir-forcey 0
  set avoid-smokex 0
  set avoid-smokey 0
end

to update-object-inview
  set see-exit? see-exit
  set see-sign? see-sign
  set see-door? see-door
end

to update-energy
  let speed-now sqrt(speedx ^ 2 + speedy ^ 2)
  ifelse speed-now > (speed-init) * health / 100
  [
    set energy energy - exp((expect-speed - speed-now) / (0.5 * expect-speed))
    if energy < 0
    [
      set energy 0
    ]
  ]
  [
    ifelse energy > health
    [
      set energy health
    ]
    [
      set energy energy + exp((speed-now - expect-speed ) / (0.5 * expect-speed))
    ]
  ]
end

to update-health
  if health < 0
  [
    set color black
    set safe-passenger? False
  ]
  if count smokes-here > 0
  [
    set health health - 0.003 * [level] of one-of smokes-here
  ]
  if count fire-spots in-radius 1 > 0
  [
    set color black
    set safe-passenger? False
  ]

end

to update-vison
  if count smokes-here > 0
  [
    set self-vision vision - (vision - bound) * 0.01 * [level] of one-of smokes-here
  ]

end

to-report see-exit
  let exit-set patches in-radius self-vision with [exits-patch? = True and detect-obscuration self]
  ifelse count exit-set > 0
  [set target-exit min-one-of exit-set [distance myself]
    report True]
  [report False]
end

to-report see-door
  let door-set patches in-radius self-vision with [door-patch? = True and (not member? self ([ignore-doors] of myself)) and detect-obscuration self]
  ifelse count door-set > 0
  [set target-door min-one-of door-set [distance myself]
  report True]
  [report False]
end

to-report see-fire
  let fire-set fire-spots in-radius self-vision with [withFire-patch? = True and detect-obscuration self]
  ifelse count fire-set > 0
  [report True]
  [report False]
end

to-report see-sign
  let sign-set patches in-radius self-vision with [sign-patch? = True and detect-obscuration self]
  ifelse count sign-set > 0
  [set exit-sign  min-one-of sign-set [distance myself]
  report True
  ]
  [report False]
end

to-report detect-obscuration [pch]
  let ans True
  ask myself [let dis distance pch
  let n 0
  while [n < dis]
  [ if [pcolor] of patch-at-heading-and-distance towards pch n = black [set ans False]
  set n n + 0.9]
  ]
  report ans
end

to explore-path [f] ;; turtle procedure
  ;; We can't just average the heading variables here.
  ;; For example, the average of 1 and 359 should be 0,
  ;; not 180.  So we have to use trigonometry.
  if not member? patch-here passed-patches
  [
  ifelse length passed-patches <= 10000
  [set passed-patches insert-item (length passed-patches - 1) passed-patches patch-here]
  [
   set passed-patches but-last passed-patches
   set passed-patches insert-item 0 passed-patches patch-here ]
  ]
;  let x-component 0
;  let y-component 0
;  foreach passed-patches [ x -> set x-component x-component + [pxcor] of x]
;  foreach passed-patches [ x -> set y-component y-component + [pycor] of x]
;  if x-component != 0 and y-component != 0
;    [ let turn subtract-headings heading (atan x-component y-component)
;      ifelse abs turn > 5 * flock-rate
;      [ifelse (turn) > 0
;        [ rt 5 * flock-rate ]
;        [ lt 5 * flock-rate ] ]
;      [rt turn]
;    ]
  let x-component 0
  let y-component 0
  foreach passed-patches [ x -> set x-component x-component + (xcor - ([pxcor] of x)) ]
  foreach passed-patches [ x -> set y-component y-component + (ycor - ([pycor] of x))]
  if x-component != 0 and y-component != 0
    [ let turn (atan x-component y-component)
      set explore-forcex explore-forcex + f * mass * ((expect-speed * sin(turn)) - speedx) / reaction-time
      set explore-forcey explore-forcey + f * mass * ((expect-speed * cos(turn)) - speedy) / reaction-time
    ]

end

to avoid-smoke
  let temx 0
  let temy 0
  ask patches in-radius self-vision with [pcolor = white]; self is me. myself is the agent who is asking me to do whatever I'm doing now.
  [
    if [pxcor] of self != [xcor] of myself and [pycor] of self != [ycor] of myself
    [
    set temx temx - 0.0001 * ([mass] of myself) * (([expect-speed] of myself * sin(towards myself)) - [speedx] of myself) / reaction-time
    set temy temy - 0.0001 * ([mass] of myself) * (([expect-speed] of myself * cos(towards myself)) - [speedy] of myself) / reaction-time
    ]
  ]
  set avoid-smokex avoid-smokex + temx
  set avoid-smokey avoid-smokey + temy
end

to go-exits
;  let turn subtract-headings towards target-exit heading
;    ifelse abs turn > 10
;    [ ifelse turn > 0
;        [ rt 10 ]
;        [ lt 10 ] ]
;    [ rt turn ]
  set exit-forcex exit-forcex + 1.2 * mass * ((expect-speed * sin(towards target-exit)) - speedx) / reaction-time
  set exit-forcey exit-forcey + 1.2 * mass * ((expect-speed * cos(towards target-exit)) - speedy) / reaction-time

end

to go-with-sign
;    let turn (subtract-headings ([direction] of exit-sign) heading)
;    if [pcolor] of patch-at-heading-and-distance turn 1 = white
;    [
;    ifelse abs turn > 10
;    [ ifelse turn > 0
;        [ rt 10 ]
;        [ lt 10 ] ]
;    [ rt turn ]
;    ]
  ask self[
  if [direction] of exit-sign = 90
  [
    let tar patch (xcor + self-vision) ycor
    ifelse detect-obscuration tar
    [
      set sign-forcex sign-forcex + 0.5 * mass * ((expect-speed - speedx) / reaction-time)
    ]
    [
        set sign-forcex sign-forcex - 10 * flock-rate * exp((distance myself - self-vision) / (self-vision)) * sin(towards tar)
        set sign-forcey sign-forcey - 10 * flock-rate * exp((distance myself - self-vision) / (self-vision)) * cos(towards tar )
    ]
  ]
  if [direction] of exit-sign = 180
  [
    set sign-forcey sign-forcey + 0.5 * mass * ((- expect-speed - speedy) / reaction-time)
    let tar patch xcor (ycor - self-vision)
    ifelse detect-obscuration tar
    [
      set sign-forcey sign-forcey + 0.5 * mass * ((- expect-speed - speedy) / reaction-time)
    ]
    [
        set sign-forcex sign-forcex - 10 * flock-rate * exp((distance myself - self-vision) / (self-vision)) * sin(towards tar)
        set sign-forcey sign-forcey - 10 * flock-rate * exp((distance myself - self-vision) / (self-vision)) * cos(towards tar )
    ]
  ]
  if [direction] of exit-sign = 270
  [
    set sign-forcex sign-forcex + 0.5 * mass * ((- expect-speed - speedx) / reaction-time)
    let tar patch (xcor - self-vision) ycor
    ifelse detect-obscuration tar
    [
      set sign-forcex sign-forcex + 0.5 * mass * ((- expect-speed - speedx) / reaction-time)
    ]
    [
        set sign-forcex sign-forcex - 10 * flock-rate * exp((distance myself - self-vision) / (self-vision)) * sin(towards tar)
        set sign-forcey sign-forcey - 10 * flock-rate * exp((distance myself - self-vision) / (self-vision)) * cos(towards tar )
    ]
  ]
  if [direction] of exit-sign = 360
  [
    set sign-forcey sign-forcey + 0.5 * mass * ((expect-speed - speedy) / reaction-time)
    let tar patch xcor (ycor + self-vision)
    ifelse detect-obscuration tar
    [
      set sign-forcey sign-forcey + 0.5 * mass * ((expect-speed - speedy) / reaction-time)
    ]
    [
        set sign-forcex sign-forcex - 10 * flock-rate * exp((distance myself - self-vision) / (self-vision)) * sin(towards tar)
        set sign-forcey sign-forcey - 10 * flock-rate * exp((distance myself - self-vision) / (self-vision)) * cos(towards tar )
    ]
  ]
  ]
end

to go-with-door
  ifelse distance target-door < 1
  [ifelse abs subtract-headings ([direction] of target-door) heading < 90
    [
      set ignore-doors insert-item 0 ignore-doors target-door
    ]
    [
      set ignore-doors insert-item 0 ignore-doors target-door
    ]
  ]
;  [
;  let turn subtract-headings (towards target-door) heading
;  if [pcolor] of patch-at-heading-and-distance turn 1 = white
;  [
;  ifelse abs turn > 10
;  [ ifelse turn > 0
;      [ rt 10 ]
;      [ lt 10 ] ]
;  [ rt turn ]
;  ]
;  ]
  [
  set door-forcex door-forcex + 0.5 * mass * ((expect-speed * sin(towards target-door)) - speedx) / reaction-time
  set door-forcey door-forcey + 0.5 * mass * ((expect-speed * cos(towards target-door)) - speedy) / reaction-time
  ]
end

to no-wall
  let h atan speedx speedy
  let temx 0
  let temy 0
  ask patches in-radius bound with [wall-patch? = True] ; self is me. myself is the agent who is asking me to do whatever I'm doing now.
  [
    set temx temx + 20 * wall-force * exp((bound - distance myself) / 2) * sin(towards myself)
    set temy temy + 20 * wall-force * exp((bound - distance myself) / 2) * cos(towards myself)
  ]
  set wall-forcex wall-forcex + temx
  set wall-forcey wall-forcey + temy
end

to bonding-force  ;; turtle procedure
  set other-passengers other passengers in-radius vision with [safe-passenger?]
  set nearest-neighbor min-one-of other-passengers [distance myself]
  let h atan speedx speedy
  let temx 0
  let temy 0
  ask other passengers in-radius self-vision ; self is me. myself is the agent who is asking me to do whatever I'm doing now.
  [
    if [xcor] of self != [xcor] of myself and [ycor] of self != [ycor] of myself
    [
    set temx temx + 10 * flock-rate * exp((2 * bound - distance myself) / bound) * sin(towards myself)
    set temx temx - 10 * flock-rate * exp((distance myself - self-vision) / (self-vision)) * sin(towards myself)
    set temy temy + 10 * flock-rate * exp((2 * bound - distance myself) / bound) * cos(towards myself)
    set temy temy - 10 * flock-rate * exp((distance myself - self-vision) / (self-vision)) * cos(towards myself)
    ]
  ]
  set bound-forcex bound-forcex + temx
  set bound-forcey bound-forcey + temy
end

to avoid-fire  ;; turtle procedure
  let temx 0
  let temy 0
  ask fire-spots in-radius self-vision ; self is me. myself is the agent who is asking me to do whatever I'm doing now.
  [
    if [xcor] of self != [xcor] of myself and [ycor] of self != [ycor] of myself
    [
    set temx temx + 10  * exp((5 - distance myself) / 5) * sin(towards myself)
    set temy temy + 10  * exp((5 - distance myself) / 5) * cos(towards myself)
    ]
  ]
  set fire-forcex fire-forcex + temx
  set fire-forcey fire-forcey + temy
end

to go-preffer
  set pre-dir-forcex pre-dir-forcex + mass * ((expect-speed * sin(pre-dir)) - speedx) / reaction-time
  set pre-dir-forcey pre-dir-forcey + mass * ((expect-speed * cos(pre-dir)) - speedy) / reaction-time
  set fx pre-dir-forcex
  set fy pre-dir-forcey
end

to deal-inwall-person
  if [pcolor] of patch-here = black
  [move-to min-one-of patches with [pcolor = white] [distance myself]]
end

;to separate  ;; turtle procedure
;  let turn subtract-headings heading ([heading] of nearest-neighbor)
;  ifelse abs turn > 5 * flock-rate
;    [ ifelse turn > 0
;        [ rt 5 * flock-rate ]
;        [ lt 5 * flock-rate ] ]
;    [ rt turn ]
;end

;;; ALIGN

;to average-flockmate-heading  ;; turtle procedure
;  ;; We can't just average the heading variables here.
;  ;; For example, the average of 1 and 359 should be 0,
;  ;; not 180.  So we have to use trigonometry.
;  let x-component sum [dx] of other-passengers
;  let y-component sum [dy] of other-passengers
;  if x-component != 0 and y-component != 0
;    [ let turn subtract-headings (atan x-component y-component) heading
;      ifelse abs turn > 5 * flock-rate
;      [ifelse (turn) > 0
;        [ rt 5 * flock-rate ]
;        [ lt 5 * flock-rate ] ]
;      [rt turn]
;    ]
;end
;
;to average-heading-towards-flockmates
;  let x-component mean [sin (towards myself + 180)] of other-passengers
;  let y-component mean [cos (towards myself + 180)] of other-passengers
;  if x-component != 0 and y-component != 0
;    [ let turn subtract-headings (atan x-component y-component) heading
;      ifelse abs turn > 3 * flock-rate
;      [ifelse (turn) > 0
;        [ rt 3 * flock-rate ]
;        [ lt 3 * flock-rate ] ]
;      [rt turn]
;    ]
;end

to go-toward-exits

  ifelse count patches in-radius 2 with [exits-patch? = True] > 0
  [
    set color green
    let cyan-patches (patches in-radius 4 with [pcolor = cyan] )
    die
  ]
  [
    set fx bound-forcex + wall-forcex + sign-forcex + door-forcex + explore-forcex + exit-forcex + fire-forcex
    set fy bound-forcey + wall-forcey + sign-forcey + door-forcey + explore-forcey + exit-forcey + fire-forcey
    if fx > max-force
    [
      set fx  max-force
    ]
    if fy > max-force
    [
      set fy  max-force
    ]
    if fx < 0 - max-force
    [
      set fx  0 - max-force
    ]
    if fy < 0 - max-force
    [
      set fy  0 - max-force
    ]
    set fx fx + random 20
    set fx fx - random 20
    set fy fy + random 20
    set fy fy - random 20
    if abs speedx < 0.1 * expect-speed and abs speedy < 0.1 * expect-speed
    [
      go-preffer
    ]
    set speedx speedx + update-time * (fx / mass)
    set speedy speedy + update-time * (fy / mass)
    let max-speed 1.5 / update-time
    let highs max list speedx speedy
    if highs > max-speed
    [
      let ratio max-speed / highs
      set speedx speedx * ratio
      set speedy speedy * ratio
    ]
    set heading atan speedx speedy
    ifelse [pcolor] of patch (xcor + speedx * update-time) (ycor + speedy * update-time) != black
    [
      set xcor xcor + speedx * update-time
      set ycor ycor + speedy * update-time
    ]
    [
      set xcor xcor + speedx * update-time * 0.2
      set ycor ycor + speedy * update-time * 0.2
    ]
    deal-inwall-person
  ]

end
@#$#@#$#@
GRAPHICS-WINDOW
451
15
1423
508
-1
-1
4.0
1
1
1
1
1
0
1
1
1
-120
120
-60
60
1
1
1
ticks
30.0

BUTTON
21
20
115
53
setup-map
setup-map
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
339
18
402
51
go
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
22
64
194
97
passenger-count
passenger-count
20
100
60.0
1
1
NIL
HORIZONTAL

SLIDER
22
396
194
429
fire-count
fire-count
0
3
0.0
1
1
NIL
HORIZONTAL

SLIDER
22
202
194
235
panic-rate
panic-rate
0
0.5
0.19
0.01
1
NIL
HORIZONTAL

SLIDER
21
250
193
283
vision
vision
1
50
20.0
1
1
NIL
HORIZONTAL

SLIDER
22
298
194
331
flock-rate
flock-rate
0
1
1.0
0.01
1
NIL
HORIZONTAL

SWITCH
22
109
149
142
Trajectory
Trajectory
0
1
-1000

SWITCH
23
155
143
188
show-sign
show-sign
1
1
-1000

SLIDER
22
346
194
379
wall-force
wall-force
1
5
5.0
0.05
1
NIL
HORIZONTAL

SLIDER
229
348
401
381
update-time
update-time
0.01
0.1
0.05
0.01
1
NIL
HORIZONTAL

SLIDER
231
251
403
284
reaction-time
reaction-time
0.5
2
0.9
0.05
1
NIL
HORIZONTAL

SLIDER
230
299
402
332
max-force
max-force
0
1000
809.0
1
1
NIL
HORIZONTAL

SLIDER
231
202
403
235
speed-init
speed-init
1
20
7.0
1
1
NIL
HORIZONTAL

BUTTON
233
17
296
50
NIL
go
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
231
156
403
189
spread-cost
spread-cost
0
5
0.9
0.1
1
NIL
HORIZONTAL

SLIDER
231
65
403
98
spread-speed
spread-speed
100
200
190.0
1
1
NIL
HORIZONTAL

PLOT
935
524
1330
673
energy
time
total
0.0
10.0
0.0
10.0
true
true
"" ""
PENS
"default" 1.0 0 -955883 true "" "plot sum [energy] of passengers"
"pen-1" 1.0 0 -13840069 true "" "plot sum [health] of passengers"

SLIDER
230
110
402
143
bound
bound
1
5
2.0
1
1
NIL
HORIZONTAL

PLOT
453
523
876
673
escape-dead
time
number of person
0.0
10.0
0.0
10.0
true
true
"" ""
PENS
"alive-people" 1.0 0 -11033397 true "" "plot count passengers with [safe-passenger? = True]"
"dead-people" 1.0 0 -10022847 true "" "plot count passengers with [safe-passenger? = False]"
"safe-people" 1.0 0 -2674135 true "" "plot passenger-count - count passengers"

BUTTON
21
449
129
482
NIL
create-wall
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
21
497
129
530
NIL
create-exit
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
21
546
129
579
NIL
delete-wall
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
22
594
130
627
NIL
delete-exit
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
243
453
385
486
setup-selfdefine
setup-selfdefine
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
119
21
213
54
NIL
set-agent
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

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

cloud
false
0
Circle -7500403 true true 13 118 94
Circle -7500403 true true 86 101 127
Circle -7500403 true true 51 51 108
Circle -7500403 true true 118 43 95
Circle -7500403 true true 158 68 134

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

fire
false
0
Polygon -7500403 true true 151 286 134 282 103 282 59 248 40 210 32 157 37 108 68 146 71 109 83 72 111 27 127 55 148 11 167 41 180 112 195 57 217 91 226 126 227 203 256 156 256 201 238 263 213 278 183 281
Polygon -955883 true false 126 284 91 251 85 212 91 168 103 132 118 153 125 181 135 141 151 96 185 161 195 203 193 253 164 286
Polygon -2674135 true false 155 284 172 268 172 243 162 224 148 201 130 233 131 260 135 282

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

person business
false
0
Rectangle -1 true false 120 90 180 180
Polygon -13345367 true false 135 90 150 105 135 180 150 195 165 180 150 105 165 90
Polygon -7500403 true true 120 90 105 90 60 195 90 210 116 154 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 183 153 210 210 240 195 195 90 180 90 150 165
Circle -7500403 true true 110 5 80
Rectangle -7500403 true true 127 76 172 91
Line -16777216 false 172 90 161 94
Line -16777216 false 128 90 139 94
Polygon -13345367 true false 195 225 195 300 270 270 270 195
Rectangle -13791810 true false 180 225 195 300
Polygon -14835848 true false 180 226 195 226 270 196 255 196
Polygon -13345367 true false 209 202 209 216 244 202 243 188
Line -16777216 false 180 90 150 165
Line -16777216 false 120 90 150 165

person service
false
0
Polygon -7500403 true true 180 195 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285
Polygon -1 true false 120 90 105 90 60 195 90 210 120 150 120 195 180 195 180 150 210 210 240 195 195 90 180 90 165 105 150 165 135 105 120 90
Polygon -1 true false 123 90 149 141 177 90
Rectangle -7500403 true true 123 76 176 92
Circle -7500403 true true 110 5 80
Line -13345367 false 121 90 194 90
Line -16777216 false 148 143 150 196
Rectangle -16777216 true false 116 186 182 198
Circle -1 true false 152 143 9
Circle -1 true false 152 166 9
Rectangle -16777216 true false 179 164 183 186
Polygon -2674135 true false 180 90 195 90 183 160 180 195 150 195 150 135 180 90
Polygon -2674135 true false 120 90 105 90 114 161 120 195 150 195 150 135 120 90
Polygon -2674135 true false 155 91 128 77 128 101
Rectangle -16777216 true false 118 129 141 140
Polygon -2674135 true false 145 91 172 77 172 101

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
NetLogo 6.3.0
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
