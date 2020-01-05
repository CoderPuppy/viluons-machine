loop2:
	?K1-- :loop2reset
	?K1-- :loop2done
	K2++
	JMP -4

loop2reset:
	K7++
	?K2-- :loop2
	K1++
	JMP -3

loop2done:
	K1++
	?K2-- :loop3
	K1++
	K1++
	JMP -4

loop3:
	?K1-- :loop3reset
	K1--
	?K1-- :loop3done
	K2++
	JMP -5

loop3reset:
	K8++
	?K2-- :loop3
	K1++
	JMP -3

loop3done:
	JMP END
