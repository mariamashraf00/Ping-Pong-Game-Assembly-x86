;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
GetKeyPress MACRO
    LOCAL NothingPressed
	MOV AH, 01H
    INT 16H
	JZ NothingPressed
    MOV AH, 00H
    INT 16H
    NothingPressed:
ENDM GetKeyPress
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

MoveCursor MACRO X,Y
    mov ah, 2
    mov dl, X
    mov dh, Y
    int 10h
endm
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
PrintStr MACRO str
    mov ah,9
    mov dx, offset str
    int 21h
endm
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
ClearScreen MACRO
    mov ah,00
    mov al,06
    int 10h
endm
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
PrintChar MACRO MyChar
    MOV AH, 02H
    MOV DL, MyChar
    INT 21H
ENDM PrintChar
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
PrintNotification MACRO str,name
    ScrollUp 0,79,23,24
    MoveCursor 1, 23
    PrintStr str
    PrintStr name
endm

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
ScrollUp MACRO X1,X2,Y1,Y2
    mov     ah, 06h ; scroll up function id.
    mov     al, 1   ; lines to scroll.
    mov     bh, 0  ; attribute for new lines.
    mov     cl, X1  ; upper col.
    mov     ch, Y1  ; upper row.
    mov     dl, X2  ; lower col.
    mov     dh, Y2  ; lower row.
    int     10h
ENDM 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
CharCheck MACRO Char, X, Y, MinY, MaxY
    LOCAL EscCheck, EnterCheck, BackCheck, Printable, ChangeCursor, Done,Scroll
    EscCheck:  
    CMP Char, 1bh
    JNE EnterCheck
    MOV chatended, 1
    jmp Done

    EnterCheck:
    CMP char, 0dh
    JNE BackCheck
    MOV X, 1
    INC Y
	JMP Scroll
    
    BackCheck:
    CMP char, 08h
    JNE Printable
    CMP X, 1
    JBE Printable
    MOV char, ' '
    DEC X
    MoveCursor X, Y
    PrintChar char
    RET
    
    Printable:
    CMP char, ' '  
    JB Done
    CMP char, '~'   
    JA Done
    
    MoveCursor X,Y
    PrintChar char    
	
    ChangeCursor:
    INC X
    CMP X, 79
    JL Done
    MOV X, 1
    INC Y

	Scroll:
    CMP Y, MaxY
    JBE Done
    DEC Y
    ScrollUp 0,79,MinY, MaxY
    Done:
ENDM
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
GameCharCheck MACRO Char, X, Y, MinX, MaxX, MinY, MaxY
    LOCAL EscCheck, EnterCheck, BackCheck, Printable, ChangeCursor, Done,Scroll
    EscCheck:
    CMP Char, 3Dh
    JNE EnterCheck
    MOV switchtogame, 1
    INC Y
    Mov X,MinX
    jmp Done

    EnterCheck:
    CMP char, 0dh
    JNE BackCheck
    MOV X, MinX
    INC Y
	JMP Scroll
    
    BackCheck:
    CMP char, 08h
    JNE Printable
    CMP X, MinX
    JBE Printable
    MOV char, ' '
    DEC X
    MoveCursor X, Y
    PrintChar char
    RET
    
    Printable:
    CMP char, ' '  
    JB Done
    CMP char, '~'   
    JA Done
    
    MoveCursor X,Y
    PrintChar char    
	
    ChangeCursor:
    INC X
    CMP X, MaxX
    JL Done
    MOV X, MinX
    INC Y

	Scroll:
    CMP Y, MaxY
    JBE Done
    DEC Y
    ScrollUp MinX,MaxX,MinY, MaxY
    
    Done:
ENDM
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
ClearBackground MACRO
            ;setting up the video mode
    mov     ah, 06h ; scroll up function id.
    mov     al, 0  ; lines to scroll.
    mov     bh, 0  ; attribute for new lines.
    mov     cl, 0  ; upper col.
    mov     ch, 0  ; upper row.
    mov     dl, 79  ; lower col.
    mov     dh, 10h  ; lower row.
    int     10h

endm
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

.model small

.data
ErrorMsg DB 'Name Must Start With Letter$'
EnterName DB 'Please Enter your Name:$' 
WaitMsg DB 'Waiting For Connection...$'

UserName DB 15,0,15 DUP ('$')
PartnerName DB 15,0,15 DUP ('$')

PressEnter DB 'Press Enter to Continue$' 
ChatMsg DB '*To start chatting, Press F1$'
GameMsg DB '*To start game, Press F2$' 
ExitMsg DB '*To Exit, Press ESC$'
ChatInvitationSentMsg       DB      'You Sent a Chat Invitation To: $'
ChatInvitationReceivedMsg   DB      'Press Y to Accept Chat Invitation or N to Refuse From: $'
GameInvitationSentMsg       DB      'You Sent a Game Invitation To: $'
GameInvitationReceivedMsg   DB      'Press Y to Accept Game Invitation or N to Refuse From: $' 
CharacterSent DB (?)
CharacterReceived DB 0FFh
ThanksMsg db  " Disconnected,Thanks For Using Our App$"

;Chat
UserX db 1
UserY db 1             
PartnerX db 1       
PartnerY db 13
chatended db 0
EndChatMsg db 'Press ESC to end chatting...$'

;InGameChat
switchtochat db 0
switchtogame db 0
initiated db 0
gameended db 0
GameUserX db 01h
GameUserY db 13h
GamePartnerX db 16h 
GamePartnerY db 13h

;Game Checks
User1char db ?
User2char db ?
SpacePermission db 0
Level1 db "Level 1 was chosen$"
Level2 db "Level 2 was chosen$"
temp db 0


;GAME VARIABLES
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 windowBounds dw 1 ;to check collisions before crashing
 windowWidth dw 140h
 windowHeight dw 78h    ;origin c8
 Time db 0

Pcharachter db 0h,0h,04h,04h,04h,04h,04h,04h,04h,04h,04h,04h,04h,04h,04h,04h,04h,0h,0h,0h
            db 0h,04h,04h,04h,04h,04h,04h,04h,04h,04h,04h,04h,04h,04h,04h,04h,04h,04h,4h,0h
            db 04h,04h,04h,04h,04h,04h,0h,0h,0h,0h,0h,0h,0h,0h,0h,04h,04h,04h,04h,04h
            db 04h,04h,04h,04h,04h,04h,0h,0h,0h,0h,0h,0h,0h,0h,0h,04h,04h,04h,04h,04h
            db 04h,04h,04h,04h,04h,04h,0h,0h,0h,0h,0h,0h,0h,0h,0h,04h,04h,04h,04h,04h
            db 04h,04h,04h,04h,04h,04h,0h,0h,0h,0h,0h,0h,0h,0h,0h,04h,04h,04h,04h,04h
            db 04h,04h,04h,04h,04h,04h,04h,04h,04h,04h,04h,04h,04h,04h,04h,04h,04h,04h,04h,04h
            db 04h,04h,04h,04h,04h,04h,04h,04h,04h,04h,04h,04h,04h,04h,04h,04h,04h,04h,04h,04h
            db 04h,04h,04h,04h,04h,04h,04h,04h,04h,04h,04h,04h,04h,04h,04h,04h,04h,04h,04h,0h
            db 04h,04h,04h,04h,04h,04h,04h,04h,04h,04h,04h,04h,04h,04h,04h,04h,04h,04h,04h,0h
             db 04h,04h,04h,04h,04h,04h,04h,0h,0h,0h,0h,0h,0h,0h,0h,0h,0h,0h,0h,0h
             db 04h,04h,04h,04h,04h,04h,04h,0h,0h,0h,0h,0h,0h,0h,0h,0h,0h,0h,0h,0h
             db 04h,04h,04h,04h,04h,04h,04h,0h,0h,0h,0h,0h,0h,0h,0h,0h,0h,0h,0h,0h
             db 04h,04h,04h,04h,04h,04h,04h,0h,0h,0h,0h,0h,0h,0h,0h,0h,0h,0h,0h,0h
             db 04h,04h,04h,04h,04h,04h,04h,0h,0h,0h,0h,0h,0h,0h,0h,0h,0h,0h,0h,0h
             db 04h,04h,04h,04h,04h,04h,04h,0h,0h,0h,0h,0h,0h,0h,0h,0h,0h,0h,0h,0h
             db 04h,04h,04h,04h,04h,04h,04h,0h,0h,0h,0h,0h,0h,0h,0h,0h,0h,0h,0h,0h
             db 04h,04h,04h,04h,04h,04h,04h,0h,0h,0h,0h,0h,0h,0h,0h,0h,0h,0h,0h,0h
             db 04h,04h,04h,04h,04h,04h,04h,0h,0h,0h,0h,0h,0h,0h,0h,0h,0h,0h,0h,0h
             db 0h,04h,04h,04h,04h,04h,0h,0h,0h,0h,0h,0h,0h,0h,0h,0h,0h,0h,0h,0h        

