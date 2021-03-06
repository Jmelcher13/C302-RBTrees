;Tricia Nelsen, Zale Young, and Jenny Melcher
;Implementation Project
;Visualization of Red-Black Tree and 2-3-4 Tree

;To run this
breed [nodes node]


globals[
rb?      ; is the tree a Red-Black tree?
root     ; is this the root?
prev234  ; was the tree previously a 234 tree
]

nodes-own[
  lChild   ; left child
  rChild   ; right child
  parent
  red?     ; is the node red
  value
  bDepth   ; black depth of this node
  is-null? ; is the node null?
  height
  is-root? ; is this node the root
  sibling  ; what is the sibling of this node
  depth
]

to setup
  ca
  initialize-globals
  initialize-nodes
  set-default-shape nodes "circle"  ;basic graphics
  ask patches [set pcolor white]
  reset-ticks
end

to initialize-globals
  set rb? true      ;always start with a red-black tree
  set prev234 false
end

to initialize-nodes
  create-nodes 1 [  ; initializing a blank (invisible) node as root
    set is-null? true
    set red? false
    set bDepth 0
    set height 0
    set root node 0
    set color white
    setxy 0 15
    set shape "circle"
    set is-root? true
  ]
end

to makeNode                  ; basics of a node
  ifelse red? [set color red]; color
    [set color black]
  set shape "circle"         ; shape
  set size 2                 ; size
  set label element          ; label
end

;;;; ZALE SECTION ;;;;;;;
to insert
  ifelse rb? = false  ; if the user is inserting into a 234 tree, switch to RB then switch back after
  [set prev234 true   ; remember that the user inserted into a 234 tree
  RBTree]             ;
  [set prev234 false]

  let r? true                  ; the only case in which insertion would not be red
  if [is-null?] of root = true ; is if it were the root
  [ set r? false ]

  let thisnode root
  let prev thisnode
  while [[is-null?] of thisnode = false]   ; while you are not at a leaf, keep comparing
  [                                        ; element to nodes and moving down
    set prev thisnode
    ifelse element <= [value] of thisnode  ;if new element is < value of node
    [ set thisnode [lChild] of thisnode]   ; move left of this node
    [ set thisnode [rChild] of thisnode]   ; if it is >, move right of this node
  ]

  ask thisnode [
    set height height + 1                  ; increase height and black depth (if it is black)
    if r? = false[set bDepth bDepth + 1]
  ]

  let l 0
  let r 0

  ask thisnode[
    set color black
    set size 1
    set value element
    set label value
    set is-null? false
    set red? r?
    set bDepth 1

    if is-root? = false
    [
      create-link-with parent           ; draw line between child and its parent
      set parent prev
    ]
    hatch 1 [                           ; hatch left leaf
      set l self
      set color white
      set size 0
      set is-null? true
      set red? false
      set parent thisnode
      set bDepth 0
      set is-root? false
      set height [height] of parent + 1
      set heading 180 + (45 / (height ^ 0.5))
      fd 10 / height ^ 0.5
    ]
    hatch 1 [                           ; hatch right leaf
      set sibling l
      set r self
      set color white
      set size 0
      set is-null? true
      set red? false
      set parent thisnode
      set bDepth 0
      set is-root? false
      set height [height] of parent + 1
      set heading 180 - (45 / (height ^ 0.5))
      fd 10 / height ^ 0.5
    ]
    ask l [set sibling r]              ; associate siblings
    set lChild l
    set rChild r
    if red? = true [set color red]

  ]
;;;;;;;; Restructuring cases ;;;;;;;;;;;
  while [
    [is-root?] of thisnode = false
    and [red?] of thisnode = true
    and [red?] of [parent] of thisnode = true] ; in the case where a child has a red parent
  [
    let next [parent] of [parent] of thisnode
    ask thisnode [
      ifelse [red?] of [sibling] of parent = true
      [case1]  ; if there is also a red aunt
      [case2]  ; if there is not a red aunt
    ]
    set thisnode next
  ]

  redrawRedBlack      ; redraw the tree

  if prev234 = true [ ;if the user was inserting into a 234 tree, switch back to that.
    two34Tree
  ]
end


