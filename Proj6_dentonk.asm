TITLE Project 6     (Proj6_dentonk.asm)

; Author: Kelson Denton
; Last Modified: 12/02/2021
; OSU email address: dentonk@oregonstate.edu
; Course number/section:   CS271 Section 400
; Project Number: 6                Due Date: 12/5/2021
; Description: When run this program will prompt the user to enter 10 signed
;			   integers. It will return an error message if the number is too
;			   large to fit in a 32 bit register or if the string entered is 
;			   not an integer. Once all numbers have been entered, the sum and
;			   average of all entered numbers will be displayed to the console.
;			   Uses WriteVal and ReadVal procedures to display and recieve all 
;			   strings from the user, converting them into integers and vice versa.

INCLUDE Irvine32.inc

; ---------------------------------------------------------
; Macro that will prompt a user for an input on the console, then saves
; the contents of the input as a string and the length of the string to
; specified memory locations.
; precondition: paramaters passed into macro
; postcondition: String and string length saved to mem locations
; receives: Prompt for user (userPrompt), memory location for string (strMem),
;			maximum length the input (strLen), memory location for string
;			length (lenMem)
; returns: String input saved to strMem and length saved to lenMem
; ---------------------------------------------------------
mGetString MACRO  userPrompt, maxLen, strMem, lenMem
	
	PUSH	EDX
	PUSH	ECX
	PUSH	EAX
	; Prompt user for input
	MOV		EDX, userPrompt
	CALL	WriteString
	; Recieve user input as string
	MOV		EDX, strMem
	MOV		ECX, maxLen
	CALL	ReadString
	MOV		lenMem, EAX		; store length of string in mem location
	; Restore registers
	POP		EAX
	POP		ECX
	POP		EDX

ENDM

; ---------------------------------------------------------
; Displays a string from a memory address to the console.
; precondition: None
; postcondition: String passed will be displayed to the console
; receives: address of string in memory
; returns: console printed with passed string
; ---------------------------------------------------------
mDisplayString MACRO dispStr

	PUSH	EDX
	MOV		EDX, dispStr
	CALL	WriteString
	POP		EDX

ENDM

; Constant Definitions
ARRAYSIZE = 10			; size of array to hold user numbers entered
STRLEN = 12				; maximum length of string user can enter
ASCIILO = 48			; minimum number for ASCII value to be an integer
ASCIIHI = 57			; maximum number for ASCII value to be an integer
NEGATIVE = 45			; ASCII value of negative sign
POSITIVE = 43			; ASCII value of positive sign
MULTIPLE = 10			; number to multiply by in conversion of ASCII values
TWOSCOMP = 4294967295	; number to perform 2s complement calculation
MOSTSIGBIT = 2147483648 ; most significant bit of 32-bit register

.data

author		BYTE	"Author: Kelson Denton      ", 0		; string for author name
projTitle	BYTE	"Project 6", 10, 13, 0					; string for project title
introMsg	BYTE	"Please input 10 signed integers. If integers are too large to fit", 10, 13		; string for introduction
			BYTE	"in a 32-bit register or are not integers you will receive and error.", 10, 13
			BYTE	"Once all numbers are entered then all numbers will be displayed ", 10, 13
			BYTE	"with their sum and average.", 10, 13, 0
errorMsg	BYTE	"Number too large for register or not a valid integer. Please try again.", 10, 13, 0
prompt		BYTE	"Enter a number: ", 0					; string for invalid input
dispMsg		BYTE	"The following numbers were entered: ", 10, 13, 0  ; string for displaying numbers
sumMsg		BYTE	"Sum of the numbers is: ", 0			; string for displaying sum
avgMsg		BYTE	"Average of the numbers is: ", 0		; string for displaying average of all numbers
goodbye		BYTE	"Thanks for playing! Goodbye.", 0		; string for program end
comma		BYTE	", ",0									; comma to insert between values
negSign		BYTE	"-", 0									; negative sign for number strings
userNum		SDWORD	?										; store user entered value after int conversion
numStr		DWORD	?										; store user number when it is a string
dispStr		BYTE	STRLEN DUP(?)							; array store string to display to user
revStr		BYTE	?										; store reverse string used in WriteVal
lenUserNum	DWORD	?										; store length of user entered value
numArray	SDWORD	ARRAYSIZE DUP(?)						; array to store 10 numbers enterd by user
sum			DWORD	0										; sum of numbers user has entered
average		DWORD   0										; average of numbers entered by user