Ochar        db 0h,0h,04h,04h,04h,04h,04h,04h,04h,04h,04h,04h,04h,04h,04h,04h,04h,04h,0h,0h
             db 0h,0h,04h,04h,04h,04h,04h,04h,04h,04h,04h,04h,04h,04h,04h,04h,04h,04h,0h,0h
             db 04h,04h,04h,04h,04h,04h,04h,04h,04h,04h,04h,04h,04h,04h,04h,04h,04h,04h,04h,04h
             db 04h,04h,04h,04h,04h,04h,04h,04h,04h,04h,04h,04h,04h,04h,04h,04h,04h,04h,04h,04h
             db 04h,04h,04h,04h,04h,04h,04h,04h,04h,04h,04h,04h,04h,04h,04h,04h,04h,04h,04h,04h
             db 04h,04h,04h,04h,04h,04h,04h,04h,04h,04h,04h,04h,04h,04h,04h,04h,04h,04h,04h,04h
             db 04h,04h,04h,04h,04h,00h,00h,00h,00h,00h,00h,00h,00h,0h,0h,04h,04h,04h,04h,04h
             db 04h,04h,04h,04h,04h,00h,00h,00h,00h,00h,00h,00h,00h,0h,0h,04h,04h,04h,04h,04h
             db 04h,04h,04h,04h,04h,00h,00h,00h,00h,00h,00h,00h,00h,0h,0h,04h,04h,04h,04h,04h
             db 04h,04h,04h,04h,04h,00h,00h,00h,00h,00h,00h,00h,00h,0h,0h,04h,04h,04h,04h,04h
             db 04h,04h,04h,04h,04h,00h,00h,00h,00h,00h,00h,00h,00h,0h,0h,04h,04h,04h,04h,04h  
             db 04h,04h,04h,04h,04h,00h,00h,00h,00h,00h,00h,00h,00h,0h,0h,04h,04h,04h,04h,04h
             db 04h,04h,04h,04h,04h,00h,00h,00h,00h,00h,00h,00h,00h,0h,0h,04h,04h,04h,04h,04h
             db 04h,04h,04h,04h,04h,04h,04h,04h,04h,04h,04h,04h,04h,04h,04h,04h,04h,04h,04h,04h
             db 04h,04h,04h,04h,04h,04h,04h,04h,04h,04h,04h,04h,04h,04h,04h,04h,04h,04h,04h,04h
             db 04h,04h,04h,04h,04h,04h,04h,04h,04h,04h,04h,04h,04h,04h,04h,04h,04h,04h,04h,04h
             db 04h,04h,04h,04h,04h,04h,04h,04h,04h,04h,04h,04h,04h,04h,04h,04h,04h,04h,04h,04h
             db 04h,04h,04h,04h,04h,04h,04h,04h,04h,04h,04h,04h,04h,04h,04h,04h,04h,04h,04h,04h
             db 0h,0h,04h,04h,04h,04h,04h,04h,04h,04h,04h,04h,04h,04h,04h,04h,04h,04h,0h,0h
             db 0h,0h,04h,04h,04h,04h,04h,04h,04h,04h,04h,04h,04h,04h,04h,04h,04h,04h,0h,0h
         
Nchar        db 04h,04h,04h,04h,0h,0h,0h,0h,0h,0h,0h,0h,0h,0h,04h,04h,04h,04h,04h,04h
             db 04h,04h,04h,04h,04h,0h,0h,0h,0h,0h,0h,0h,0h,0h,04h,04h,04h,04h,04h,04h
             db 04h,04h,04h,04h,04h,04h,0h,0h,0h,0h,0h,0h,0h,0h,04h,04h,04h,04h,04h,04h
             db 04h,04h,04h,04h,04h,04h,04h,0h,0h,0h,0h,0h,0h,0h,04h,04h,04h,04h,04h,04h
             db 04h,04h,04h,04h,04h,04h,04h,04h,0h,0h,0h,0h,0h,0h,04h,04h,04h,04h,04h,04h
             db 04h,04h,04h,04h,04h,04h,04h,04h,04h,0h,0h,0h,0h,0h,04h,04h,04h,04h,04h,04h
             db 04h,04h,04h,04h,04h,04h,04h,04h,04h,04h,0h,0h,0h,0h,04h,04h,04h,04h,04h,04h
             db 04h,04h,04h,04h,04h,04h,04h,04h,04h,04h,04h,0h,0h,0h,04h,04h,04h,04h,04h,04h
             db 04h,04h,04h,04h,04h,04h,04h,04h,04h,04h,04h,04h,0h,0h,04h,04h,04h,04h,04h,04h
             db 04h,04h,04h,04h,04h,0h,04h,04h,04h,04h,04h,04h,04h,0h,04h,04h,04h,04h,04h,04h
             db 04h,04h,04h,04h,04h,0h,0h,04h,04h,04h,04h,04h,04h,04h,04h,04h,04h,04h,04h,04h
             db 04h,04h,04h,04h,04h,0h,0h,0h,04h,04h,04h,04h,04h,04h,04h,04h,04h,04h,04h,04h
             db 04h,04h,04h,04h,04h,0h,0h,0h,0h,04h,04h,04h,04h,04h,04h,04h,04h,04h,04h,04h
             db 04h,04h,04h,04h,04h,0h,0h,0h,0h,0h,04h,04h,04h,04h,04h,04h,04h,04h,04h,04h
             db 04h,04h,04h,04h,04h,0h,0h,0h,0h,0h,0h,04h,04h,04h,04h,04h,04h,04h,04h,04h
             db 04h,04h,04h,04h,04h,0h,0h,0h,0h,0h,0h,0h,04h,04h,04h,04h,04h,04h,04h,04h
             db 04h,04h,04h,04h,04h,0h,0h,0h,0h,0h,0h,0h,0h,04h,04h,04h,04h,04h,04h,04h
             db 04h,04h,04h,04h,04h,0h,0h,0h,0h,0h,0h,0h,0h,0h,04h,04h,04h,04h,04h,04h
             db 04h,04h,04h,04h,04h,0h,0h,0h,0h,0h,0h,0h,0h,0h,0h,04h,04h,04h,04h,04h
             db 04h,04h,04h,04h,04h,0h,0h,0h,0h,0h,0h,0h,0h,0h,0h,0h,04h,04h,04h,04h

Gchar        db 0h,04h,04h,04h,04h,04h,04h,04h,04h,04h,04h,04h,04h,04h,04h,04h,04h,04h,04h,0h
             db 04h,04h,04h,04h,04h,04h,04h,04h,04h,04h,04h,04h,04h,04h,04h,04h,04h,04h,04h,0h
             db 04h,04h,04h,04h,04h,04h,04h,04h,04h,04h,04h,04h,04h,04h,04h,04h,04h,04h,04h,04h
             db 04h,04h,04h,04h,04h,04h,04h,04h,04h,04h,04h,04h,04h,04h,04h,04h,04h,04h,04h,04h
             db 04h,04h,04h,04h,04h,04h,04h,04h,04h,04h,04h,04h,04h,04h,04h,04h,04h,04h,04h,04h
             db 04h,04h,04h,04h,04h,0h,0h,0h,0h,0h,0h,0h,0h,0h,0h,0h,0h,0h,0h,0h
             db 04h,04h,04h,04h,04h,00h,00h,00h,00h,00h,00h,00h,00h,0h,0h,0h,0h,0h,0h,0h
             db 04h,04h,04h,04h,04h,00h,00h,00h,00h,00h,00h,00h,00h,0h,0h,0h,0h,0h,0h,0h
             db 04h,04h,04h,04h,04h,00h,00h,00h,00h,00h,00h,00h,00h,0h,0h,0h,0h,0h,0h,0h
             db 04h,04h,04h,04h,04h,00h,00h,00h,00h,00h,0h,0h,0h,0h,0h,0h,0h,0h,0h,0h
             db 04h,04h,04h,04h,04h,00h,00h,00h,00h,00h,04h,04h,04h,04h, 04h,04h,04h,04h,04h,04h  
             db 04h,04h,04h,04h,04h,00h,00h,00h,00h,00h,04h,04h,04h,04h  ,04h,04h,04h,04h,04h,04h
             db 04h,04h,04h,04h,04h,00h,00h,00h,00h,00h,04h,04h,04h,04h, 04h,04h,04h,04h,04h,04h
             db 04h,04h,04h,04h,04h,0h,0h,0h,0h,0h,0h,0h,0h,0h,         04h,04h,04h,04h,04h,04h
             db 04h,04h,04h,04h,04h,0h,0h,0h,0h,0h,0h,0h,0h,0h,         04h,04h,04h,04h,04h,04h
             db 04h,04h,04h,04h,04h,0h,0h,0h,0h,0h,0h,0h,0h,0h,         04h,04h,04h,04h,04h,04h
             db 04h,04h,04h,04h,04h,04h,04h,04h,04h,04h,04h,04h,04h,04h,04h,04h,04h,04h,04h,04h
             db 04h,04h,04h,04h,04h,04h,04h,04h,04h,04h,04h,04h,04h,04h,04h,04h,04h,04h,04h,04h
             db 04h,04h,04h,04h,04h,04h,04h,04h,04h,04h,04h,04h,04h,04h,04h,04h,04h,04h,04h,0h
             db 0h,04h,04h,04h,04h,04h,04h,04h,04h,04h,04h,04h,04h,04h,04h,04h,04h,04h,4h,0h

