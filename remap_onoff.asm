!xflipped = $00     ;; valid values are $00 for not flipped and $01 for flipped
!yflipped = $00     ;; valid values are $00 for not flipped and $01 for flipped
!priority = $00     ;; valid values are $00, $01, $02, $03
!palette = $0B      ;; valid values are in the range $08-$0F
!page = $01         ;; valid values are $00, $01

!tilenum = $8A

!properties = ((!yflipped<<7)|(!xflipped<<6)|(!priority<<5)|((!palette-$08)<<1)|!page)&$FF

!onoff_sprnum = $05


org $0291F1+!onoff_sprnum         ;; bounce sprite tile numbers, order as $1699
    db !tilenum

org $028789+!onoff_sprnum         ;; yxppccct values, order as $1699
    db !properties 
