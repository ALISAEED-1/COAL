; ============================================
; Digital Clock — 1 Second Accurate Update
; Waits for RTC second to change (INT 1Ah AH=02h)
; ============================================

.MODEL SMALL
.STACK 100h

.DATA
    time_str    DB  "HH:MM:SS", 13, 10, '$'
    prev_sec    DB  0FFh        ; stores last second value

.CODE
MAIN PROC
    MOV AX, @DATA
    MOV DS, AX

    ; Set cursor top-left
    MOV AH, 02h
    MOV BH, 00h
    MOV DH, 00h
    MOV DL, 00h
    INT 10h

CLOCK_LOOP:
    ; ----------------------------
    ; STEP 1: Get RTC time
    ; CH=hours, CL=minutes, DH=seconds (all BCD)
    ; ----------------------------
    MOV AH, 02h
    INT 1Ah

    ; ----------------------------
    ; STEP 2: Wait until second changes
    ; Compare new DH with saved prev_sec
    ; If same → keep looping (no update yet)
    ; If different → update display
    ; ----------------------------
    CMP DH, prev_sec
    JE  CLOCK_LOOP          ; Same second → wait

    MOV prev_sec, DH        ; Save new second

    ; ----------------------------
    ; STEP 3: Convert BCD → ASCII
    ; ----------------------------

    ; Hours
    MOV AL, CH
    CALL BCD_TO_ASCII
    MOV time_str[0], AH
    MOV time_str[1], AL

    ; Minutes
    MOV AL, CL
    CALL BCD_TO_ASCII
    MOV time_str[3], AH
    MOV time_str[4], AL

    ; Seconds
    MOV AL, DH
    CALL BCD_TO_ASCII
    MOV time_str[6], AH
    MOV time_str[7], AL

    ; ----------------------------
    ; STEP 4: Reset cursor and display
    ; ----------------------------
    MOV AH, 02h
    MOV BH, 00h
    MOV DH, 00h
    MOV DL, 00h
    INT 10h

    MOV AH, 09h
    LEA DX, time_str
    INT 21h

    ; ----------------------------
    ; STEP 5: Check for keypress
    ; ----------------------------
    MOV AH, 01h
    INT 16h
    JZ  CLOCK_LOOP          ; No key → loop

    MOV AH, 00h
    INT 16h                 ; Flush key

    MOV AH, 4Ch
    MOV AL, 00h
    INT 21h

MAIN ENDP

; ----------------------------
; BCD_TO_ASCII
; IN:  AL = BCD byte
; OUT: AH = tens ASCII, AL = units ASCII
; ----------------------------
BCD_TO_ASCII PROC
    MOV AH, AL
    SHR AH, 4
    AND AL, 0Fh
    ADD AH, 30h
    ADD AL, 30h
    RET
BCD_TO_ASCII ENDP

END MAIN