ball db 0h ,0h ,0h , 0h ,0h ,0h ,0h ,0h ,0h ,0h 
     db 0h ,0h ,0h , 0h ,0h ,0h ,0h ,0h ,0h ,0h
     db 0h ,0h ,04h , 04h ,04h ,04h ,04h ,0h ,0h ,0h 
     db 0h ,04h ,04h , 04h ,04h ,04h ,04h ,04h ,0h ,0h 
     db 0h ,04h ,04h , 04h ,04h ,04h ,04h ,04h ,0h ,0h 
     db 0h ,04h ,04h , 04h ,04h ,04h ,04h ,04h ,0h ,0h 
     db 0h ,0h ,04h , 04h ,04h ,04h ,04h ,0h ,0h ,0h 
     db 0h ,0h ,0h , 04h ,04h ,04h ,0h ,0h ,0h ,0h 
     db 0h ,0h ,0h , 0h ,0h ,0h ,0h ,0h ,0h ,0h 
     db 0h ,0h ,0h , 0h ,0h ,0h ,0h ,0h ,0h ,0h 

    Ppong  DB 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0    
            DB 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
            DB 0, 0, 0, 0, 0, 0h, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
            DB 0, 0, 0, 0, 0, 0, 0, 0, 0, 0h, 04h, 04h, 04h, 04h, 04h, 04h, 04h, 04h, 04h, 0
            DB 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 04h, 04h
            DB 04h, 04h, 04h, 04h, 04h, 04h, 04h, 04h, 04h, 04h, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0   
            DB 0, 0, 0, 0, 0, 0, 0, 04h, 04h, 04h, 04h, 04h, 04h, 04h, 04h, 04h, 04h, 04h, 04h, 04h 
            DB 04h, 04h, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 04h, 04h, 04h, 04h
            DB 04h, 04h, 04h, 04h, 04h, 04h, 04h, 04h, 04h, 04h, 04h, 04h, 04h, 0, 0, 0, 0, 0, 0, 0
            DB 0, 0, 0, 0, 0, 04h, 04h, 04h, 04h, 04h, 04h, 04h, 04h, 04h, 04h, 04h, 04h, 04h, 04h, 04h
            DB 04h, 04h, 04h, 04h, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 04h, 04h, 04h, 04h, 04h, 04h
            DB 04h, 04h, 04h, 04h, 04h, 04h, 04h , 04h, 04h, 04h, 04h, 04h, 04h, 04h, 04h, 0, 0, 0, 0, 0
            DB 0, 0, 0, 0, 04h, 04h, 04h, 04h, 04h, 04h, 04h, 04h, 04h, 04h, 04h, 04h, 04h, 04h, 04h, 04h
            DB 04h, 04h, 04h, 04h, 04h, 0, 0, 0, 0, 0, 0, 0, 0, 04h, 04h, 04h, 04h, 04h, 04h, 04h
            DB 04h, 04h, 04h, 04h, 04h, 04h, 04h, 04h, 04h, 04h, 04h, 04h, 04h, 04h, 04h, 04h, 0, 0, 0, 0
            DB 0, 0, 0, 04h, 04h, 04h, 04h, 04h, 04h, 04h, 04h, 04h, 04h, 04h, 04h, 04h, 04h, 04h, 04h, 04h
            DB 04h, 04h, 04h, 04h, 04h, 04h, 0, 0, 0, 0, 0, 0, 04h, 04h, 04h, 04h, 04h, 04h, 04h, 04h
            DB 04h, 04h, 04h, 04h, 04h, 04h, 04h, 04h, 04h, 04h, 04h, 04h, 04h, 04h, 04h, 04h, 04h, 0, 0, 0
            DB 0, 0, 04h, 04h, 04h, 04h, 04h, 04h, 04h, 04h, 04h, 04h, 04h, 04h, 04h, 04h, 04h, 04h, 04h, 04h
            DB 04h, 04h, 04h, 04h, 04h, 04h, 04h, 0, 0, 0, 0, 0, 04h, 04h, 04h, 04h, 04h, 04h, 04h, 04h
            DB 04h, 04h, 04h, 04h, 04h, 04h, 04h, 04h, 04h, 04h, 04h, 04h, 04h, 04h, 04h, 04h, 04h, 0, 0, 0
            DB 0, 0, 04h, 04h, 04h, 04h, 04h, 04h, 04h, 04h, 04h, 04h, 04h, 04h, 04h, 04h, 04h, 04h, 04h, 04h
            DB 04h, 04h, 04h, 04h, 04h, 04h, 04h, 0, 0, 0, 0, 0, 04h, 04h, 04h, 04h, 04h, 04h, 04h, 04h
            DB 04h, 04h, 04h, 04h, 04h, 04h, 04h, 04h, 04h, 04h, 04h, 04h, 04h, 04h, 04h, 04h, 04h, 0, 0, 0
            DB 0, 0, 04h, 04h, 04h, 04h, 04h, 04h, 04h, 04h, 04h, 04h, 04h, 04h, 04h, 04h, 04h, 04h, 04h, 04h
            DB 04h, 04h, 04h, 04h, 04h, 04h, 04h, 0, 0, 0, 0, 0, 04h, 04h, 04h, 04h, 04h, 04h, 04h, 04h
            DB 04h, 04h, 04h, 04h, 04h, 04h, 04h, 04h, 04h, 04h, 04h, 04h, 04h, 04h, 04h, 04h, 04h, 0, 0, 0
            DB 0, 0, 0, 04h, 04h, 04h, 04h, 04h, 04h, 04h,04h, 04h, 04h, 04h, 04h, 04h, 04h, 04h, 04h, 04h
            DB 04h, 04h, 04h, 04h, 04h, 04h, 0, 0, 0, 0, 0, 0, 0, 04h, 04h, 04h, 04h, 04h, 04h, 04h
            DB 04h, 04h, 04h, 04h, 04h, 04h, 04h, 04h, 04h, 04h, 04h, 04h, 04h, 04h, 04h, 04h, 0, 0, 0, 0
            DB 0, 0, 0, 0, 04h, 04h, 04h, 04h, 04h, 04h, 04h, 04h, 04h, 04h, 04h, 04h, 04h, 04h, 04h, 04h
            DB 04h, 04h, 04h, 04h, 04h, 0, 0, 0, 0, 0, 0, 0, 0, 0, 04h, 04h, 04h, 04h, 04h , 04h    
            DB 04h, 04h, 04h, 04h, 04h, 04h, 04h, 04h, 04h, 04h, 04h, 04h, 04h, 04h, 04h, 0, 0, 0, 0, 0
            DB 0, 0, 0, 0, 0, 04h, 04h, 04h, 04h, 04h, 04h, 04h, 04h, 04h, 04h, 04h, 04h, 04h, 04h, 04h
            DB 04h, 04h, 04h, 04h, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 04h, 04h, 04h, 04h
            DB 04h, 04h, 04h, 04h, 04h, 04h, 04h, 04h, 04h, 04h, 04h, 04h, 04h, 0, 0, 0, 0, 0, 0, 0
            DB 0, 0, 0, 0, 0, 0, 0, 04h,04h,04h, 04h, 04h, 04h, 04h, 04h, 04h, 04h, 04h, 04h, 04h
            DB 04h, 04h, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0h, 0h, 04h
            DB 04h, 04h, 04h, 04h, 04h, 04h, 04h, 04h, 04h, 04h, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
            db 0h, 0h , 0h , 0h , 0h , 0h , 0h ,0h, 0h ,0h , 0h ,0h ,0h , 0h ,0h ,0h,0h,0h, 0h, 0h 
            db 0h, 0h , 0h , 0h , 0h , 0h , 0h ,0h, 0h ,0h , 0h ,0h ,0h , 0h ,0h ,0h,0h,0h, 0h, 0h 
            db 0h, 0h , 0h , 0h , 0h , 0h , 0h ,0h, 0h ,0h , 0h ,0h ,0h , 0h ,0h ,0h,0h,0h, 0h, 0h 
            db 0h, 0h , 0h , 0h , 0h , 0h , 0h ,0h, 0h ,0h , 0h ,0h ,0h , 0h ,0h ,0h,0h,0h, 0h, 0h 
            db 0h, 0h , 0h , 0h , 0h , 0h , 0h ,0h, 0h ,0h , 0h ,0h ,0h , 0h ,0h ,0h,0h,0h, 0h, 0h 
            db 0h, 0h , 0h , 0h , 0h , 0h , 0h ,0h, 0h ,0h , 0h ,0h ,0h , 0h ,0h ,0h,0h,0h, 0h, 0h 

    ball_initX dw 0a0h
    ball_initY dw 37h   ;64h

    ballX dw 0fh ;x pos of the ball     ;origin 120 to the middle of screen
    ballY dw 55 ;y pos of the ball     ;origin 0ah
    ballSize  DW 10 ;size of ball
    ballVelocityX dw 05h ;x-axis velocity
    ballVelocityY dw 03h ;y-axis velocity
    Max_Score dw ?   ; maximum score Can be achieved by the 2 level Game 
    
    xintiat dw ?  ;dimenstion of the required shape in X axis 
    yintiat dw ?   ; dimenstion of the required shape in y axis
    ;:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
User             db 03h,03h,03h,03h,03h
                 db 03h,03h,03h,03h,03h
                 db 03h,03h,03h,03h,03h
                 db 03h,03h,03h,03h,03h
                 db 03h,03h,03h,03h,03h
                 db 03h,03h,03h,03h,03h
                 db 03h,03h,03h,03h,03h
                 db 03h,03h,03h,03h,03h
                 db 03h,03h,03h,03h,03h
                 db 03h,03h,03h,03h,03h
                 db 03h,03h,03h,03h,03h
                 db 03h,03h,03h,03h,03h  
                 db 03h,03h,03h,03h,03h
                 db 07h,07h,07h,07h,07h
                 db 07h,07h,07h,07h,07h
                 db 07h,07h,07h,07h,07h
                 db 07h,07h,07h,07h,07h
                 db 07h,07h,07h,07h,07h
                 db 07h,07h,07h,07h,07h
                 db 07h,07h,07h,07h,07h
                 db 07h,07h,07h,07h,07h
                 db 07h,07h,07h,07h,07h
                 db 07h,07h,07h,07h,07h
                 db 07h,07h,07h,07h,07h
                 db 07h,07h,07h,07h,07h
                 db 07h,07h,07h,07h,07h
                 db 07h,07h,07h,07h,07h
                 db 03h,03h,03h,03h,03h
                 db 03h,03h,03h,03h,03h
                 db 03h,03h,03h,03h,03h  
                 db 03h,03h,03h,03h,03h
                 db 03h,03h,03h,03h,03h
                 db 03h,03h,03h,03h,03h
                 db 03h,03h,03h,03h,03h 
                 db 03h,03h,03h,03h,03h
                 db 03h,03h,03h,03h,03h
                 db 03h,03h,03h,03h,03h
                 db 03h,03h,03h,03h,03h
                 db 03h,03h,03h,03h,03h 
                 db 03h,03h,03h,03h,03h
                 db 03h,03h,03h,03h,03h
                 db 03h,03h,03h,03h,03h


    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;



