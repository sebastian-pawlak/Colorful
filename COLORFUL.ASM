; "Colorful", Atari XL/XE Intro 256B
; code by tr1x
; requirements: original Atari XL/XE 64KB PAL
; version: 1.0
; release date: 2019-12-07

	org $0600

gtia10	equ $80		; graphics 10 (GTIA mode)
rtclok	equ $0012
memdl1	equ $0090
cntr1	equ $0092
cntr2	equ $0093
cntr3	equ $0094
vdslst	equ $0200
gprior	equ $026f
pcolr1	equ $02c1
vidptr	equ $5000	; video memory
dlist	equ $9c20	; display list
colpm1	equ $d013
wsync	equ $d40a
vcount	equ $d40b
setvbv	equ $e45c
xitvbv	equ $e462

	; prepare display list
	ldx #<dlist+3
	stx memdl1
	lda #>dlist
	sta memdl1+1
	ldx #$c0
	ldy #$00
	sty rtclok+1	; zeroing rtclok+1
loopa1	lda #$4f	; ANTIC command: gr.mode | address
	sta (memdl1),y
	inc memdl1
	;bne skipa1	; not needed,
	;inc memdl1+1	; ..since does not occur in practice
skipa1	lda #<vidptr
	sta (memdl1),y
	inc memdl1
	bne skipa2
	inc memdl1+1
skipa2	lda #>vidptr
	sta (memdl1),y
	inc memdl1
	bne skipa3
	inc memdl1+1
skipa3	dex
	bne loopa1

	;lda #$41	; jump to the beginning of display list
	;sta dlist+$243	; ..is not necessary
	;lda #<dlist
	;sta dlist+$244
	;lda #>dlist
	;sta dlist+$245

	; set GTIA graphics mode
	lda #gtia10
	sta gprior

	; draw vertical bars
	ldx #$27
	ldy #$06
loopb1	lda colors,y
	sta vidptr,x
	dey
	bpl skipb1
	ldy #$06
skipb1	dex
	bpl loopb1

	; color palette animation
anim	lda vcount
loopc1	cmp vcount
	beq loopc1
	and #$01
	bne anim
	lda vcount
	clc
	adc rtclok+2

	clc
	adc shapes+0,y
	tax
	clc
	adc shapes+1,y
	sta opcodc1+1
	clc
	adc shapes+2,y
	sta opcodc2+1
	sta wsync
	nop		; needed for synchronization
	clc
	adc shapes+3,y
	sta opcodc3+1
	clc    
	adc shapes+4,y
	sta opcodc4+1
	clc
	adc shapes+5,y
	sta opcodc5+1
	clc
	adc shapes+6,y
	sta opcodc6+1
	clc
	adc shapes+7,y
	tay

opcodc1	lda #$00
	sta colpm1+1
	sty colpm1+7
opcodc6	lda #$00
	sta colpm1+6
opcodc5	lda #$00
	sta colpm1+5
opcodc4	lda #$00
	sta colpm1+4
opcodc3	lda #$00
	sta colpm1+3
opcodc2	lda #$00
	sta colpm1+2
	stx colpm1+0

	lda rtclok+1
	cmp #$06
	bne skipc1
	lda #$00
	sta rtclok+1
skipc1	asl
	asl
	asl
	tay

	jmp anim

	; colors of vertical bars
colors	.byte $21, $23, $45, $67, $87, $65, $43

shapes	.byte $02, $02, $02, $02, $02, $02, $02, $02	; triangle
	.byte $08, $06, $06, $04, $04, $02, $02, $00	; parabola, arms down
	.byte $00, $12, $12, $14, $14, $16, $16, $18	; narrow parabola, up
	.byte $00, $00, $02, $04, $04, $02, $02, $00	; sine
	.byte $04, $04, $04, $04, $04, $04, $04, $04	; high triangle
	.byte $20, $22, $24, $26, $28, $2a, $2c, $2e	; dense parabola