to case1     ; the case in which a node, its parent and its aunt were both red
  ask parent [set red? false
    set color black]
  if [is-root?] of [parent] of parent = false[
    ask [parent] of parent [set red? true
      set color red]]
  ask [sibling] of parent [set red? false
    set color black]
end

to case2     ; the case in which a node and its parent were red, but not its aunt
  let A self
  let B parent
  let C [parent] of parent

; trinode restructuring of A, B, C


  let p 0
  let s 0
  let lc? false

  let rooted? false
  ifelse [is-root?] of C = true
  [set rooted? true]
  [
    set p [parent] of [parent] of parent
    set s [sibling] of [parent] of parent

    set lc? false
    if C = [lChild] of p [ set lc? true ]
  ]
;;;; Find min of A, B, C
  let miniv [value] of A
  let mini A
  if [value] of C < miniv [
    set mini C
    set miniv [value] of C
  ]
  if [value] of B < miniv [set mini B]

;;;; Find max of A, B, C
  let maxiv [value] of C
  let maxi C
  if [value] of A > maxiv [
    set maxi A
    set maxiv [value] of A
  ]
  if [value] of B > maxiv [set maxi B]

;;;; Find mid of A, B, C
  let midv [value] of B
  let mid B
  ifelse A != maxi and A != mini
  [set mid A]
  [
    if C != maxi and C != mini
    [set mid C]
  ]
; note: alpha < mini < beta < mid < gamma < maxi < delta
  let alpha [lChild] of mini

  let beta [lChild] of mid
  if [lChild] of mid = mini
  [set beta [rChild] of mini]

  let gamma [rChild] of mid
  if [rChild] of mid = maxi
  [set gamma [lChild] of maxi]

  let delta [rChild] of maxi

  ask alpha[
    set parent mini
    set sibling beta
  ]
; restructures nodes to correct order
  ask mini[
    set parent mid
    set lChild alpha
    set rChild beta
    set color red
    set red? true
    set is-root? false
    set sibling maxi
  ]

  ask beta[
    set parent mini
    set sibling alpha
  ]

  ask mid[
    set sibling s
    set lChild mini
    set rChild maxi
    set color black
    set red? false
    ifelse rooted? = true
    [set is-root? true]
    [
      set parent p
      ifelse lc? = true
      [
        ask parent[
          set lChild myself
        ]
      ]
      [
        ask parent[
          set rChild myself
        ]
      ]
    ]
  ]
  if rooted? = true [set root mid]

  ask gamma[
    set parent maxi
    set sibling delta
  ]

  ask maxi[
    set lChild gamma
    set parent mid
    set rChild delta
    set color red
    set red? true
    set is-root? false
    set sibling mini
  ]

  ask delta[
    set parent maxi
    set sibling gamma
  ]
end

to redrawRedBlack   ; redraw the red-black tree
  clear-links

  ask root[         ; place root
    setxy 0 15
    set depth 0
  ]
  let myList []     ; lists for nodes
  set mylist lput [lChild] of root mylist
  set mylist lput [rChild] of root mylist
  let cur root

  while [empty? mylist = false][   ; while the list contains nodes

    set cur first mylist
    set mylist remove-item 0 mylist


    ask cur[
      set depth [depth] of parent + 1  ; increasing depth for each level
      move-to parent                   ; children move to parent and then moving diagonally away to placement
      ifelse self = [lChild] of parent
      [ set heading 180 + (45 / (depth ^ 0.5)) ]
      [ set heading 180 - (45 / (depth ^ 0.5)) ]

      fd 10 / depth ^ 0.5

      if is-null? = false [
        set mylist lput lChild mylist
        set mylist lput rChild mylist
        create-link-with parent
      ]
    ]
  ]

end

to left-rotate
  let p [parent] of self
  let xl [lChild] of self
  let xr [rChild] of self
  let s [sibling] of self

  let rooted? [is-root?] of p
  let g 0
  let ps 0
  if rooted? = false
  [
    set g [parent] of p
    set ps [sibling] of p

    ask g[
      ifelse p = [lChild] of g
      [set lChild self]
      [set rChild self]
    ]

    ask ps[
      set sibling self
    ]
  ]

  ask self[
    set parent g
    set lChild p
    set sibling ps

    if rooted? = true[
      set is-root? true
      set root self
    ]
  ]

  ask p[
    set parent self
    set is-root? false
    set sibling xr
    set rChild xl
  ]

  ask xr[
    set sibling p
  ]

  ask s[
    set sibling xl
  ]

  ask xl[
    set sibling s
    set parent p
  ]