;user level 2 paddel
UserLevel2       db 03h,03h,03h,03h,03h
                 db 03h,03h,03h,03h,03h
                 db 03h,03h,03h,03h,03h 
                 db 03h,03h,03h,03h,03h
                 db 03h,03h,03h,03h,03h
                 db 03h,03h,03h,03h,03h
                 db 03h,03h,03h,03h,03h
                 db 07h,07h,07h,07h,07h 
                 db 07h,07h,07h,07h,07h   
                 db 07h,07h,07h,07h,07h   
                 db 07h,07h,07h,07h,07h
                 db 07h,07h,07h,07h,07h
                 db 07h,07h,07h,07h,07h
                 db 07h,07h,07h,07h,07h
                 db 07h,07h,07h,07h,07h
                 db 07h,07h,07h,07h,07h
                 db 07h,07h,07h,07h,07h
                 db 03h,03h,03h,03h,03h
                 db 03h,03h,03h,03h,03h
                 db 03h,03h,03h,03h,03h
                 db 03h,03h,03h,03h,03h
                 db 03h,03h,03h,03h,03h
                 db 03h,03h,03h,03h,03h
                 db 03h,03h,03h,03h,03h
                 db 03h,03h,03h,03h,03h
                 db 03h,03h,03h,03h,03h
                 db 03h,03h,03h,03h,03h
























    User_Center dw 8    ;to specify the start pos of the paddle
    User1_X dw 0ah      
    User1_Y dw 42       ;origin 0ah
    User_Size dw 5h  
    User_Height dw 27
    User2_X dw 130h
    User2_Y dw 42      ;origin 0ah
    UserVelocity dw 05h
    User2_Score dw 00h
    User1_Score dw 00h
    charsize DW 20
    pongSize DW 30 
    Level DW 0
    MyScore dw 00H
    GuestScore dw 00h



    ;::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
    GameIsOver dw 00h ;act as a boolean in case the score of any user became 3 it will hang the game as game over
    GameOver db 'Game Over','$'
    User1_Won db 'User1 Won','$'
    User2_Won db 'User2 Won','$'
    WelcomeGame db 'Welcome To Pong Game','$'
    StartGame db 'Press P to Start Game',10,13,'Press H to Know How To Play','$'
    ChooseLevel db 'press 1 for Level 1 or 2 for Level 2',10,13,'$'
    LeftInstructions db 'Left Paddle Controllers :',10,13,'W = move up',10,13,'S = move down','$'
    RightInstructions db 'Right Paddle Controllers :',10,13,'Up-Arrow = move up',10,13,'Down-Arrow = move down','$'
    EscapeInstructions db 'Press P To Start Game','$'
    Restart db 'Press M To Go To Main menu','$'
    User1Name db 'User1 : ','$'
    User2Name db 'User2 : ','$'


    Score1User1 db 'Score :', '$'
    Score2User2 db 'Score :', '$'


    WonMsg db "You Won!$"
    LostMsg db "You Lost!$"
    ExitfromGame db 'Press F2 to leave game & F1 to chat$'
    ExitfromGame2 db 'Press ESC to return to main menu$'

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

.STACK 64
.CODE
MAIN PROC FAR
	  MOV AX,@data
	  MOV DS,AX 

	  call InitSerialPort ; function to initialize serial port connection
	  Call GetUserName 
	  Call WaitingScreen
	  Call ExchangeNames
	  Call MainScreen ; prints main screen
Main endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;
EndApp proc  ;called when either of the users press ESC to end program
 ClearScreen
      MoveCursor 15,5
      PrintStr PartnerName+2
      PrintStr ThanksMsg
	  MOV AX,4C00h ; exit program
	  INT 21h
EndApp endp      
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
WaitingScreen Proc  ;waiting screen while users exchange names
	ClearScreen
	MoveCursor 25,5
	PrintStr WaitMsg
	ret
WaitingScreen endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;
SendChar Proc     ;function to send the character stored in ChracterSent
	CheckBuffer: 
		mov dx,3fdh
		in al,dx
		test al,00100000b
		Jz CheckBuffer 
		mov al,CharacterSent
		mov dx,3f8h
		out dx,al
	ret 
SendChar endp 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
ReceiveChar Proc  ;function to recieve on char and place it in CharacterReceived
	MOV DX,3FDh
	IN AL,DX
	TEST AL,1
	JZ NothingSent
	MOV DX,3F8h
	IN AL,DX
	MOV CharacterReceived,AL
	RET 
	NothingSent: 
		MOV CharacterReceived , 0FFH  ;dummy flag in case nothing is recieved
	RET
ReceiveChar endp 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
MainScreen PROC

 	 MOV AX,0C00h
	 INT 21h 
	 CALL PrintMainScreen
	 Waiting: 
     CALL GetInput ;gets the scan code of the key pressed whether it's F1,F2 or ESC

	 mov AL , AH 
	 CMP AL , 59 
	 JZ F1pressed 

	 CMP AL , 60
	 JZ F2pressed

	 CMP AL , 01h
	 JZ ESCpressed 

	 Call ReceiveChar 
	 CMP CharacterReceived , 0FFH ;means nothing was sent
	 JZ Waiting

	 MOV AL , CharacterReceived
	 CMP AL , 59
	 JZ F1Received 

	 CMP AL , 60
	 JZ F2Received

     CMP AL , 01h
	 JZ ESCReceived

	 JMP Waiting

	F1Received: 
			Call ReceiveChatInvitaion 
			JMP Waiting 

	F2Received:
	        Call ReceiveGameInvitaion 
			jmp Waiting

	ESCReceived:
    Call EndApp

	F1pressed: 
		 CALL SendChatInvitation
		 JMP Waiting

	F2pressed: 
	Call SendGameInvitation
		JMP Waiting 

	ESCpressed: 
    Mov CharacterSent,01h
    Call SendChar
    Call EndApp

	RET

MainScreen ENDP
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

ExchangeNames proc ;exchange names with the other user 
	MOV BX, 1    
	Send:
    	MOV CL, UserName[BX]
		MOV CharacterSent, CL
    	Call SendChar
    Receive:
    	Call ReceiveChar
		CMP CharacterReceived,0ffh
		jz Receive
    	MOV  PartnerName[BX], Al
    	INC BX
    	CMP BX, 16
    	JLE Send
    RET
ExchangeNames endp 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

SendChatInvitation proc 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    mov chatended,0
    mov UserX,1
    mov UserY,1 ;;;;;;;;;;;; Reset Chat Vars ;;;;;;;;;;;;;;;;;;;
    mov PartnerX,1
    mov PartnerY,13
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;   
	MOV CharacterSent , 59 ;sends scan code of f1 to the other side
	Call SendChar
	PrintNotification ChatInvitationSentMsg,PartnerName+2 ;;;;;;;;; print notification
	WaitForReply9:
    ;;;;;;;;;;;;wait until the other user presses y or n
    CALL ReceiveChar
    CMP CharacterReceived , 0FFH 
    JZ WaitForReply9
    Cmp CharacterReceived , 'y'
    JZ Accept9
    cmp CharacterReceived,'n'
    JZ Next
    JmP WaitForReply9
    Accept9: 
    CALL Chat  ;call chat procedure  in case request is accepted
    cmp chatended,1
    JE Next
    Next:
    Call MainScreen
 	RET 
SendChatInvitation endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

ReceiveChatInvitaion proc
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	Mov chatended,0
    mov UserX,1
    mov UserY,1       ;;;;;;;;;; Reset Chat Vars ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    mov PartnerX,1
    mov PartnerY,13
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;   
    PrintNotification ChatInvitationReceivedMsg,PartnerName+2
	WaitAnswer:  ;;;;;; wait for an answer ;;;;;;;;;;;;;;;;
    GetKeyPress
    cmp al, 'y'
    Jz AcceptChat
    cmp al,'n'
    je refusechat
    jmp WaitAnswer
    AcceptChat:
    mov CharacterSent,al
    Call SendChar
	Call Chat ;;;;;;;;;;;;;;call chat proc in case invitation accepted;;;;;;;;;;;;;;;;;;
	cmp chatended,1
    JE Next1
    refusechat:
    mov CharacterSent,al
    Call SendChar
    Next1:
    Call MainScreen
	Ret 
ReceiveChatInvitaion endp 

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
SendGameInvitation proc 
	MOV CharacterSent ,  60 ;sends scan code of f2 to the other side
	Call SendChar
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	Mov gameended,0
	mov ax,0
    mov User1_Score,ax      ;reseting game variables
    mov User2_Score,ax
    mov User1_X,0ah
    mov User1_Y,42
    mov User2_X,130h
    mov User2_Y,42
    mov SpacePermission,0
    mov initiated,0
    mov GameUserX , 01h
    mov GameUserY , 13h
    mov GamePartnerX , 16h 
    mov GamePartnerY , 13h
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	PrintNotification GameInvitationSentMsg,PartnerName+2
	WaitForReply9Game:
    CALL ReceiveChar
    CMP CharacterReceived , 0FFH 
    JZ WaitForReply9Game
    Cmp CharacterReceived , 'y'
    JZ AcceptGame9
    cmp CharacterReceived,'n'
    je Next4
    JmP WaitForReply9Game
    
    AcceptGame9: 
    Call Reset_Ball_Left ;;;;;; resets ball in front of left player
    mov SpacePermission,1 ;;;;; moves serve turn to the current user since he initiated the game
    mov initiated,1   ;;;;; set initiated flag to user for later checks
    CALL Game        ;;;;;;;;;; call game function
    cmp GameEnded,1
    JE Next4
    Next4:
    Call MainScreen
	Ret  
SendGameInvitation endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

