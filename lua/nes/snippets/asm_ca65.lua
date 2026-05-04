local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node

return {

	-- Load/Store
	s("lda", { t("LDA "), i(1) }),
	s("ldai", { t("LDA #$"), i(1) }),
	s("lday", { t("LDA ($"), i(1), t("), Y") }),
	s("ldax", { t("LDA ($"), i(1), t("), X") }),

	s("ldx", { t("LDX "), i(1) }),
	s("ldy", { t("LDY "), i(1) }),

	s("sta", { t("STA "), i(1) }),
	s("stay", { t("STA ($"), i(1), t("), Y") }),
	s("stax", { t("STA ($"), i(1), t("), X") }),

	-- Jumps / branches
	s("jmp", { t("JMP "), i(1) }),

	s("beq", { t("BEQ "), i(1) }),
	s("bne", { t("BNE "), i(1) }),
	s("bcs", { t("BCS "), i(1) }),
	s("bcc", { t("BCC "), i(1) }),
	s("bmi", { t("BMI "), i(1) }),
	s("bpl", { t("BPL "), i(1) }),
	s("bvs", { t("BVS "), i(1) }),
	s("bvc", { t("BVC "), i(1) }),

	-- Flags
	s("clc", { t("CLC") }),
	s("sec", { t("SEC") }),

	-- Inc/Dec
	s("inc", { t("INC "), i(1) }),
	s("inx", { t("INX") }),
	s("iny", { t("INY") }),

	s("dec", { t("DEC "), i(1) }),
	s("dex", { t("DEX") }),
	s("dey", { t("DEY") }),

	-- Arithmetic
	s("adc", { t("ADC "), i(1) }),
	s("adci", { t("ADC #$"), i(1) }),
	s("adcx", { t("ADC ($"), i(1), t("), X") }),
	s("adcy", { t("ADC ($"), i(1), t("), Y") }),

	s("sbc", { t("SBC "), i(1) }),
	s("sbci", { t("SBC #$"), i(1) }),
	s("sbcx", { t("SBC ($"), i(1), t("), X") }),
	s("sbcy", { t("SBC ($"), i(1), t("), Y") }),

	-- Compare
	s("cmp", { t("CMP "), i(1) }),
	s("cpx", { t("CPX "), i(1) }),
	s("cpy", { t("CPY "), i(1) }),

}
