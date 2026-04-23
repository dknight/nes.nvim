" ============================================================================
" ca65 syntax (NES / 6502)
" ============================================================================

if exists("b:current_syntax")
  finish
endif

" Base: standard syntax extension
runtime! syntax/asm.vim

" ----------------------------------------------------------------------------
" Comments
" ----------------------------------------------------------------------------
syntax match ca65Comment ";.*$"
highlight link ca65Comment Comment

" ----------------------------------------------------------------------------
" Numbers
" ----------------------------------------------------------------------------
" hex: $C000 (See ZP section)
" syntax match ca65Hex "\$\x\+"
" highlight link ca65Hex Number

" binary: %10101010
syntax match ca65Binary "%[01]\+"
highlight link ca65Binary Number

" decimal
syntax match ca65Decimal "\<[0-9]\+\>"
highlight link ca65Decimal Number

" ----------------------------------------------------------------------------
" Strings
" ----------------------------------------------------------------------------
syntax region ca65String start=+"+ skip=+\\"+ end=+"+
highlight link ca65String String

" ----------------------------------------------------------------------------
" Labels
" ----------------------------------------------------------------------------
" global label: Start:
syntax match ca65Label "^[A-Za-z_][A-Za-z0-9_]*:"
highlight link ca65Label Function

" local label: @loop:
syntax match ca65LocalLabel "^@[A-Za-z_][A-Za-z0-9_]*:"
highlight link ca65LocalLabel Identifier

" ----------------------------------------------------------------------------
" Directives ca65
" ----------------------------------------------------------------------------
syntax keyword ca65Directive
  \ .segment .org .byte .word .res
  \ .proc .endproc
  \ .macro .endmacro
  \ .include .incbin
  \ .export .import .exportzp .importzp
  \ .define .undef
  \ .if .else .endif
  \ .repeat .endrepeat
  \ .scope .endscope
  \ .struct .endstruct
  \ .union .endunion

highlight link ca65Directive Keyword

" ----------------------------------------------------------------------------
" Instruction set 6502
" ----------------------------------------------------------------------------
syntax keyword ca65Opcode
  \ ADC AND ASL BCC BCS BEQ BIT BMI BNE BPL BRK BVC BVS
  \ CLC CLD CLI CLV CMP CPX CPY DEC DEX DEY EOR INC INX INY
  \ JMP JSR LDA LDX LDY LSR NOP ORA PHA PHP PLA PLP ROL ROR
  \ RTI RTS SBC SEC SED SEI STA STX STY TAX TAY TSX TXA TXS TYA

highlight link ca65Opcode Statement

" ----------------------------------------------------------------------------
" Registers
" ----------------------------------------------------------------------------
syntax keyword ca65Register A X Y
highlight link ca65Register Identifier

" ----------------------------------------------------------------------------
" Immediate addressing (#$10)
" ----------------------------------------------------------------------------
syntax match ca65Immediate "#\$[0-9A-Fa-f]\+"
syntax match ca65Immediate "#[0-9]\+"
highlight link ca65Immediate Constant

" ----------------------------------------------------------------------------
" Addressing (absolute,X / ,Y)
" ----------------------------------------------------------------------------
syntax match ca65Indexed ",[ ]*[XY]"
highlight link ca65Indexed Type

" ----------------------------------------------------------------------------
" Parenthesis (indirect addressing)
" ----------------------------------------------------------------------------
syntax match ca65Indirect "(\$[0-9A-Fa-f]\+)"
highlight link ca65Indirect Special

" ----------------------------------------------------------------------------
" Macros / Procedures
" ----------------------------------------------------------------------------
syntax region ca65Proc
  \ matchgroup=ca65Directive start="\.proc"
  \ end="\.endproc"
  \ contains=ALL

highlight link ca65Proc Structure

syntax region ca65Macro
  \ matchgroup=ca65Directive start="\.macro"
  \ end="\.endmacro"
  \ contains=ALL

highlight link ca65Macro Macro

" ----------------------------------------------------------------------------
" Constants (ALL_CAPS)
" ----------------------------------------------------------------------------
syntax match ca65Constant "\<[A-Z_][A-Z0-9_]*\>"
highlight link ca65Constant Constant

" ----------------------------------------------------------------------------
" Todos
" ----------------------------------------------------------------------------
syntax match ca65Todo "TODO\|FIXME\|NOTE" containedin=ca65Comment
highlight link ca65Todo Todo

" ----------------------------------------------------------------------------
" ZERO PAGE ($0000-$00FF)
" ----------------------------------------------------------------------------
syntax match nesZeroPage /\$\x\{1,2}\>/
syntax match nesZeroPage /\$00\x\{2}\>/

syntax match ca65Hex /\$\x\+/

" ----------------------------------------------------------------------------
" PPU REGISTERS ($2000-$2007)
" ----------------------------------------------------------------------------
syntax match nesPPURegister "\$200[0-7]"
highlight link nesPPURegister Special

" ----------------------------------------------------------------------------
" Symbolic names
" ----------------------------------------------------------------------------
syntax keyword nesPPUSymbol PPUCTRL PPUMASK PPUSTATUS OAMADDR OAMDATA PPUSCROLL PPUADDR PPUDATA
highlight link nesPPUSymbol Identifier

" ----------------------------------------------------------------------------
" APU + IO ($4000-$4017)
" ----------------------------------------------------------------------------
syntax match nesAPURegister "\$40[0-1][0-9A-Fa-f]"
highlight link nesAPURegister Special

syntax keyword nesAPUSymbol SQ1_VOL SQ1_SWEEP SQ1_LO SQ1_HI SQ2_VOL SQ2_SWEEP SQ2_LO SQ2_HI TRI_LINEAR TRI_LO TRI_HI NOISE_VOL NOISE_LO NOISE_HI DMC_FREQ DMC_RAW DMC_START DMC_LEN OAMDMA JOY1 JOY2 APUSTATUS
highlight link nesAPUSymbol Identifier

" ----------------------------------------------------------------------------
let b:current_syntax = "asm_ca65"