ReceiveGameInvitaion proc
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    mov gameended,0
    mov ax,0
    mov User1_Score,ax      ;reseting game variables
    mov User2_Score,ax
    mov User1_X,0ah
    mov User1_Y,42
    mov User2_X,130h
    mov User2_Y,42
    mov SpacePermission,0
    mov initiated,0
    mov  GameUserX , 01h
    mov GameUserY , 13h
    mov GamePartnerX , 16h 
    mov GamePartnerY , 13h
   ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    PrintNotification GameInvitationReceivedMsg,PartnerName+2
	WaitAnswerGame:
    GetKeyPress
    cmp al, 'y'
    Jz AcceptGame
    cmp al,'n'
    je refusegame
    jmp WaitAnswerGame
    AcceptGame:
    mov CharacterSent,al
    Call SendChar
    Call Reset_Ball_Left ;;;;;;;;;;;;;;;;;resets ball to the left position
    mov SpacePermission,2 ;;;;;;;;;;;;; set serve turn to the other user who initiated the game
    mov initiated,0  ;;;;;;;;;;;;;;;;;;unset initiated flag
	Call Game        ;;;;;;;;;;;;;;;;; call game proc
	cmp gameended,1
    JE Next8
    refusegame:
    mov CharacterSent,al
    Call SendChar
    Next8:
    Call MainScreen
	Ret 
ReceiveGameInvitaion endp 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

GetUserName proc  ;;;;;;;;;;;;;;;get user name
	TakeName:
		ClearScreen
		MoveCursor 25,5
		PrintStr EnterName
		MoveCursor 25,9
		PrintStr PressEnter
		MoveCursor 25,7
		mov ah,0AH
		mov dx, offset UserName
		int 21h 
		jmp CheckName

	CheckName:    ;;;;;;;;;;;;;;check if first char is a letter
		mov al, UserName+2                   
		cmp al, 41h               
		jb WrongName               
		cmp al, 5Ah               
		jbe ValidName        
		cmp al, 61h    
		jb WrongName               
		cmp al, 7Ah           
		ja WrongName              
		jmp ValidName

	WrongName:             ;;;;;print error message if not
		MoveCursor 25,11
		PrintStr ErrorMsg
		MOV     CX, 0FH
		MOV     DX, 4240H
		MOV     AH, 86H
		INT     15H
		jmp TakeName

	ValidName:         ;;;;;;;;;;;;add an extra $ to the end of the name if valid
		mov bx,00
		mov bl,UserName[1]
		mov UserName[bx+2],'$' 
	RET
GetUserName endp 

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
GetInput PROC ;returns scan code of F1,F2,ESC	
	mov ah , 1
	int 16h 
	jz Empty
	mov ah,0
	int 16h
	jmp Exit
	Empty:
		mov ah , 0
	Exit:
	RET
GetInput ENDP


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

PrintMainScreen proc  ;;;;;;;;;;;;prints options in the main screen

    ClearScreen
    MoveCursor 25,5
    PrintStr ChatMsg
    MoveCursor 25,7
    PrintStr GameMsg
    MoveCursor 25,9
    PrintStr ExitMsg
    MoveCursor 0,22
    MOV DL , '-' 
	MOV CX , 80 
	MOV AH , 2
	Line: 
		INT 21H 
	LOOP Line
	RET 
PrintMainScreen endp  
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

InitSerialPort proc
    mov dx,3FBh            ;Address of line control register
    mov al,10000000b       ;Data to be outputted on LCR =1000 0000 [To make DLAB=1]
    Out dx,al              ;OUT DX,AL   Put Data on AL on the port of address DX
    mov dx,3F8h            ;Divisor Latch Low [DLAB=1]
    mov al,0Ch              
    Out dx,al
    mov dx,3F9h            ;Divisor Latch High [DLAB=0]
    mov al,0
    Out dx,al
    mov dx,3FBh              ;Return to LCR
    mov al,00011011b         ;Data =8 bit - 1 stop bit - even parity
    Out dx,al
    ret
InitSerialPort endp
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 

DrawChatWindow proc      ;;;;;;;;;;;;;;;;draws chat window
    ClearScreen
    MoveCursor 1,0
    PrintStr UserName+2
    MoveCursor 0,11
    MOV DL , '_' 
	MOV CX , 80 
	MOV AH , 2
	Line3: 
		INT 21H 
	LOOP Line3
    MoveCursor 1,12
    PrintStr PartnerName+2
    MoveCursor 0,23
    MOV DL , '_' 
	MOV CX , 80 
	MOV AH , 2
	Line1: 
		INT 21H 
	LOOP Line1
    MoveCursor 1,24
    PrintStr EndChatMsg
    ret
DrawChatWindow endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

SenderCheck PROC
    CharCheck CharacterSent, UserX, UserY, 1 , 10     ;;;;;;;;;check character for User limits
    RET
SenderCheck ENDP

ReceiverCheck PROC
    CharCheck CharacterReceived, PartnerX, PartnerY, 13,22    ;;;;;;;;;;;;check character for partner limits
    RET
ReceiverCheck ENDP

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Chat Proc
    Call DrawChatWindow
    ChatLoop:
        MoveCursor UserX,UserY
    ChatSend:
        GetKeyPress
        JZ ChatReceive             
	    Mov CharacterSent,AL
        Call SendChar
        CALL SenderCheck
    ChatReceive:
        Call ReceiveChar
        JZ ChatCheck                 
        CALL ReceiverCheck    
        ChatCheck:
        CMP chatended, 0
        JZ ChatLoop
    RET
Chat endp	

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;GAME;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Draw_Black_Backgorund PROC near
    mov ah,00h
    mov al,13h
    int 10h
    mov ah,0bh
    mov bh,00h 
    mov bl,00h;black color
    int 10h;clear screen with black color
    RET
    Draw_Black_Backgorund ENDP
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
User_Collision_With_Ball PROC NEAR

        Check_User2_Collision: 
        ;if ballX+ballSize > PaddleX && BallX< PaddleX+width && 
        ;BallY+ballSize > PaddleY && BallY < PaddleY+hieght collision occurs 

        ;Checking that the ball X-pos is in the limit of paddle width
        mov ax,ballX 
        add ax,ballSize 
        cmp ax,User2_X 
        jng Check_User1_Collision       ;if there is no collision with user2 

        mov ax,User2_X 
        add ax,User_Size
        cmp ballX,ax 
        jnl Check_User1_Collision       ;if there is no collision with user2 

        ;Checking if the ball Y-position is in the limit of the paddle height
        mov ax,ballY 
        add ax,ballSize 
        cmp ax,User2_Y 
        jng Check_User1_Collision       ;if there is no collision with user2 

        mov ax,User2_Y
        add ax,User_Height
        cmp ballY,ax 
        jnl Check_User1_Collision       ;if there is no collision with user2 

        neg ballVelocityX               ;collision occurs so make this action 

        CALL CheckCollisionAngle2       ;to select the suitable angle of reflection
        RET                             ;Exiting after applying the collision action       
        
        ;Checking that the ball X-pos is in the limit of paddle width
        Check_User1_Collision: 
        mov ax,ballX 
        add ax,ballSize 
        cmp ax,User1_X 
        jng QUIT 
        
        mov ax,User1_X 
        add ax,User_Size
        cmp ballX,ax 
        jnl QUIT 
        ;Checking if the ball Y-position is in the limit of the paddle height
        mov ax,ballY 
        add ax,ballSize 
        cmp ax,User1_Y 
        jng QUIT 
        
        mov ax,User1_Y 
        add ax,User_Height 
        cmp ballY,ax
        jnl QUIT 
        
        neg ballVelocityX               ;collision occurs so make this action 
        Call CheckCollisionAngle1       ;toselect the suitableangle of reflection
        QUIT:
        RET                             
    User_Collision_With_Ball ENDP
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Draw_Ball proc 
    mov cx,ballX                      ;set X
    mov dx,ballY                      ;set Y
    LEA SI ,ball
    mov xintiat , 10 
    mov yintiat , 10 
    call draw
    ret
Draw_Ball endp
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Draw_pong proc
    mov cx , 100
    mov dx , 60
    LEA SI ,Pcharachter
    mov xintiat , 20 
    mov yintiat , 20
    call draw 
    mov cx , 130
    mov dx , 60
    LEA SI ,Ochar
    mov xintiat , 20 
    mov yintiat , 20    
    call draw 
    mov cx , 160
    mov dx , 60
    LEA SI ,Nchar
    mov xintiat , 20 
    mov yintiat , 20    
    call draw 
    mov cx , 190
    mov dx , 60
    LEA SI ,Gchar
    mov xintiat , 20 
    mov yintiat , 20  
    call draw 
    mov xintiat ,30
    mov yintiat ,30 
    mov cx , 90
    mov dx , 90
    LEA SI ,Ppong
    call draw 
    mov cx , 125
    mov dx , 90
    LEA SI ,Ppong
    call draw 
    mov cx , 157
    mov dx , 90
    LEA SI ,Ppong
    call draw 
    mov cx , 190
    mov dx , 90
    LEA SI ,Ppong
    call draw 
    ret 
Draw_pong endp 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
draw proc 

    push AX
    push BX 
    push CX 
    push DX     
    push SI 
    push DI 
    push BP 

    ; stoping point of size of object 
    mov BP , DX ; y load 
    add BP , yintiat  ; BP holding ending point of y axis true give me the Y end 
    mov BX , cx  ;BX holding ending point  of x axis true give me the X end
    add Bx , xintiat

    Mov DI , CX

    DRAW_COLUMN : 
    Draw_ROW :
        LODSB 
        mov AH , 0Ch 
        cmp AL , 0 
        JE Skip_Draw 
        INT 10h  
        Skip_Draw: 
      inc cx 
      cmp cx , Bx 
      JNE DRAW_ROW 

    mov cx , DI 
    INC DX 
    CMP DX , BP 
    JNE DRAW_COLUMN 

    pop BP
    pop DI
    Pop SI 
    Pop DX 
    pop CX
    pop BX 
    pop AX  
    ret 
