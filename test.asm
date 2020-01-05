  JMP :part21
part3:
  K3++
  JMP :label1
part4:
  K2++
  JMP :part3
part5:
  K1--
  JMP :part4
part7:
label1:
  ?K1 END
  JMP :part5
part10:
  K1--
  JMP :label3
part11:
  K3++
  JMP :part10
part13:
label3:
  ?K1 :label2
  JMP :part11
part15:
label2:
  ?K3 :part13
  ?K2 :part7
  K2--
  K3--
  K1++
  JMP -6
part17:
  K1--
  JMP :label4
label4:
part19:
  ?K1 :part15
  JMP :part17
part21:
  ?K3 END
  JMP :part19