.code
main PROC

	; Display introductory information to console
	mDisplayString	OFFSET author
	mDisplayString	OFFSET projTitle
	mDisplayString	OFFSET introMsg
	; Begin to loop gathering user entered values
	MOV		ECX, ARRAYSIZE
	XOR		EBX, EBX
	XOR		EDX, EDX
 _getUserVal:
	; Get integer input from user using ReadVal
	PUSH	OFFSET userNum				; output int
	PUSH	OFFSET errorMsg				; error string
	PUSH	OFFSET prompt				; prompt for user
	PUSH	OFFSET numStr				; number string
	PUSH	OFFSET lenUserNum			; length of user number
	CALL	ReadVal
	; move userNum to next value in numArray
	MOV		EDI, OFFSET numArray		
	MOV		EAX, userNum
	MOV		[EDI+EBX*4], EAX
	INC		EBX
	LOOP	_getUserVal

	MOV		ECX, LENGTHOF numArray		; set loop count to array length
	XOR		EBX, EBX
	mDisplayString	OFFSET dispMsg		; message to show entered numbers
 _displayUserVal:
	; Display integer numbers in array as strings
	MOV		EDI, OFFSET numArray
	MOV		EAX, [EDI+EBX*4]
	PUSH	OFFSET	negSign			; sign for negative numbers
	PUSH	OFFSET	revStr			; storage for reverse string generated
	PUSH	OFFSET	dispStr			; storage for string to be displayed
	PUSH	EAX						; value to convert to string
	CALL	WriteVal
	mDisplayString	OFFSET comma
	ADD		EAX, sum				; add to sum total
	MOV		sum, EAX
	INC		EBX
	LOOP	_displayUserVal
	CALL	CrLf

	; Display sum to user
	mDisplayString	OFFSET sumMsg	; display message
	PUSH	OFFSET	negSign			; push variables
	PUSH	OFFSET	revStr
	PUSH	OFFSET  dispStr
	PUSH	sum
	CALL	WriteVal
	CALL	CrLf

	; Display average to user
	; clear registers
	mDisplayString	OFFSET avgMsg
	XOR		EBX, EBX
	XOR		EAX, EAX
	XOR		EDX, EDX
	; divide sum by number of integers
	MOV		EAX, sum
	MOV		EBX, ARRAYSIZE
	CDQ									; sign extend EAX into EDX to make QUADWORD
	IDIV	EBX	
	; push values for WriteVal
	PUSH	OFFSET	negSign
	PUSH	OFFSET	revStr
	PUSH	OFFSET	dispStr
	PUSH	EAX
	CALL	WriteVal
	CALL	CrLf
	
	; Display goodbye message
	mDisplayString	OFFSET goodbye

	Invoke ExitProcess,0	; exit to operating system
main ENDP

; (insert additional procedures here)

; ---------------------------------------------------------
; Gets a user input using the mGetString macro, then converting it
; to an integer, and returning an error if the input is invalid. If
; input is valid the value is stored at an output memory location passed
; by reference.
; precondition: Stack aligned with input and output reference, 
;				with error string at [EBP+20], prompt string at [EBP+16]
;				variable to store the length of the number at [EBP+8],
;				and the string to convert to an int at [EBP+4}
; postcondition: User input saved to mem location
; receives: mem location of prompt string, mem location of error message,
;			address of output parameter
; returns: integer user entered converted to integer and saved to passed
;		   memory location
; ---------------------------------------------------------
ReadVal PROC
	; variable to store integer while it is being constructed, whether it is negative
	LOCAL	storeChar:BYTE, isNeg:DWORD	
	PUSHAD
	XOR		EBX, EBX
	MOV		isNeg, EBX					; zero isNeg value
	JMP		_start

 _dispError:
	mDisplayString	[EBP+20]			; display error to user

 _start:
	; Get user input in console
	mGetString [EBP+16], STRLEN, [EBP+12], [EBP+8]	; pass prompt, STRLEN, numStr, and lenUserNum
	; Checks if string entered can be converted to an integer, if it can it performs conversion
	MOV		ESI, [EBP+12]				; move numStr to ESI
	MOV		ECX, [EBP+8]				; set counter equal to length of number	
	XOR		EBX, EBX					; zero EBX register to store numInt
	XOR		EAX, EAX

 _convert:
 	; Convert from string to int
	CLD
	LODSB
	CMP		AL, NEGATIVE				; look for negative sign
	JNE		_notNeg
	CMP		ECX, [EBP+8]
	JNE		_dispError					; show error if negative sign is not at front of string
	MOV		EDI, 1						; set isNeg to 1 if one exists
	MOV		isNeg, EDI
	JMP		_end						; skip to next index
	
 _notNeg:								; jump here if not a negative sign
	CMP		AL, POSITIVE				; look for a plus sign
	JNE		_continue					; continue through loop if there isn't one
	CMP		ECX, [EBP+8]
	JNE		_dispError					; show error if + is not at front of string
	JMP		_end						; jump to end if it is at front of string
