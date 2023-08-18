// format: (assembly instruction)_(addressing mode)
pub const Opcode = enum(u8) {
    // Add with Carry
    adc_immediate = 0x69,
    adc_zero_page = 0x65,
    adc_zero_page_x = 0x75,
    adc_absolute = 0x6D,
    adc_absolute_x = 0x7D,
    adc_absolute_y = 0x79,
    adc_indirect_x = 0x61,
    adc_indirect_y = 0x71,

    // Logical And
    and_immediate = 0x29,
    and_zero_page = 0x25,
    and_zero_page_x = 0x35,
    and_absolute = 0x2D,
    and_absolute_x = 0x3D,
    and_absolute_y = 0x39,
    and_indirect_x = 0x21,
    and_indirect_y = 0x31,

    // Arithmetic Left Shift
    asl_accumulator = 0x0A,
    asl_zero_page = 0x06,
    asl_zero_page_x = 0x16,
    asl_absolute = 0x0E,
    asl_absolute_x = 0x1E,

    // Branch if Carry Clear
    bcc_relative = 0x90,

    // Branch if Carry Set
    bcs_relative = 0xB0,

    // Branch if Equal
    beq_relative = 0xF0,

    // Bit Test
    bit_zero_page = 0x24,
    bit_absolute = 0x2C,

    // Branch if Minus
    bmi_relative = 0x30,

    // Branch if Not Equal
    bne_relative = 0xD0,

    // Branch if Positive
    bpl_relative = 0x10,

    // Force Interrupt
    brk_implied = 0x00,

    // Branch if Overflow Clear
    bvc_relative = 0x50,

    // Branch if Overflow Set
    bvs_relative = 0x70,

    // Clear Carry Flag
    clc_implied = 0x18,

    // Clear Decimal Mode
    cld_implied = 0xD8,

    // Clear Interrupt Disable
    cli_implied = 0x58,

    // Clear Overflow Flag
    clv_implied = 0xB8,

    // Compare
    cmp_immediate = 0xC9,
    cmp_zero_page = 0xC5,
    cmp_zero_page_x = 0xD5,
    cmp_absolute = 0xCD,
    cmp_absolute_x = 0xDD,
    cmp_absolute_y = 0xD9,
    cmp_indirect_x = 0xC1,
    cmp_indirect_y = 0xD1,

    // Compare X Register
    cpx_immediate = 0xE0,
    cpx_zero_page = 0xE4,
    cpx_absolute = 0xEC,

    // Compare Y Register
    cpy_immediate = 0xC0,
    cpy_zero_page = 0xC4,
    cpy_absolute = 0xCC,

    // Decrement Memory
    dec_zero_page = 0xC6,
    dec_zero_page_x = 0xD6,
    dec_absolute = 0xCE,
    dec_absolute_x = 0xDE,

    // Decrement X Register
    dex_implied = 0xCA,

    // Decrement Y Register
    dey_implied = 0x88,

    // Exclusive OR
    eor_immediate = 0x49,
    eor_zero_page = 0x45,
    eor_zero_page_x = 0x55,
    eor_absolute = 0x4D,
    eor_absolute_x = 0x5D,
    eor_absolute_y = 0x59,
    eor_indirect_x = 0x41,
    eor_indirect_y = 0x51,

    // Increment Memory
    inc_zero_page = 0xE6,
    inc_zero_page_x = 0xF6,
    inc_absolute = 0xEE,
    inc_absolute_x = 0xFE,

    // Increment X Register
    inx_implied = 0xE8,

    // Increment Y Register
    iny_implied = 0xC8,

    // Jump
    jmp_absolute = 0x4C,
    jmp_indirect = 0x6C,

    // Jump to Subroutine
    jsr_absolute = 0x20,

    // Load Accumulator
    lda_immediate = 0xA9,
    lda_zero_page = 0xA5,
    lda_zero_page_x = 0xB5,
    lda_absolute = 0xAD,
    lda_absolute_x = 0xBD,
    lda_absolute_y = 0xB9,
    lda_indirect_x = 0xA1,
    lda_indirect_y = 0xB1,

    // Load X Register
    ldx_immediate = 0xA2,
    ldx_zero_page = 0xA6,
    ldx_zero_page_y = 0xB6,
    ldx_absolute = 0xAE,
    ldx_absolute_y = 0xBE,

    // Load Y Register
    ldy_immediate = 0xA0,
    ldy_zero_page = 0xA4,
    ldy_zero_page_x = 0xB4,
    ldy_absolute = 0xAC,
    ldy_absolute_x = 0xBC,

    // Logical Right Shift
    lsr_accumulator = 0x4A,
    lsr_zero_page = 0x46,
    lsr_zero_page_x = 0x56,
    lsr_absolute = 0x4E,
    lsr_absolute_x = 0x5E,

    // No Operation
    nop_implied = 0xEA,

    // Logical Inclusive OR
    ora_immediate = 0x09,
    ora_zero_page = 0x05,
    ora_zero_page_x = 0x15,
    ora_absolute = 0x0D,
    ora_absolute_x = 0x1D,
    ora_absolute_y = 0x19,
    ora_indirect_x = 0x01,
    ora_indirect_y = 0x11,

    // Push Accumulator
    pha_implied = 0x48,

    // Push Processor Status
    php_implied = 0x08,

    // Pull Accumulator
    pla_implied = 0x68,

    // Pull Processor Status
    plp_implied = 0x28,

    // Rotate Left
    rol_accumulator = 0x2A,
    rol_zero_page = 0x26,
    rol_zero_page_x = 0x36,
    rol_absolute = 0x2E,
    rol_absolute_x = 0x3E,

    // Rotate Right
    ror_accumulator = 0x6A,
    ror_zero_page = 0x66,
    ror_zero_page_x = 0x76,
    ror_absolute = 0x6E,
    ror_absolute_x = 0x7E,

    // Return from Interrupt
    rti_implied = 0x40,

    // Return from Subroutine
    rts_implied = 0x60,

    // Subtract with Carry
    sbc_immediate = 0xE9,
    sbc_zero_page = 0xE5,
    sbc_zero_page_x = 0xF5,
    sbc_absolute = 0xED,
    sbc_absolute_x = 0xFD,
    sbc_absolute_y = 0xF9,
    sbc_indirect_x = 0xE1,
    sbc_indirect_y = 0xF1,

    // Set Carry Flag
    sec_implied = 0x38,

    // Set Decimal Flag
    sed_implied = 0xF8,

    // Set Interrupt Disable
    sei_implied = 0x78,

    // Store Accumulator
    sta_zero_page = 0x85,
    sta_zero_page_x = 0x95,
    sta_absolute = 0x8D,
    sta_absolute_x = 0x9D,
    sta_absolute_y = 0x99,
    sta_indirect_x = 0x81,
    sta_indirect_y = 0x91,

    // Store X Register
    stx_zero_page = 0x86,
    stx_zero_page_y = 0x96,
    stx_absolute = 0x8E,

    // Store Y Register
    sty_zero_page = 0x84,
    sty_zero_page_x = 0x94,
    sty_absolute = 0x8C,

    // Transfer Accumulator to X
    tax_implied = 0xAA,

    // Transfer Accumulator to Y
    tay_implied = 0xA8,

    // Transfer Stack Pointer to X
    tsx_implied = 0xBA,

    // Transfer X to Accumulator
    txa_implied = 0x8A,

    // Transfer X to Stack Pointer
    txs_implied = 0x9A,

    // Transfer Y to Accumulator
    tya_implied = 0x98,
};
