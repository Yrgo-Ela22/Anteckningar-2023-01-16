;/********************************************************************************
;* exercise.asm: L�sningsf�rslag f�r dagens �vningsuppgift. 
;*               Tre lysdioder ansluts till pin 8 - 10 (PORTB0 - PORTB2) och
;*               tv� tryckknappar ansluts till pin 12 - 13 (PORTB4 - PORTB5).
;*
;*               - I vilol�get h�lls lysdioderna sl�ckta.
;*               - Om enbart tryckknapp 1 ansluten till pin 12 (PORTB4) trycks
;*                 ned blinkar lysdioderna fram�t i en slinga var 100:e ms.
;                - Om enbart tryckknapp 2 ansluten till pin 13 (PORTB5) trycks
;*                 ned blinkar lysdioderna bak�t i en slinga var 100:e ms.
;*               - Om b�da tryckknappar trycks ned h�lls lysdioderna t�nda.
;*
;*               Notering: Under programmets g�ng sparas v�rden f�r att enkelt
;*                         kunna toggla respektive lysdiod i CPU-register:
;*
;*                          - R16 = (1 << LED1)
;*                          - R17 = (1 << LED2)
;*                          - R18 = (1 << LED3)
;*
;*                          Skriv inte �ver dessa v�rden efter initiering!
;********************************************************************************/

; Makrodefinitioner:
.EQU LED1 = PORTB0    ; Lysdiod 1 ansluten till pin 8 (PORTB0).
.EQU LED2 = PORTB1    ; Lysdiod 2 ansluten till pin 9 (PORTB1).
.EQU LED3 = PORTB2    ; Lysdiod 3 ansluten till pin 10 (PORTB2).
.EQU BUTTON1 = PORTB4 ; Tryckknapp 1 ansluten till pin 12 (PORTB4).
.EQU BUTTON2 = PORTB5 ; Tryckknapp 2 ansluten till pin 13 (PORTB5).

;/********************************************************************************
;* .CSEG: Programminnet - H�r lagras programkoden.
;********************************************************************************/
.CSEG
.ORG 0x00    ; Programmets startadress.
   RJMP main ; Anropar subrutinen main f�r att starta programmet.

;/********************************************************************************
;* main: Initierar systemet vid start. Programmet exekverar sedan kontinuerligt
;*       i enlighet med specifikationerna.
;********************************************************************************/
main:
   LDI R16, (1 << LED1) | (1 << LED2) | (1 << LED3) ; L�ser in 0000 0111 i R16.
   OUT DDRB, R16                                    ; S�tter lysdioderna till utportar.
   LDI R16, (1 << BUTTON1) | (1 << BUTTON2)         ; L�ser in 0011 0000 i R16.
   OUT PORTB, R16                                   ; Aktiverar interna pullup-resistorer.
   LDI R16, (1 << LED1)                             ; L�ser in 0000 0001 i R16.
   LDI R17, (1 << LED2)                             ; L�ser in 0000 0010 i R17.
   LDI R18, (1 << LED3)                             ; L�ser in 0000 0100 i R18.

;/********************************************************************************
;* main_loop: H�ller ig�ng programmet s� l�nge matningssp�nning tillf�rs.
;*            Utefter aktuell status p� tryckknapparna kontrolleras lysdioderna.
;********************************************************************************/
main_loop:
   IN R24, PINB                ; L�ser in insignaler fr�n PINB i R24 f�r att kontrollera BUTTON1.
   MOV R25, R24                ; Kopierar inneh�llet till R25 f�r att senare kontrollera BUTTON2.
   ANDI R24, (1 << BUTTON1)    ; Kontrollerar insignalen fr�n BUTTON1.
   BRNE button1_is_pressed     ; Om BUTTON1 �r nedtryckt sker hopp till designerad branch.
   RJMP button1_is_not_pressed ; Om BUTTON1 inte �r nedtryckt sker hopp till designerad branch.

;/********************************************************************************
;* button1_is_pressed: Branch som exekverar ifall BUTTON1 �r nedtryckt.
;*                     Om �ven BUTTON2 �r nedtryckt t�nds lysdioderna, annars
;*                     blinkar de fram�t i en slinga var 100:e ms.
;********************************************************************************/
button1_is_pressed:
   ANDI R25, (1 << BUTTON2) ; Kontrollerar insignalen fr�n BUTTON2.
   BRNE leds_on             ; Om ocks� BUTTON2 �r nedtryckt t�nds lysdioderna.
   RJMP leds_blink_forwards ; Annars blinkar lysdioderna fram�t i en slinga.

;/********************************************************************************
;* button1_isnot__pressed: Branch som exekverar ifall BUTTON1 inte �r nedtryckt.
;*                         Om BUTTON2 �r nedtryckt blinkar lysdioderna bak�t
;*                         i en slinga var 100:e ms, annars h�lls de sl�ckta.
;********************************************************************************/
button1_is_not_pressed:
   ANDI R25, (1 << BUTTON2)  ; Kontrollerar insignalen fr�n BUTTON2.
   BRNE leds_blink_backwards ; Om BUTTON2 �r nedtryckt blinkar lysdioderna bak�t i en slinga. 
   RJMP leds_off             ; Annars sl�cks lysdioderna.

;/********************************************************************************
;* leds_on: T�nder lysdioderna genom att ettst�lla lysdiodernas bitar i
;*          dataregister PORTB utan att p�verka �vriga bitar.
;********************************************************************************/
leds_on:
   IN R24, PORTB                                    ; L�ser signaler fr�n PORTB.
   ORI R24, (1 << LED1) | (1 << LED2) | (1 << LED3) ; Ettst�ller lysdiodernas bitar.
   OUT PORTB, R24                                   ; T�nder lysdioderna.
   RJMP main_loop                                   ; �terstartar loopen i main.

   