draw endp 

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

DrawLineAndUserNames PROC NEAR
        mov dx,78h
        mov cx,0
        LOOP3:
            mov ah,0ch
            mov al,04h  ;select color
            mov bh,00h 
            int 10h 
            inc cx
            cmp cx,320  ;if reached max columns num stop drawing
            JE ESCAPELINE
            JMP LOOP3   ;else continue looping
        ESCAPELINE:
        ;---------------To draw tha dash which seperate the score part equally-----------;
        mov dx,78h
        mov cx,160
        VERTICALLINE:
            mov ah,0ch
            mov al,04h  ;select color
            mov bh,00h 
            int 10h 
            inc dx
            cmp dx,8dh
            JE ESCAPEVERTICAL ;if reached max rows num stop drawing
            JMP VERTICALLINE    ;else continue looping
        ESCAPEVERTICAL:
        ;-------------------To print the users name------------------;
        mov dh,12h   ;row number to display user1 name at ,don't change it
        mov dl,00h  ;column number to display user1 name at, feel free to ahjust it
        mov bh,0   ;page no
        mov ah,2
        int 10h
        mov ah,9
        mov dx,offset UserName+2 ;printing user1 name
        int 21h
        mov dh,12h  ;row number to display user2 name at ,don't chnage it
        mov dl,15h  ;column number to display user2 name at ,feel free to ahjust it
        mov bh,0   ;page no
        mov ah,2
        int 10h
        mov ah,9
        mov dx,offset PartnerName+2 ;printing user2 name
        int 21h
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;show Exist Statment 
        mov dh,17h   
        mov dl,00h  
        mov bh,0   
        mov ah,2
        int 10h
        mov ah,9
        mov dx,offset ExitfromGame
        int 21h
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        RET
    DrawLineAndUserNames ENDP
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
showGameOver PROC NEAR
        Call Draw_Black_Backgorund
        mov dh,05h  ;row number
        mov dl,0fh  ;column number
        mov bh,0   ;page no
        mov ah,2
        int 10h
        mov ah,9
        mov dx,offset GameOver      ;showing game over msg
        int 21h
        
        ;;;;;;;;;;;;;;;;;Check whether you initiated the game or not to determine which score is yours (User1Score for the left paddle)
        mov ax,User2_Score
        cmp initiated,1
        jne CheckOther
        cmp User1_Score,ax
        jb loser
        mov dh,07h  ;row number
        mov dl,0fh  ;column number
        mov bh,0   ;page no
        mov ah,2
        int 10h
        mov ah,9
        mov dx,offset WonMsg      ;showing game over msg
        int 21h
        jmp endofgame
        loser:
        mov dh,07h  ;row number
        mov dl,0fh  ;column number
        mov bh,0   ;page no
        mov ah,2
        int 10h
        mov ah,9
        mov dx,offset LostMsg      ;showing game over msg
        int 21h
        jmp endofgame

        ;;;;;;;;;;;;;;;;;;;;if you didnt initiate your score is User2Score
        CheckOther:
        cmp User1_Score,ax
        jb winner
        mov dh,07h  ;row number
        mov dl,0fh  ;column number
        mov bh,0   ;page no
        mov ah,2
        int 10h
        mov ah,9
        mov dx,offset LostMsg      ;showing game over msg
        int 21h
        jmp endofgame
        winner:
        mov dh,07h  ;row number
        mov dl,0fh  ;column number
        mov bh,0   ;page no
        mov ah,2
        int 10h
        mov ah,9
        mov dx,offset WonMsg      ;showing game over msg
        int 21h
        jmp endofgame

        endofgame:           ;;;;;;;;;;;;;;;;;;5seconds delay before returning to main menu
        MOV CX, 4cH
        MOV DX, 4B40H
        MOV AH, 86H
        INT 15H
        Call MainScreen
        RET
ShowGameOver ENDP
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;   
ShowScore PROC NEAR

        mov dh,10h  ;row number
        mov dl,15h  ;column number
        mov bh,0   ;page no
        mov ah,2
        int 10h
        mov ah ,9h 
        mov dx , offset PartnerName+2
        int 21h 

        mov dh,10h  ;row number
        mov dl,21h  ;column number
        mov bh,0   ;page no
        mov ah,2
        int 10h


        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;same checks as previous function to determine which score is yours
        cmp initiated,1
        jne Movescore2
        mov ax,User2_Score      ;moving the score of user2 into ax to display it
        add ax,30h              ;turning into ascii to be displayed correctly
        mov dl,al
        mov ah,2
        int 21h  
        jmp secondscore            ;interput print char in dl=user2 score in asci
        Movescore2:
        mov ax,User1_Score      ;moving the score of user2 into ax to display it
        add ax,30h              ;turning into ascii to be displayed correctly
        mov dl,al
        mov ah,2
        int 21h              ;interput print char in dl=user2 score in asci
        ;to adjust the position of writing the score of user 1 on right
        secondscore:
        mov dh,10h  ;row number
        mov dl,0h  ;column number
        mov bh,0   ;page no
        mov ah,2
        int 10h
        mov ah ,9h 
        mov dx , offset UserName+2
        int 21h
        mov dh,10h  ;row number
        mov dl,10h  ;column number
        mov bh,0   ;page no
        mov ah,2
        int 10h
        cmp initiated,1
        jne Movescore1
        mov ax,User1_Score      ;moving the score of user2 into ax to display it
        add ax,30h              ;turning into ascii to be displayed correctly
        mov dl,al
        mov ah,2
        int 21h  
        jmp otherchecks            ;interput print char in dl=user2 score in asci
        Movescore1:
        mov ax,User2_Score      ;moving the score of user2 into ax to display it
        add ax,30h              ;turning into ascii to be displayed correctly
        mov dl,al
        mov ah,2
        int 21h    
         ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;check if either of the users won the game;;;;;;;;;;;;;;;;;
        otherchecks:               ;interput print char in dl=user1 score in ascii
        mov ax,User2_Score ;checking if game is over after printing the result
        cmp ax,Max_Score
        JE GAME_OVER
        mov ax,User1_Score  ;checking if game is over brdo
        cmp ax,Max_Score
        JE GAME_OVER
        RET
        GAME_OVER: 
        Call ShowGameOver
        ret
ShowScore ENDP
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

CheckCollisionAngle1 PROC NEAR
    ;user height is 1fh so center of paddle is from 0fh,10h
    ;first Check if ballY is at the center of paddle or not
        mov ax,ballY        
        mov bx,User1_Y
        mov cx,User1_Y
        add bx,User_Center  ;to get the start pos of center paddle
        add cx,User_Center
        add cx,User_Center
        add cx,2            ;to get the last pos of the center paddle
        cmp ax,bx
        jbe CollisionUp21   ;if it is below the start pos of the center so the collision happens in the upper part of paddle
        cmp ax,cx
        jge CollisionDown21 ;if the ball is greater than the end pos of center so the collision happens in the lower part of paddle

        JustNegative1:          ;Ball is hitten by the center of paddle so no change in angle magnitude only change in the direction
            RET

        CollisionUp21:
            mov ax,ballVelocityY
            cmp ax,0                ;check if ball angle is zero to convert it to 45
            JNE Step1Up
            mov ballVelocityY,5
            mov ballVelocityX,5     ;making an angle 45
            neg ballVelocityY
            RET
            Step1Up:
                cmp ax,5
                JNE Step13Up
                mov ballVelocityY,3     ;from 45 deg to 30 deg up
                neg ballVelocityY       ;to move up
                RET
            Step13Up:
                cmp ax,3
                mov ballVelocityY,0     ;from 30 deg to zero deg
                RET
        CollisionDown21:
            mov ax,ballVelocityY
            cmp ax,0                    ;checking if ball angleis zero will change it to 45 down direction
            JNE Step1Down
            mov ballVelocityY,5
            mov ballVelocityX,5
            RET
            Step1Down:
                cmp ax,5                ;checking if ball angle is 45 will change it to 30 down direction
                JNE STEP13Down
                mov ballVelocityY,3
                RET
            STEP13Down:
                cmp ax,3
                mov ballVelocityY,0     ;from 30 deg to zero deg
                RET

CheckCollisionAngle1 ENDP
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

CheckCollisionAngle2 PROC NEAR
        ;user height is 24h so center of paddle is from 11,23
        ;first Check if ballY is at the center of paddle or not
        mov ax,ballY        
        mov bx,User2_Y
        mov cx,User2_Y
        add bx,User_Center  ;to get the start pos of center paddle
        add cx,User_Center
        add cx,User_Center
        add cx,2            ;to get the last pos of the center paddle
        cmp ax,bx
        jbe CollisionUp2    ;if it is below the start pos of the center so the collision happens in the upper part of paddle
        cmp ax,cx
        jge CollisionDown2   ;if the ball is greater than the end pos of center so the collision happens in the lower part of paddle

        JustNegative2:      ;Collision with ball is at the center so no angle magnitude change on the ball direction is changed
            RET

        CollisionUp2:
            mov ax,ballVelocityY
            cmp ax,0                ;if ballangle is 0 will change to 45 upwards
            JNE Step2Up
            mov ballVelocityY,5
            mov ballVelocityX,5     ;making an angle 45
            neg ballVelocityX       ;to move to the left
            neg ballVelocityY       ;to move upwards
            RET
            Step2Up:
                cmp ax,5            ;if angle is 45 will change to 30 upwards
                JNE Step3Up
                mov ballVelocityY,3
                neg ballVelocityY   ;to move -30 degree up
                RET
            Step3Up:
                cmp ax,3
                mov ballVelocityY,0 ;from 30 deg to zero deg
                RET                 
        CollisionDown2:
            mov ax,ballVelocityY
            cmp ax,0                ;if angle is 0 will change to angle 45 downwards
            JNE Step2Down
            mov ballVelocityY,5
            mov ballVelocityX,5
            neg ballVelocityX       ;to move to the left
            RET
            Step2Down:
                cmp ax,5            ;if angle is 45 will change to angle 30 downwards
                JNE Step3Down
                mov ballVelocityY,3     ;from 45 deg to 30 deg down
                RET
            Step3Down:
                cmp ax,3
                mov ballVelocityY,0     ;from 30 deg to zero deg
                RET