end


to right-rotate
  let p [parent] of self
  let xl [lChild] of self
  let xr [rChild] of self
  let s [sibling] of self

  let rooted? [is-root?] of p
  let g 0
  let ps 0
  if rooted? = false
  [
    set g [parent] of p
    set ps [sibling] of p

    ask g[
      ifelse p = [lChild] of g
      [set lChild self]
      [set rChild self]
    ]

    ask ps[
      set sibling self
    ]
  ]

  ask self[
    set parent g
    set rChild p
    set sibling ps

    if rooted? = true[
      set is-root? true
      set root self
    ]
  ]

  ask p[
    set parent self
    set is-root? false
    set sibling xl
    set lChild xr
  ]

  ask xl[
    set sibling p
  ]

  ask s[
    set sibling xr
  ]

  ask xr[
    set sibling s
    set parent p
  ]


end
;;;;; END ZALES SECTION ;;;;;;;;;;;;;;;



to two34Tree ;;;;;;;;;;; BUTTON SWITCHES FROM R/B TO 234 TREES;;;;;;;;;;;;;;;;;;;;;;;;;;

  ifelse rb? = true [
  ask nodes [if red? = false ; if a node is black make it the center of a 234 tree node
    [
    set shape "square"  ; change shape
        if is-root? = false and [red?] of parent = true [
          set depth [depth] of parent
      ]
        if depth <= 3 and depth > 0 ; if a parent moves up, it shouldn't leave a gap, the
        [set ycor 16 - (depth * 3)] ; child should also move up.
        if depth > 3                ; maintain equal levels by using depth
        [set ycor 0 - (depth * 3)]
      ]
    if lChild != 0 and [red?] of lChild = true ; if it has red children, bring them up to be part of the 234 tree node
    [ask lChild [set shape "square" ;left child
      move-to parent ; bring it up
      set heading 270 ; put children to the side of the parent
      fd 1]]
    if rChild != 0 and [red?] of rChild = true
    [ask rChild [set shape "square" ; right child
      move-to parent ;bring up
      set heading 90 ; put it on right side of parent
      fd 1]]
  ]
 set rb?  false ] ; rb? is false because this is a rb tree, so red-black button will work
    [ write "already a 2-3-4 tree"] ; if rb? is false, this is already a 234 tree, print that out.
end

to RBTree  ;;;;;;;;BUTTON SWITCHES FROM 234 TO RB TREES;;;;;;;;;;;;;;;;;;;;;

  ifelse rb? = false [ ; can only be changed to rb tree if rb? is false (thus, it is already a 234 tree)
    ask nodes [ if red? = false ;;;; black nodes
      [set shape "circle" ; Shape of nodes back to circles
        if is-root? = false and [red?] of parent = true [
          set depth depth + 1 ] ; depth decreased when they were switched to a 234 tree, add it back
      ]
      if red? = true  ;;;;;red nodes
      [ set shape "circle"] ; change shapes back to circles
    ]
    redrawRedBlack  ; use redrawredblack function to actually redraw the tree
    set rb? true ;global variable to know it is a red/black tree
  ]
  [ write "already a red-black tree"]
end








;;;;;;START TRICIAS SECTION ;;;;;;;;;;;;;;;

to-report search [val]
  let current-node root
  while [not [is-null?] of current-node and [value] of current-node != val]
  [ifelse val < [value] of current-node[
    set current-node [lChild] of current-node][
    set current-node [rChild] of current-node]
  ]
    report current-node
end

to display-search [current-node]
  reset-timer
  ifelse [value] of current-node = search-value[
    ask current-node[
      set color yellow
      write "The search value is in the tree!"]
    while [timer < 3][]
    ask current-node[
      ifelse red? [set color red][set color black]
  ]][write "This value is not in the tree"]
end

to rb-transplant [u v]
  ifelse [is-null?] of [parent] of u
  [
    set root v
  ]
  [
    ifelse [lChild] of [parent] of u = u
    [
      ask [parent] of u[
        set lChild v
      ]
    ][

    ask v[
      set parent [parent] of u
    ]
  ]]
