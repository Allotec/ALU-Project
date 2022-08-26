;;; Test program that will exercise most functions of the ALU
;;; When the ALU operates correctly the program should output
;;; what is found in test_reference.output

        clear r0
        clear r1
        clear r2
        clear r3
        loadhi r0 = 1
;;; Print HRT
        ;; H
        loadlo r1 = 8
        add r2 = r0 r1
        out r2
        ;; R
        loadlo r1 = 18
        add r2 = r0 r1
        out r2
        ;; T
        loadlo r1 = 20
        add r2 = r0 r1
        out r2
;;; or
        clear r0
        loadlo r0 = 0x3f
        clear r1
        loadhi r1 = 0x3f
        or r2 = r0 r1
        out r2
;;; xor
        clear r1
        loadlo r1 = 0x3f
        clear r2
        loadhi r2 = 0x3f
        xor r3 = r1 r2
        out r3
;;; and
        clear r2
        loadlo r2 = 0x3f
        clear r3
        loadhi r3 = 0x3f
        and r0 = r2 r3
        out r0
;;; not
        clear r2
        loadlo r2 = 0x3f
        not r0 = r2
        out r0
;;; lshift
        lshift r0 = r0
        out r0
;;; rshift
        rshift r0 = r0
        out r0
;;; arshift
        arshift r0 = r0
        clear r0
        loadhi r0 = 0x3f
        arshift r0 = r0
        out r0
;;; add
        clear r0
        clear r1
        loadlo r0 = 0x3f
        loadlo r1 = 1
        add r2 = r0 r1
        out r2
;;; addc
        clear r0
        clear r1
        loadlo r0 = 0x3f
        loadlo r1 = 1
        addc r2 = r0 r1
        out r2
;;; add
        clear r0
        clear r1
        loadhi r0 = 0x3f
        loadhi r1 = 1
        add r2 = r0 r1
        out r2
;;; addc
        clear r0
        clear r1
        addc r2 = r0 r1
        out r2
;;; sub
        clear r0
        clear r1
        loadlo r0 = 0x3f
        loadlo r1 = 1
        sub r2 = r0 r1
        out r2
;;; dump regs
        out r0
        out r1
        out r2
        out r3
;;; end
        halt r0
