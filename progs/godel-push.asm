gen1:
	K3++
	?K1-- 8
		?K3-- 3
		K5++
		K5++
		JMP -4

		?K5-- 2
		K3++
		JMP -3
	JMP -9

gen2:
	K4++
	?K2-- 9
		?K4-- 4
		K5++
		K5++
		K5++
		JMP -5

		?K5-- 2
		K4++
		JMP -3
	JMP -10

mul:
	?K3-- 8
		?K4-- 3
		K5++
		K7++
		JMP -4

		?K5-- 2
		K4++
		JMP -3
	JMP -9

	?K4-- 1
	JMP -2