_continue:
	; check ASCII value corresponds to integers
	CMP		AL, ASCIILO
	JL		_dispError
	CMP		AL, ASCIIHI
	JG		_dispError
	; numInt = 10*numInt+(numChar-48)
	MOV		storeChar, AL				; 10*numInt
	MOV		EAX, MULTIPLE
	IMUL	EBX
	MOV		EBX, EAX
	XOR		EAX, EAX					; clear EAX register
	MOV		AL, storeChar				; numChar-48
	SUB		AL, ASCIILO
	ADD		EBX, EAX					; (10*numInt)+(numChar-48)
	JS		_dispError					; catch values too large for 32-bit register
	
 _end:									; used to skip to end if plus sign is entered
	LOOP	_convert

	XOR		EAX, EAX					; check if negative was encountered
	CMP		isNeg, EAX
	JE		_saveNum					; negative was not encountered
	; perform 2s complement on EBX register
	MOV		EAX, TWOSCOMP
	SUB		EAX, EBX
	INC		EAX
	MOV		EBX, EAX
	; toggle most significant bit on EBX to 1
	MOV		EAX, MOSTSIGBIT					
	XOR		EAX, EBX

 _saveNum:
	; Save EBX to userNum memory
	XOR		EDX, EDX
	MOV		EDX, [EBP+24]
	MOV		[EDX], EBX

	; restore register states
	POPAD
	RET		24
readVal ENDP

; ---------------------------------------------------------
; Gets a saved integer value from a memory location, then converts it
; to a string and uses mDisplayString macro to display the newly 
; converted string to the console.
; precondition: Stack aligned with variable to store negative sign string
;				at [EBP+20], reverse string at [EBP+16], display string at [EBP+12]
;				and int to be converted at [EBP+8]
; postcondition: Int displayed to console as a string
; receives: dispString and numStr
; returns: number displayed to the console
; ---------------------------------------------------------
WriteVal PROC
	
	LOCAL	numMem:DWORD, lenCount:DWORD
	PUSHAD							; save registers
	XOR		EDI, EDI				; clear source and destination registers
	XOR		ESI, ESI
	MOV		EDI, [EBP+16]			; set destination as reverseString
	MOV		EAX, [EBP+8]			; put integer in EAX to be divided
	XOR		EBX, EBX				
	MOV		lenCount, EBX			; zero lengthcount

	; check if number is negative
	CMP		EAX, 0
	JGE		_convert				; number is not negative
	; performs 2's complement conversion
	mDisplayString [EBP+20]			; show negative sign
	MOV		EBX, TWOSCOMP
	SUB		EBX, EAX
	INC		EBX
	MOV		EAX, EBX
	XOR		EBX, EBX

 _convert:
	; creates string of digits in reverse order
	XOR		EDX, EDX				; clear for division
	MOV		EBX, MULTIPLE
	IDIV	EBX						; divide by 10
	MOV		numMem, EAX
	ADD		EDX, ASCIILO			; add 48 to remainder
	MOV		EAX, EDX
	STOSB							; store result
	MOV		EAX, numMem
	INC		lenCount
	CMP		EAX, 0					; if quotient is zero, whole number has been iterated
	JNE		_convert

	; Reverse string back to normal order
	; set registers to correct values
	MOV		ECX, lenCount
	MOV		EDI, [EBP+12]			; point to dispStr with EDI
	MOV		ESI, [EBP+16]			; point to revStr with ESI
	ADD		ESI, ECX
	DEC		ESI
	XOR		EAX, EAX

 _reverseStr:
	; iterate through reversing movement
	STD
    LODSB
	CLD
    STOSB
	LOOP	_reverseStr
	; null terminate string
	MOV		EAX, 0
	STOSB
	mDisplayString [EBP+12]

	POPAD							; restore registers
	RET		20
WriteVal ENDP

END main
