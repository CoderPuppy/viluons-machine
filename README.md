This is a set of tools for [@viluon](://github.com/viluon)'s machine

# Machine
The instruction pointer is incremented after every instruction

### Instructions:
- `K{reg}++` - increment `reg`
- `K{reg}--` - decrement `reg`
- `?K{reg} {to}` - go to `to` if `reg` is 0
- `JMP {to}` - go to `to`

### Destinations:
- `{O:%d+}` - add `O` to the instruction pointer

# Extensions

- `{lbl}:` - introduces a label the points to the next instruction

### Destinations
- `:{lbl}` - go to a label named `lbl`
- `={I:%d+}` - set the instruction pointer to `I`
- `ERROR` - error out
- `END` - stop the program (actually sets the instruction pointer to after the last instruction)
