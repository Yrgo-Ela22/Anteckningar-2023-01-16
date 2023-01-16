;/********************************************************************************
;* exercise.asm: Lösningsförslag för dagens övningsuppgift. 
;*               Tre lysdioder ansluts till pin 8 - 10 (PORTB0 - PORTB2) och
;*               två tryckknappar ansluts till pin 12 - 13 (PORTB4 - PORTB5).
;*
;*               - I viloläget hålls lysdioderna släckta.
;*               - Om enbart tryckknapp 1 ansluten till pin 12 (PORTB4) trycks
;*                 ned blinkar lysdioderna framåt i en slinga var 100:e ms.
;                - Om enbart tryckknapp 2 ansluten till pin 13 (PORTB5) trycks
;*                 ned blinkar lysdioderna bakåt i en slinga var 100:e ms.
;*               - Om båda tryckknappar trycks ned hålls lysdioderna tända.
;*
;*               Notering: Under programmets gång sparas värden för att enkelt
;*                         kunna toggla respektive lysdiod i CPU-register:
;*
;*                          - R16 = (1 << LED1)
;*                          - R17 = (1 << LED2)
;*                          - R18 = (1 << LED3)
;*
;*                          Skriv inte över dessa värden efter initiering!
;********************************************************************************/

; Makrodefinitioner:
.EQU LED1 = PORTB0    ; Lysdiod 1 ansluten till pin 8 (PORTB0).
.EQU LED2 = PORTB1    ; Lysdiod 2 ansluten till pin 9 (PORTB1).
.EQU LED3 = PORTB2    ; Lysdiod 3 ansluten till pin 10 (PORTB2).
.EQU BUTTON1 = PORTB4 ; Tryckknapp 1 ansluten till pin 12 (PORTB4).
.EQU BUTTON2 = PORTB5 ; Tryckknapp 2 ansluten till pin 13 (PORTB5).

;/********************************************************************************
;* .CSEG: Programminnet - Här lagras programkoden.
;********************************************************************************/
.CSEG
.ORG 0x00    ; Programmets startadress.
   RJMP main ; Anropar subrutinen main för att starta programmet.

;/********************************************************************************
;* main: Initierar systemet vid start. Programmet exekverar sedan kontinuerligt
;*       i enlighet med specifikationerna.
;********************************************************************************/
main:
   LDI R16, (1 << LED1) | (1 << LED2) | (1 << LED3) ; Läser in 0000 0111 i R16.
   OUT DDRB, R16                                    ; Sätter lysdioderna till utportar.
   LDI R16, (1 << BUTTON1) | (1 << BUTTON2)         ; Läser in 0011 0000 i R16.
   OUT PORTB, R16                                   ; Aktiverar interna pullup-resistorer.
   LDI R16, (1 << LED1)                             ; Läser in 0000 0001 i R16.
   LDI R17, (1 << LED2)                             ; Läser in 0000 0010 i R17.
   LDI R18, (1 << LED3)                             ; Läser in 0000 0100 i R18.

;/********************************************************************************
;* main_loop: Håller igång programmet så länge matningsspänning tillförs.
;*            Utefter aktuell status på tryckknapparna kontrolleras lysdioderna.
;********************************************************************************/
main_loop:
   IN R24, PINB                ; Läser in insignaler från PINB i R24 för att kontrollera BUTTON1.
   MOV R25, R24                ; Kopierar innehållet till R25 för att senare kontrollera BUTTON2.
   ANDI R24, (1 << BUTTON1)    ; Kontrollerar insignalen från BUTTON1.
   BRNE button1_is_pressed     ; Om BUTTON1 är nedtryckt sker hopp till designerad branch.
   RJMP button1_is_not_pressed ; Om BUTTON1 inte är nedtryckt sker hopp till designerad branch.

;/********************************************************************************
;* button1_is_pressed: Branch som exekverar ifall BUTTON1 är nedtryckt.
;*                     Om även BUTTON2 är nedtryckt tänds lysdioderna, annars
;*                     blinkar de framåt i en slinga var 100:e ms.
;********************************************************************************/
button1_is_pressed:
   ANDI R25, (1 << BUTTON2) ; Kontrollerar insignalen från BUTTON2.
   BRNE leds_on             ; Om också BUTTON2 är nedtryckt tänds lysdioderna.
   RJMP leds_blink_forwards ; Annars blinkar lysdioderna framåt i en slinga.

;/********************************************************************************
;* button1_isnot__pressed: Branch som exekverar ifall BUTTON1 inte är nedtryckt.
;*                         Om BUTTON2 är nedtryckt blinkar lysdioderna bakåt
;*                         i en slinga var 100:e ms, annars hålls de släckta.
;********************************************************************************/
button1_is_not_pressed:
   ANDI R25, (1 << BUTTON2)  ; Kontrollerar insignalen från BUTTON2.
   BRNE leds_blink_backwards ; Om BUTTON2 är nedtryckt blinkar lysdioderna bakåt i en slinga. 
   RJMP leds_off             ; Annars släcks lysdioderna.