CheckCollisionAngle2 ENDP
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Draw_User1 proc 
    mov cx,User1_X  ;set X
    mov dx,User1_Y ;set Y

    cmp User_Center, 8 
    JE  Userlev2Draw
    JMP UserLev1Draw

    UserLev1Draw:
    LEA SI ,User
    mov xintiat ,5     ;  User level 1 width 
    mov yintiat , 42   ;  User level 1 length 
    JMP _Draw


    Userlev2Draw:
    LEA SI ,UserLevel2
    mov xintiat ,5      ;User level 2 width
    mov yintiat , 27    ; User level 2 length 
    JMP _Draw

    _Draw:
    call draw  ; general draw function 

    ret
 Draw_User1 endp 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Draw_User2 proc 
    mov cx,User2_X ;set X
    mov dx,User2_Y ;set Y
    cmp User_Center, 8 
    JE  User2lev2Draw
    JMP User2Lev1Draw

    User2Lev1Draw:
    LEA SI ,User
    mov xintiat ,5
    mov yintiat , 42
    JMP _Draw2


    User2lev2Draw:
    LEA SI ,UserLevel2
    mov xintiat ,5
    mov yintiat , 27
    JMP _Draw2

    _Draw2:
    call draw 

    ret
 Draw_User2 endp 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Ball_Movement PROC NEAR
        mov ax,ballVelocityX;giving the ball x-axis pos according to it's x-axis velocity
        add ballX,ax

        mov ax,windowBounds
        cmp ballX,ax ;if it is smaller than 0
        JL Reset_Ball_Left

        mov SpacePermission,0
        mov ax,windowWidth
        sub ax,ballSize  ;subtracting the ballsize & bounds to avoid entering the ball into the side of screen
        sub ax,windowBounds
        cmp ballX,ax  ;if it is greater than window width
        JG Reset_Ball_Right


        mov ax,ballVelocityY;giving the ball y-axis pos according to it's y-axis velocity
        add ballY,ax
        
        mov ax,windowBounds
        cmp ballY,ax ;if it is smaller than 0
        JL Adjust_yAxis

        mov ax,windowHeight
        sub ax,ballSize  ;subtracting the ballsize & bounds to avoid entering the ball into the side of screen
        sub ax,windowBounds
        cmp ballY,ax  ;if it is greater than window height
        JG Adjust_yAxis

        RET

        Reset_Pos:
            Call Reset_Ball
            RET

        Adjust_xAxis:
            neg ballVelocityX ;reverting the velocity direction
            RET
        Adjust_yAxis:
            neg ballVelocityY ;reverting the velocity direction
            RET
Ball_Movement ENDP
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Reset_Ball_Left PROC NEAR
        neg ballVelocityX
        mov ax,User2_Score
        inc ax
        mov User2_Score,ax      ;increasing the score of user2
        mov ax,User1_X
        add ax,6
        mov ballX,ax            ;moving the pos of ball to the x of use who lose
        mov ax,User1_Y
        add ax,User_Center
        add ax,3
        mov ballY,ax            ;moving the initial pos-Y of ball to it again to start from center        ;moving the initial pos-Y of ball to it again to start from center
        cmp initiated,1      ;;;;;;;;;;;;;;;;fix serve turn based on who initiated the game
        jne notinitiated
        mov SpacePermission,1
        RET
        notinitiated:
        mov SpacePermission,2
        RET
Reset_Ball_Left ENDP
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Reset_Ball_Right PROC NEAR
        neg ballVelocityX
        mov ax,User1_Score
        inc ax
        mov User1_Score,ax      ;increasing the score of user1
        mov ax,User2_X
        sub ax,10
        mov ballX,ax            ;moving the initial pos-X of ball to it again
        mov ax,User2_Y
        add ax,User_Center
        add ax,3
        mov ballY,ax            ;moving the initial pos-Y of ball to it again to start from center            ;moving the initial pos-Y of ball to it again to start from center
        cmp initiated,1       ;;;;;;;;;;;;;;;;fix serve turn based on who initiated the game
        jne notinitiated1
        mov SpacePermission,2
        RET
        notinitiated1:
        mov SpacePermission,1
        RET
Reset_Ball_Right ENDP
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Reset_Ball PROC NEAR
        mov ax,ball_initX   
        mov ballX,ax            ;moving the initial x-pos to the ball
        mov ax,ball_initY
        mov ballY,ax            ;moving the initial y-pos to the ball
        
Reset_Ball ENDP
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

TempScreen PROC NEAR ;;;;;;;;;;;;;;;;;;;;;temporary screen to show current scores for 5 seconds
        Call Draw_Black_Backgorund
        mov dh,05h  ;row number
        mov dl,09h  ;column number
        mov bh,0   ;page no
        mov ah,2
        int 10h
        mov ah,9
        mov dx,offset UserName+2      ;showing game over msg
        int 21h

        mov dh,07h  ;row number
        mov dl,09h  ;column number
        mov bh,0   ;page no
        mov ah,2
        int 10h
        mov ah,9
        mov dx,offset PartnerName+2      ;showing game over msg
        int 21h


        cmp initiated,1
        jne switchscores
        mov dh,05h  ;row number
        mov dl,15h  ;column number
        mov bh,0   ;page no
        mov ah,2
        int 10h

        mov ax,User1_Score      ;moving the score of user2 into ax to display it
        add ax,30h              ;turning into ascii to be displayed correctly
        mov dl,al
        mov ah,2
        int 21h
       
        mov dh,07h  ;row number
        mov dl,15h  ;column number
        mov bh,0   ;page no
        mov ah,2
        int 10h
        mov ax,User2_Score      ;moving the score of user2 into ax to display it
        add ax,30h              ;turning into ascii to be displayed correctly
        mov dl,al
        mov ah,2
        int 21h
        jmp todelay
        
        switchscores:
        mov dh,05h  ;row number
        mov dl,15h  ;column number
        mov bh,0   ;page no
        mov ah,2
        int 10h

        mov ax,User2_Score      ;moving the score of user2 into ax to display it
        add ax,30h              ;turning into ascii to be displayed correctly
        mov dl,al
        mov ah,2
        int 21h
       
        mov dh,07h  ;row number
        mov dl,15h  ;column number
        mov bh,0   ;page no
        mov ah,2
        int 10h
        mov ax,User1_Score      ;moving the score of user2 into ax to display it
        add ax,30h              ;turning into ascii to be displayed correctly
        mov dl,al
        mov ah,2
        int 21h

        todelay:
        MOV CX, 4cH
        MOV DX, 4B40H
        MOV AH, 86H
        INT 15H
        call MainScreen
        ret
TempScreen endp

 ;;;;;;;;;;;;;;;;;;;;;;;;;;;moves left paddle;;;;;;;;;;;;;;;;;;;;;       
MoveUser1 PROC NEAR

            cmp User1char,48h ;scancode of upArrow is 48h 
            JE Move_User1_Up
            cmp User1char,50h ;scancode of downArrow is 50h
            JE Move_User1_Down


            cmp User1char,59 ;;;; call in game chat in case F1 is pressed
            JE enterchat

            cmp User1char,60 ; call temp screen in case F2 is pressed
            JE totemp

            JMP Exit1
        ;Movements calculations
            Move_User1_Up:
            mov ax,UserVelocity
            sub User1_Y,ax
            mov ax,windowBounds;checking if user is going out of window
            cmp User1_Y,ax
            JL Adjust_User1_High
            JMP Exit1
                Adjust_User1_High:
                    mov User1_Y,ax
                    JMP Exit1
            Move_User1_Down:
            mov ax,UserVelocity
            add User1_Y,ax
            mov ax,windowHeight ;checking that user is still in the window 
            sub ax,windowBounds
            sub ax,User_Height
            cmp User1_Y,ax ;if the user1 y-axis is greater that mean that user1 pos exceeds the limit
            JG Adjust_User1_Below
            JMP Exit1
                Adjust_User1_Below: ;readjusting the user pos to stay inside the window boundaries
                    mov User1_Y,ax
                    JMP Exit1
            Exit1:
            RET
            enterchat:
            mov switchtochat,1
            ret
            totemp:
            call TempScreen
            ret
MoveUser1 ENDP
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;moves right paddle;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
MoveUser2 PROC NEAR

            cmp User2char,48h ;scancode of upArrow is 48h 
            JE Move_User2_Up
            cmp User2char,50h ;scancode of downArrow is 50h
            JE Move_User2_Down

          
            cmp User2char,59
            je enterchat1

            cmp User2char,60
            je totemp1

            JMP Exit2
        ;Movements calculations
            Move_User2_Up:
            mov ax,UserVelocity
            sub User2_Y,ax
            mov ax,windowBounds
            cmp User2_Y,ax ;checking if the user goes above the window limit
            JL Adjust_User2_X
            JMP Exit1
                Adjust_User2_X:
                    mov User2_Y,ax  ;re-adjusting the y axis of the user to not get above the window limit
                    JMP Exit2
            Move_User2_Down:
            mov ax,UserVelocity
            add User2_Y,ax
            mov ax,windowHeight
            sub ax,windowBounds
            sub ax,User_Height
            cmp User2_Y,ax ;if user y-axis is greater than ax that means it exceeds the window's limit
            JG Adjust_User2_Y
            JMP Exit2
                Adjust_User2_Y:
                    mov User2_Y,ax
                    JMP Exit2
                       
            Exit2:
            RET
            enterchat1:
            mov switchtochat,1
            ret
            totemp1:
            call TempScreen
            ret
