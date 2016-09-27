	; IF K8 == 0
	; THEN GOTO END
	?K8 END

	; K2 = 0
	?K2 :loop
	K2--
	JMP -3

loop:
	; IF K8 <= K7
	; THEN K2 += K8, K7 -= K8, K8 = 0, GOTO :reset
	; ELSE K2 += K7, K8 -= K7, K7 = 0, GOTO :done
	?K8 :reset
	?K7 :done
	K7--
	K8--
	K2++
	JMP -6

reset:
	; K8 += K2, K2 = 0, GOTO :loop
	?K2 :loop
	K8++
	K2--
	JMP -4

done:
	; K7 += K2, K8 += K2, K2 = 0, GOTO END
	?K2 END
	K2--
	K7++
	K8++
	JMP -5