;/********************************************************************************
;* leds_off: Sl�cker lysdioderna genom att nollst�lla lysdiodernas bitar i
;*          dataregister PORTB utan att p�verka �vriga bitar.
;********************************************************************************/
leds_off:
   IN R24, PORTB                                        ; L�ser signaler fr�n PORTB.
   ANDI R24, ~((1 << LED1) | (1 << LED2) | (1 << LED3)) ; Nollst�ller lysdiodernas bitar.
   OUT PORTB, R24                                       ; Sl�cker lysdioderna.
   RJMP main_loop                                       ; �terstartar loopen i main.

;/********************************************************************************
;* leds_blink_forwards: Blinkar lysdioderna fram�t i en slinga var 100:e ms.
;********************************************************************************/
leds_blink_forwards:
   IN R24, PORTB                                        ; L�ser in signaler fr�n PORTB.
   ANDI R24, ~((1 << LED1) | (1 << LED2) | (1 << LED3)) ; Nollst�ller lysdiodernas bitar.
   OUT PORTB, R24                                       ; Sl�cker lysdioderna innan blinkning.
   OUT PINB, R16                                        ; T�nder LED1 vid start.
   CALL delay_100ms                                     ; Genererar 100 ms f�rdr�jning.
   OUT PINB, R16                                        ; Sl�cker LED1.
   OUT PINB, R17                                        ; T�nder LED2.
   CALL delay_100ms                                     ; Genererar 100 ms f�rdr�jning.
   OUT PINB, R17                                        ; Sl�cker LED2.
   OUT PINB, R18                                        ; T�nder LED3.
   CALL delay_100ms                                     ; Genererar 100 ms f�rdr�jning.
   OUT PINB, R18                                        ; Sl�cker LED3.
   RJMP main_loop                                       ; �terstartar loopen i main.

;/********************************************************************************
;* leds_blink_backwards: Blinkar lysdioderna bak�t i en slinga var 100:e ms.
;********************************************************************************/
leds_blink_backwards:
   IN R24, PORTB                                        ; L�ser in signaler fr�n PORTB.
   ANDI R24, ~((1 << LED1) | (1 << LED2) | (1 << LED3)) ; Nollst�ller lysdiodernas bitar.
   OUT PORTB, R24                                       ; Sl�cker lysdioderna innan blinkning.
   OUT PINB, R18                                        ; T�nder LED3 vid start.
   CALL delay_100ms                                     ; Genererar 100 ms f�rdr�jning.
   OUT PINB, R18                                        ; Sl�cker LED3.
   OUT PINB, R17                                        ; T�nder LED2.
   CALL delay_100ms                                     ; Genererar 100 ms f�rdr�jning.
   OUT PINB, R17                                        ; Sl�cker LED2.
   OUT PINB, R16                                        ; T�nder LED1.
   CALL delay_100ms                                     ; Genererar 100 ms f�rdr�jning.
   OUT PINB, R16                                        ; Sl�cker LED6.
   RJMP main_loop                                       ; �terstartar loopen i main.

;/********************************************************************************
;* delay_100ms: Genererar ca 100 ms f�rdr�jning genom uppr�kning till 
;*              255 x 255 x 5 via CPU-register R24 - R26:
;*
;*              - R24 r�knar kontinuerligt upp fr�n 0 - 255.
;*              - R25 inkrementeras n�r R24 har r�knat till 255. 
;*              - R26 inkrementeras n�r R25 har r�knat upp till 255.
;*
;*              D�rmed r�knas R24 upp 255 g�nger varje varv. R25 inkrementeras
;*              efter varje varv, vilket medf�r att efter 255 x 255 varv har
;*              R25 r�knats upp till 255. D� inkrementeras R26, vilket sker
;*              fem g�nger totalt, vilket medf�r 255 x 255 x 5 varv totalt.
;********************************************************************************/
delay_100ms:
   LDI R24, 0x00          ; Nollst�ller R24 inf�r uppr�kning.
   LDI R25, 0x00          ; Nollst�ller R25 inf�r uppr�kning.
   LDI R26, 0x00          ; Nollst�ller R26 inf�r uppr�kning.
delay_100ms_loop:
   INC R24                ; Inkrementerar R24.
   CPI R24, 0xFF          ; J�mf�r inneh�llet i R24 med v�rdet 0xFF.
   BRLO delay_100ms_loop  ; S� l�nge inneh�llet i R24 understiger 0xFF repeteras loopen.
   LDI R24, 0x00          ; Nollst�ller R24 inf�r n�sta uppr�kning.
   INC R25                ; Inkrementerar R25 varje g�ng R24 har r�knat upp till 255.
   CPI R25, 0xFF          ; J�mf�r inneh�llet i R25 med v�rdet 0xFF.
   BRLO delay_100ms_loop  ; S� l�nge inneh�llet i R25 understiger 0xFF repeteras loopen.
   LDI R25, 0x00          ; Nollst�ller R25 inf�r n�sta uppr�kning.
   INC R26                ; Inkrementerar R26 varje g�ng R26 har r�knat upp till 255.
   CPI R26, 0x05          ; J�mf�r inneh�llet i R25 med v�rdet 0x05.
   BRLO delay_100ms_loop  ; S� l�nge inneh�llet i R26 understiger 0x05 repeteras loopen.
   RET                    ; Genomf�r �terhopp till returadressen lagrad p� stacken.