; K2 = 0
	?K2 2
	K2--
	JMP -3

; K3 = 0
	?K3 2
	K3--
	JMP -3

; K1 = 0

; K2 = K7, K1 = 0
	; K1 = K7, K7 = 0
		?K7 3
		K1++
		K7--
		JMP -4

	; K7 = K1, K2 = K1, K1 = 0
		?K1 4
		K7++
		K2++
		K1--
		JMP -5

redo:
; K3 = K8, K1 = 0
	; K1 = K8, K8 = 0
		?K8 3
		K1++
		K8--
		JMP -4

	; K8 = K1, K3 = K1, K1 = 0
		?K1 4
		K8++
		K3++
		K1--
		JMP -5

; IF K2 <= K3
; THEN K3 -= K2, K2 = 0, GOTO 2lteq3
; ELSE K2 -= K3, K3 = 0, GOTO 3lt2
	; ?K2 17
	?K2 :2lteq3
	; ?K3 3
	?K3 :3lt2
	K2--
	K3--
	JMP -5

3lt2:
; K7 = K2, K1 = 0
	; K7 = 0
		?K7 2
		K7--
		JMP -3
	; K1 += K2, K2 = 0
		?K2 3
		K1++
		K2--
		JMP -4
	; K2 += K1, K7 += K1, K1 = 0
		?K1 4
		K2++
		K7++
		K1--
		JMP -5
; GOTO redo
	JMP :redo
	; JMP -27

2lteq3:
; IF K3 != 0
; THEN GOTO END
	?K3 1
	; GOTO END
		JMP END
		; JMP 3

; K7 = 0
	?K7 2
	K7--
	JMP -3