MoveUser2 ENDP
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;loop to follow in case you initiated the game to be placed on the left;;;;;;;;;;;;;;;;;
User1loop proc
        GetKeyPress
        JZ GameReceive           
      	Mov CharacterSent,AH
        Call SendChar
        Mov User1char,AH              
        CALL MoveUser1

        GameReceive:
        Call ReceiveChar
        JZ GameCheck   
        Mov User2char,Al                             
        CALL MoveUser2
		GameCheck:
        ret
User1loop endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;loop to follow in case you didn't initiate the game to be placed on the right;;;;;;;;;;;;;;;
User2loop proc
     GetKeyPress
        JZ GameReceive1           
      	Mov CharacterSent,AH
        Call SendChar
        Mov User2char,AH              
        CALL MoveUser2
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        GameReceive1:
        Call ReceiveChar
        JZ GameCheck1   
        Mov User1char,Al                             
        CALL MoveUser1
		GameCheck1:
        ret
User2loop endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;lets the user who initiated the game choose levels;;;;;;;;;;;;;;;;;;
Choose PROC NEAR
            call Draw_Black_Backgorund
            mov ax,0
            mov User1_Score,ax      ;reseting the user scores to zero
            mov User2_Score,ax
            mov dl,0ah  ;column number
            mov bh,0   ;page no
            mov ah,2
            int 10h
            mov dh,15h  ;row number
            mov dl,00h  ;column number
            mov bh,0   ;page no
            mov ah,2
            int 10h
            mov ah,9
            mov dx , offset ChooseLevel ; choosee the level of diffuclty of game 
            int 21h 
            mov dh,16h  ;row number
            mov dl,00h  ;column number
            mov bh,0   ;page no
            mov ah,2
            int 10h
            mov ah,9
            mov dx , offset ExitfromGame2 ; choosee the level of diffuclty of game 
            int 21h 
            call Draw_pong

            CHECKDIFFICULTY:
            mov ah , 0   ; wait& checking for selected difficulty 
            int 16h 
            cmp al,49 
            JE Setlevel1
         
            cmp al ,50
            JE Setlevel2 

            cmp al ,1bh
            JE BackToMain1

            JMP CHECKDIFFICULTY

            Setlevel1:
            Mov CharacterSent,al
            Call SendChar
            mov ballVelocityX , 05h 
            mov ballVelocityY , 03h 
            mov Max_Score , 3
            mov User_Height,42
            mov User_Center,13      ;center starts from 14-27
            mov  UserVelocity ,04h 
            JMP Begininterface
     
            Setlevel2:
            Mov CharacterSent,al
            Call SendChar
            mov ballVelocityX ,05h 
            mov ballVelocityY ,03h 
            mov Max_Score ,5 
            mov User_Height,27
            mov User_Center,8       ;center starts from 9-17
            mov UserVelocity ,06h
            
            JMP Begininterface

            Begininterface:
            MOV CX, 1EH
            MOV DX, 8480H
            MOV AH, 86H
            INT 15H
            RET
            BackToMain1:
            Mov CharacterSent,al
            Call SendChar
            call MainScreen
            ret
Choose ENDP
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;waits for the other user to choose the level;;;;;;;;;;;;;;;;;;;;;
WaitForChoice proc
            call Draw_Black_Backgorund
            mov ax,0
            mov User1_Score,ax      ;reseting the user scores to zero
            mov User2_Score,ax
            mov dl,0ah  ;column number
            mov bh,0   ;page no
            mov ah,2
            int 10h
            mov dh,15h  ;row number
            mov dl,00h  ;column number
            mov bh,0   ;page no
            mov ah,2
            int 10h
            mov ah,9
            mov dx , offset WaitMsg ; choosee the level of diffuclty of game 
            int 21h 
            call Draw_pong
            mov dh,16h  ;row number
            mov dl,00h  ;column number
            mov bh,0   ;page no
            mov ah,2
            int 10h
            waitingforlevel:
            Call ReceiveChar 
	        CMP CharacterReceived , 0FFH ;means nothing was sent
	        JZ waitingforlevel
            MOV AL , CharacterReceived
	        cmp al,49 
            JE chosenlevel1
            cmp al ,50
            JE chosenlevel2
            cmp al ,1bh
            JE BackToMain
	        JMP waitingforlevel
            chosenlevel1: 
            mov ballVelocityX , 05h 
            mov ballVelocityY , 03h 
            mov Max_Score , 3 
            mov User_Height,42
            mov User_Center,13      ;center starts from 14-27
            mov  UserVelocity ,04h 
            mov ah,9
            mov dx , offset Level1 ; choosee the level of diffuclty of game 
            int 21h 
            JMP Begininterface1
     
            chosenlevel2:
            mov ballVelocityX ,05h 
            mov ballVelocityY ,03h 
            mov Max_Score ,5
            mov User_Height,27
            mov User_Center,8       ;center starts from 9-17
            mov UserVelocity ,06h 
            mov ah,9
            mov dx , offset Level2 ; choosee the level of diffuclty of game 
            int 21h
            JMP Begininterface1

            Begininterface1: 
            MOV CX, 1EH
            MOV DX, 8480H
            MOV AH, 86H
            INT 15H
            ret
            BackToMain:
            call MainScreen
            ret 
WaitForChoice ENDP
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
draw_Chat proc Near  ;;;;;;;;;;;;;draw in game chat;;;;;;;;;;;;;;;;;
        mov dx , 8dh
        mov cx , 0 
        loopchat:
        mov ah,0ch 
        mov al,04h 
        mov bh , 00h 
        int 10h 
        inc cx  
        cmp cx ,320 
        JE myEscape 
        JNE loopchat


        myEscape:
        mov dx ,8dh
        mov cx,160

       Chatlinesplit:
        mov ah , 0ch 
        mov al ,04h 
        mov bh ,00h 
        int 10h 
        inc dx 
        cmp dx , 0b4h
        JE DRAWENDCHAT
        JNE Chatlinesplit


        DRAWENDCHAT:
        mov cx, 0 

        ENDChat:
        mov ah,0ch 
        mov al,04h 
        mov bh , 00h 
        int 10h 
        inc cx  
        cmp cx ,320 
        JNE ENDChat
        ret 
draw_Chat endp 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
InGameChat proc ;;;;;;;;;;;;;;;;;;;;;;;; in game chat loop;;;;;;;;;;;;;;;;;;;;
    ChatLoop1:
    MoveCursor UserX,UserY
    ChatSend1:
    GetKeyPress
    JZ ChatReceive1             
	Mov CharacterSent,AL
    Call SendChar
    CALL GameSenderCheck
    
    ;Get secondary user input
    ChatReceive1:
    Call ReceiveChar
    JZ ChatCheck1                 
    CALL GameReceiverCheck
    
    ChatCheck1:
    CMP switchtogame, 1
    je backtogame
    JMP ChatLoop1

    backtogame:
    ret

InGameChat endp  
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
GameSenderCheck PROC
    GameCharCheck CharacterSent, GameUserX, GameUserY, 1,13h, 13h , 15h ;;;;;;;;;;check user in game chat input;;;;;;;;;;;;;;;;;
    RET
GameSenderCheck ENDP

GameReceiverCheck PROC
    GameCharCheck CharacterReceived, GamePartnerX, GamePartnerY, 16h,28h,13h,15h ;;;;;;;;;;;;;;check partner in game chat input;;;;;;;;;;;;;
    RET
GameReceiverCheck ENDP
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;




;;;;;;;;;;;;;;;;;;;;;;;GAME MAIN CODE;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Game Proc
    cmp initiated,1
    JE YouBegin
    cmp initiated,0
    JE YouDont

    YouBegin:
    Call Choose;;;;;;;;;;;;;;;if you initiated choose the level
    JMP test5

    YouDont:
    Call WaitForChoice ;;;;;;;;;if you didnt wait fo the other user's choice
    JMP test5

    test5:
    Call Draw_Black_Backgorund ;;;;;;;;;;;;;;draw black background and set video mode
    Call draw_Chat ;;;;;;;;;;;;;;;;draw in game chat area
    SetTime:
        mov ah,2ch  ;setup time
        int 21h  
        cmp dl,Time
        JE SetTime
        mov Time,dl ;update the time 
        ClearBackground ;;;;;;;;;;scrolls up game area only as to not clear the in game chat
        CALL DrawLineAndUserNames
        Call ShowScore  ;printing the most updated score on the screen
        Call User_Collision_With_Ball ;checking for collision
        Call Draw_Ball;to draw the ball
        Call Draw_User1
        Call Draw_User2


        ;;;;;;;;;;;;;;;;;;;;;;check whose turn it is to serve;;;;;;;;;;;;;;;;;;;;;;;
        cmp SpacePermission,0
        je GameSend
  

        cmp SpacePermission,1
        jne PartnerCheck

        serve1:
        mov ah,0
        int 16h
        cmp al,32
        jne serve1
        Mov CharacterSent,Al
        Call SendChar
        jmp GameSend

        PartnerCheck:
        cmp SpacePermission,2
        jne GameSend
        serve2:
        Call ReceiveChar
        cmp CharacterReceived,32
        jne serve2
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

        GameSend: ;;;;;;;;;;;;;;;;;check which loop to follow based on who started the game
        Call Ball_Movement
        cmp initiated,0
        je Start2
        Call User1loop
        cmp switchtochat,1
        je gotochat
        JMP SetTime

        Start2:
        call User2loop
        cmp switchtochat,1
        je gotochat
        JMP SetTime

        gotochat: ;;;;;;;;;;;;;jumped to when either of the users presses F1 to switch to chat
        Call InGameChat
        Mov switchtochat,0
        Mov switchtogame,0
        JMP SetTime
        RET
 Game endp  


 
end main