;/********************************************************************************
;* leds_on: Tänder lysdioderna genom att ettställa lysdiodernas bitar i
;*          dataregister PORTB utan att påverka övriga bitar.
;********************************************************************************/
leds_on:
   IN R24, PORTB                                    ; Läser signaler från PORTB.
   ORI R24, (1 << LED1) | (1 << LED2) | (1 << LED3) ; Ettställer lysdiodernas bitar.
   OUT PORTB, R24                                   ; Tänder lysdioderna.
   RJMP main_loop                                   ; Återstartar loopen i main.

   
;/********************************************************************************
;* leds_off: Släcker lysdioderna genom att nollställa lysdiodernas bitar i
;*          dataregister PORTB utan att påverka övriga bitar.
;********************************************************************************/
leds_off:
   IN R24, PORTB                                        ; Läser signaler från PORTB.
   ANDI R24, ~((1 << LED1) | (1 << LED2) | (1 << LED3)) ; Nollställer lysdiodernas bitar.
   OUT PORTB, R24                                       ; Släcker lysdioderna.
   RJMP main_loop                                       ; Återstartar loopen i main.

;/********************************************************************************
;* leds_blink_forwards: Blinkar lysdioderna framåt i en slinga var 100:e ms.
;********************************************************************************/
leds_blink_forwards:
   IN R24, PORTB                                        ; Läser in signaler från PORTB.
   ANDI R24, ~((1 << LED1) | (1 << LED2) | (1 << LED3)) ; Nollställer lysdiodernas bitar.
   OUT PORTB, R24                                       ; Släcker lysdioderna innan blinkning.
   OUT PINB, R16                                        ; Tänder LED1 vid start.
   CALL delay_100ms                                     ; Genererar 100 ms fördröjning.
   OUT PINB, R16                                        ; Släcker LED1.
   OUT PINB, R17                                        ; Tänder LED2.
   CALL delay_100ms                                     ; Genererar 100 ms fördröjning.
   OUT PINB, R17                                        ; Släcker LED2.
   OUT PINB, R18                                        ; Tänder LED3.
   CALL delay_100ms                                     ; Genererar 100 ms fördröjning.
   OUT PINB, R18                                        ; Släcker LED3.
   RJMP main_loop                                       ; Återstartar loopen i main.

;/********************************************************************************
;* leds_blink_backwards: Blinkar lysdioderna bakåt i en slinga var 100:e ms.
;********************************************************************************/
leds_blink_backwards:
   IN R24, PORTB                                        ; Läser in signaler från PORTB.
   ANDI R24, ~((1 << LED1) | (1 << LED2) | (1 << LED3)) ; Nollställer lysdiodernas bitar.
   OUT PORTB, R24                                       ; Släcker lysdioderna innan blinkning.
   OUT PINB, R18                                        ; Tänder LED3 vid start.
   CALL delay_100ms                                     ; Genererar 100 ms fördröjning.
   OUT PINB, R18                                        ; Släcker LED3.
   OUT PINB, R17                                        ; Tänder LED2.
   CALL delay_100ms                                     ; Genererar 100 ms fördröjning.
   OUT PINB, R17                                        ; Släcker LED2.
   OUT PINB, R16                                        ; Tänder LED1.
   CALL delay_100ms                                     ; Genererar 100 ms fördröjning.
   OUT PINB, R16                                        ; Släcker LED6.
   RJMP main_loop                                       ; Återstartar loopen i main.

;/********************************************************************************
;* delay_100ms: Genererar ca 100 ms fördröjning genom uppräkning till 
;*              255 x 255 x 5 via CPU-register R24 - R26:
;*
;*              - R24 räknar kontinuerligt upp från 0 - 255.
;*              - R25 inkrementeras när R24 har räknat till 255. 
;*              - R26 inkrementeras när R25 har räknat upp till 255.
;*
;*              Därmed räknas R24 upp 255 gånger varje varv. R25 inkrementeras
;*              efter varje varv, vilket medför att efter 255 x 255 varv har
;*              R25 räknats upp till 255. Då inkrementeras R26, vilket sker
;*              fem gånger totalt, vilket medför 255 x 255 x 5 varv totalt.
;********************************************************************************/
delay_100ms:
   LDI R24, 0x00          ; Nollställer R24 inför uppräkning.
   LDI R25, 0x00          ; Nollställer R25 inför uppräkning.
   LDI R26, 0x00          ; Nollställer R26 inför uppräkning.
delay_100ms_loop:
   INC R24                ; Inkrementerar R24.
   CPI R24, 0xFF          ; Jämför innehållet i R24 med värdet 0xFF.
   BRLO delay_100ms_loop  ; Så länge innehållet i R24 understiger 0xFF repeteras loopen.
   LDI R24, 0x00          ; Nollställer R24 inför nästa uppräkning.
   INC R25                ; Inkrementerar R25 varje gång R24 har räknat upp till 255.
   CPI R25, 0xFF          ; Jämför innehållet i R25 med värdet 0xFF.
   BRLO delay_100ms_loop  ; Så länge innehållet i R25 understiger 0xFF repeteras loopen.
   LDI R25, 0x00          ; Nollställer R25 inför nästa uppräkning.
   INC R26                ; Inkrementerar R26 varje gång R26 har räknat upp till 255.
   CPI R26, 0x05          ; Jämför innehållet i R25 med värdet 0x05.
   BRLO delay_100ms_loop  ; Så länge innehållet i R26 understiger 0x05 repeteras loopen.
   RET                    ; Genomför återhopp till returadressen lagrad på stacken.