end

to delete
  let x 1
  let origColor yellow
  let z search delete-value ;make y the node that is put in the input to be deleted
  let y z

  ifelse [red?] of y [set origColor red]
  [set origColor black]

  ifelse [is-null?] of [lChild] of z
  [
    set x [rChild] of z
    rb-transplant z x
  ]
  [
    ifelse [is-null?] of [rChild] of z
    [
      set x [lChild] of z
      rb-transplant z x
    ]
    [
      let z.right [rChild] of z
      set y tree-min z.right
      set origColor [color] of y
      set x [rChild] of y

      ifelse [parent] of y = z
      [
        ask x[
          set parent y]
      ]
      [
        let y.right [rChild] of y
        rb-transplant y y.right
        ask y[
          set rChild [rChild] of z
          ask rChild[
            set parent y]]
      ]
      rb-transplant z y
      ask y[
        set lChild [lChild] of z
        ask lChild[
          set parent y
        ]
        set color [color] of z
      ]
    ]
  ]
    if origColor = black [
      delete-fixup x
    ]
end

to-report tree-min [x]
  while[[is-null?] of [lChild] of x = false]
  [set x [lChild] of x]
  report x
end

to delete-fixup [x]
  ask x[while [not is-root? and not red?]
    [ifelse [lChild] of parent = self ;if x is the left child of it's parent
      [let w [rChild] of parent
        ifelse [red?] of w [
          ask w [
            set red? false
            set color black]
          ask parent[
            set red? true
            set color red]
            ask x[left-rotate]
            ;left-rotate x
          set w [rChild] of parent] ;this is through line 8 of pseudocode on line 326
        [ifelse[red?] of [lChild] of w = false and [red?] of [rChild] of w = false[
          ask w[
            set color red
            set red? true
          ]
          set x [parent] of x
          ]
          [if [red?] of [rChild] of w = false[
            ask w [
              set color red
              set red? true]
            ask [lChild] of w [
              set color black
              set red? false]
              ask [lChild] of w[right-rotate]
              ;right-rotate [lChild] of w
            set w [rChild] of parent
            ask w [set color [color] of parent]
            ask parent [
              set color black
              set red? false]
            ask w [
              ask rChild
              [set color black ]
            ]
            ask x[left-rotate]
            ;left-rotate x
           set x root
          ]]
      ]]

[let w [lChild] of parent
        ifelse [red?] of w [
          ask w [
            set red? false
            set color black]
          ask parent[
            set red? true
            set color red]
         ; right-rotate parent
          set w [lChild] of parent] ;this is through line 8 of pseudocode on line 326
        [ifelse[red?] of [rChild] of w = false and [red?] of [rChild] of w = false[
          ask w[
            set color red
            set red? true
          ]
          set x [parent] of x
          ]
          [if [red?] of [lChild] of w = false[
            ask w [
              set color red
              set red? true]
            ask [rChild] of w [
              set color black
              set red? false]
         ;  left-rotate w
            set w [lChild] of parent
            ask w [set color [color] of parent]
            ask parent [
              set color black
              set red? false]
            ask w [
              ask lChild
              [set color black ]
            ]
          ;   right-rotate [parent] of w
           set x root
      ]]]
    ]
  ]
  ]
  redrawRedBlack
end

;;;;;;;; END TRICIA SECTION ;;;;;;;;;;;;;
@#$#@#$#@
GRAPHICS-WINDOW
210
10
647
448
-1
-1
13.0
1
10
1
1
1
0
0
0
1
-16
16
-16
16
0
0
1
ticks
30.0

BUTTON
27
18
93
51
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

INPUTBOX
23
70
89
130
element
8.0
1
0
Number

BUTTON
106
86
173
119
NIL
insert
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
115
298
176
331
234 Tree
two34Tree
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
3
297
99
330
Red-Black Tree
RBTree
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

INPUTBOX
14
142
94
202
search-value
1.0
1
0
Number

BUTTON
104
156
182
189
search
display-search search search-value
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

INPUTBOX
11
216
94
276
delete-value
7.0
1
0
Number

BUTTON
106
233
175
266
NIL
delete
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
NetLogo 6.0.4
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
