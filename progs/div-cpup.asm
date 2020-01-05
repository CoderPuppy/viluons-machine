	?K8 ERROR

	?K2 2
	K2--
	JMP -3

loop:
	?K8 :reset
	?K7 :done
	K7--
	K8--
	K2++
	JMP -6

reset:
	K1++
	?K2 :loop
	K2--
	K8++
	JMP -4

done:
	?K2 END
	K2--
	K7++
	K8++
	JMP -5
