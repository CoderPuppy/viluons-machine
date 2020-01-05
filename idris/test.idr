module ViluonsMachine

import Data.Fin
import Data.Vect

data Instr : (nr : Nat) -> (ni : Nat) -> Type where
	IJmp : Fin (S ni) -> Instr nr ni
	IJIZ : Fin nr -> Fin (S ni) -> Instr nr ni
	IIncr : Fin nr -> Instr nr ni
	IDecr : Fin nr -> Instr nr ni

data Prog : (nr : Nat) -> Type where
	MkProg : {ni : Nat} -> Vect ni (Instr nr ni) -> Prog nr

raiseFin : Fin n -> Fin (S n)
raiseFin FZ = FZ
raiseFin (FS f) = FS $ raiseFin f

raiseFin' : Fin n -> Fin (m + n)
raiseFin' {m=Z} f = f
raiseFin' {m=S m} f = raiseFin $ raiseFin' f

incrFin : Fin n -> Fin (m + n)
incrFin {m=Z} f = f
incrFin {m=S m} f = FS $ incrFin f

reduceFin : Fin (S n) -> Maybe (Fin n)
reduceFin {n=Z} f = Nothing
reduceFin {n=S n} FZ = Just FZ
reduceFin {n=S n} (FS f) = map FS $ reduceFin f

mapJumps : (Fin (S n) -> Fin (S m)) -> Instr nr n -> Instr nr m
mapJumps f (IJmp to) = IJmp $ f to
mapJumps f (IJIZ r to) = IJIZ r $ f to
mapJumps f (IIncr r) = IIncr r
mapJumps f (IDecr r) = IDecr r

Semigroup (Prog nr) where
	(MkProg {ni=na} a) <+> (MkProg {ni=nb} b) =
		MkProg $
		map (mapJumps $ replace {P=Fin} (plusCommutative nb (S na)) . raiseFin') a
		++
		map (mapJumps $ replace {P=Fin} (sym $ plusSuccRightSucc na nb) . incrFin) b

Monoid (Prog nr) where
	neutral = MkProg []

MemState : Nat -> Type
MemState nr = Vect nr Nat
ExecState : Nat -> Type
ExecState ni = Fin ni

total
tick : Instr nr ni -> (ExecState ni, MemState nr) -> (ExecState (S ni), MemState nr)
tick (IJmp to) (_, ms) = (to, ms)
tick (IJIZ r to) (es, ms) =
	if index r ms == 0
	then (to, ms)
	else (FS es, ms)
tick (IIncr r) (es, ms) = (FS es, updateAt r S ms)
tick (IDecr r) (es, ms) = (FS es, updateAt r (\a => minus a 1) ms)

total
tick' : Vect ni (Instr nr ni) -> (ExecState ni, MemState nr) -> MemState nr
tick' prog (es, ms) = let
		s' = tick (index es prog) (es, ms)
	in maybe (snd s') (\es'' => assert_total $ tick' prog (es'', snd s')) $ reduceFin $ fst s'

total
exec : Prog nr -> MemState nr -> MemState nr
exec (MkProg {ni=Z} prog) ms = ms
exec (MkProg {ni=S ni} prog) ms = tick' prog (0, ms)

total
reduceFinLast : {n : Nat} -> reduceFin (last {n}) = Nothing
reduceFinLast {n=Z} = Refl
reduceFinLast {n=S n} = replace {P = \l => map FS l = Nothing} (sym $ reduceFinLast {n}) Refl

-- execEndIf :
-- 	(prog : Vect ni (Instr nr ni)) ->
-- 	(es : ExecState ni) ->
-- 	(ms : MemState nr) ->
-- 	fst (tick (index es prog) (es, ms)) = last ->
-- 	tick' prog (es, ms) = snd (tick (index es prog) (es, ms))
-- execEndIf prog es ms prf = ?t

-- execEndIff :
-- 	(prog : Vect ni (Instr nr ni)) ->
-- 	

toZero : Fin nr -> Prog nr
toZero reg = MkProg [
	IJIZ reg 3,
	IDecr reg,
	IJmp 0
]

toZeroZero : index r (exec (toZero r) ms) = 0
-- toZeroZero = ?t
