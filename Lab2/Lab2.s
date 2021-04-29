SYSEXIT32 = 1
EXIT_SUCCESS = 0
SYSCALL32 = 0x80
SYSWRITE = 4
SYSREAD = 3
STDOUT = 1
STDIN = 0
BUFF_LEN = 200
RESULT_LEN = 2*BUFF_LEN

.global _start                    #wskazanie punktu wejścia do programu

.section .bss                     #segment danych niezarejestrowanych
.lcomm my_buffer1, BUFF_LEN       #inicjowanie buforów
.lcomm my_buffer2, BUFF_LEN
.lcomm hex_number1, BUFF_LEN
.lcomm hex_number2, BUFF_LEN

.data                             #segment danych
result: .space RESULT_LEN

.text
msg1: .ascii "Podaj pierwsza liczbe calkowita: "    #etykieta napisu wraz z dyrektywą rezerwującą pamięć dla napisu
msg1_len = . - msg1                                 #długość napisu
msg2: .ascii "Podaj druga liczbe calkowita: "
msg2_len = . - msg2


_start:
#wypisanie napisu msg1
mov $SYSWRITE, %eax           #wywołanie funkcji write
mov $STDOUT, %ebx             #pierwszy argument funkcji, będący deskryptorem stdout
mov $msg1, %ecx               #drugi argument funkcji, będący adresem początkowym napisu
mov $msg1_len, %edx           #trzeci argument funkcji, będący długością łańcucha
int $SYSCALL32                #wywołanie przerwania systemowego

#wczytanie napisu do buforu pierwszego
mov $SYSREAD, %eax            #wywołanie funkcji read
mov $STDIN, %ebx              #pierwszy argument funkcji, będący deskryptorem stdin
mov $my_buffer1, %ecx         #drugi argument funkcji, będący adresem bufora
mov $BUFF_LEN, %edx           #trzeci argument funkcji, będący długością bufora
int $SYSCALL32

#wypisanie napisu msg2
mov $SYSWRITE, %eax
mov $STDOUT, %ebx
mov $msg2, %ecx
mov $msg2_len, %edx
int $SYSCALL32

#wczytanie napisu do buforu drugiego
mov $SYSREAD, %eax
mov $STDIN, %ebx
mov $my_buffer2, %ecx
mov $BUFF_LEN, %edx
int $SYSCALL32

mov $my_buffer1, %eax           #eax - adres pierwszego napisu
mov $BUFF_LEN, %ecx             #ecx - długość bufora

#sprawdzanie długości pierwszego napisu
mov $0, %esi                    #esi - przechowuje długość napisu

loop1:
cmp $0, %ecx                  #koniec, jeśli bufor jest pusty
je next1
mov (%eax), %bl               #wartość znaku do rejestru bl
cmp $'\n', %bl                #znak końca linii oznacza koniec napisu
je next1
inc %eax                      #rozpatrujemy kolejny znak
dec %ecx                      #zmniejszamy długość sprawdzanego bufora
inc %esi                      #zwiększamy długość napisu
jmp loop1

next1:
mov $my_buffer1, %eax
add %esi, %eax              #przechodzimy do końca napisu
sub $8, %eax                #przechodzimy do ostatniego bajtu napisu
mov $0, %edx
mov $0, %edi

mov $BUFF_LEN, %ecx

#sprawdzanie czy znak jest cyfra
loop2:
cmp $0, %ecx           #jeśli bufor pusty to koniec sprawdzania
je okay
mov (%eax), %bl        #wartość z bufora do bl

cmp $'0', %bl          #jeśli mniejsze niż znak 0 to nie jest liczba
jl end

cmp $'9', %bl          #jeśli miedzy 0 a 9 to liczba
jle number

cmp $'A', %bl          #jeśli większe od 0, większe od 9 i mniejsze od A to nie jest liczba
jl end

cmp $'F', %bl          #jeśli pomiędzy A i F to duzy znak należący do hex
jle big_char

cmp $'a', %bl          #jeśli większy od F i mniejszy od a to nie jest liczba hex
jl end

cmp $'f', %bl          #jeśli większy od f to nie jest liczba hex
ja end

char:
subb $0x57, %bl       #od rozpoznanego małego znaku odejmujemy 57h i przepisujemy do bufora liczby
jmp write

big_char:
subb $0x37, %bl       #od rozpoznanego dużego znaku odejmujemy 37h i przepisujemy do bufora liczby
jmp write

number:
subb $0x30, %bl       #od rozpoznanego znaku cyfry odejmujemy 30h i przepisujemy do bufora liczby

write:
shll $4, hex_number1(,%edx,4)       #bierze pod uwagę tylko cyfrę
addl %ebx, hex_number1(,%edx, 4)    #wpisuje w odpowiednie miejsce
end:
inc %eax              #rozpatrujemy kolejny znak
dec %ecx              #zmniejszamy rozmiar bufora
inc %edi              #edi - licznik przepisanych bitów
cmp $8,%edi           #jeśli bajt to przesuwamy bufor
je shift
jmp loop2

shift:
shrl $4, %ebx             #przesuniecie miejsca w buforze liczby
subl $16, %eax            #przechodzimy do poprzednich bajtów
mov $0, %edi
inc %edx
jmp loop2

okay:
mov $0, %eax
mov $0, %ebx
mov $0, %ecx
mov $0, %edx
mov $0, %esi

mov $my_buffer2, %eax   #eax - adres drugiego napisu
mov $BUFF_LEN, %ecx     #ecx - długość bufora

#sprawdzanie długości drugiego napisu
loop3:
cmp $0, %ecx
je done1
mov (%eax), %bl
cmp $'\n', %bl
je done1
inc %eax
dec %ecx
inc %esi
jmp loop3

done1:
mov $my_buffer2, %eax
add %esi, %eax
sub $8, %eax
mov $BUFF_LEN, %ecx
mov $0, %edx
mov $0, %edi

#sprawdzanie czy znak jest cyfra
loop4:
cmp $0, %ecx
je okay2
mov (%eax), %bl

cmp $'0', %bl
jl end1

cmp $'9', %bl
jle number1

cmp $'A', %bl
jl end1

cmpb $'F', %bl
jle big_char1

cmp $'a', %bl
jl end1

cmpb $'f', %bl
ja end1

char1:
subb $0x57, %bl
jmp write1

big_char1:
subb $0x37, %bl
jmp write1

number1:
subb $0x30, %bl

write1:
shll $4, hex_number2(,%edx,4)
addl %ebx, hex_number2(,%edx, 4)
end1:
inc %eax
dec %ecx
inc %edi
cmp $8,%edi
je shift1
jmp loop4

shift1:
shrl $4, %ebx
subl $16, %eax
mov $0, %edi
inc %edx
jmp loop4

okay2:
mov $0, %eax
mov $0, %ebx
mov $0, %ecx
mov $0, %edx
mov $0, %esi


#mnozenie gotowych liczb hex
mov $0, %ebx           #iterator pętli zewnętrznej

outside_loop:
cmp $BUFF_LEN, %ebx    #jeśli przekroczony rozmiar liczby to koniec
jz end_program
mov $0, %ecx           #iterator pętli wewnętrznej
mov $0, %esi           #przeniesienie pozycji

inside_loop:
mov $0, %edi
cmp $BUFF_LEN, %ecx               #jeśli przekroczony rozmiar liczby to koniec
jz end_i
movl hex_number1(,%ebx,4), %eax   #przenosimy liczby z odpowiednich pozycji do danych rejestrów
movl hex_number2(,%ecx,4), %edx
mull %edx                         #mnożymy powyższe liczby
addl %ebx, %ecx                   #obliczamy potęgę podstawy
addl result(,%ecx,4), %eax        #dodajemy obecnie otrzymany wynik do wartości w rejestrze eax
movl %eax, result(,%ecx,4)        #kopiujemy wynik na odpowiednia pozycje
inc %ecx                          #zwiększamy pozycje i sprawdzamy ewentualne wytworzenie przeniesienia
adcl result(,%ecx,4), %edx
adcl $0, %edi
addl %esi, %edx
adcl $0, %edi
movl %edi, %esi
movl %edx, result(,%ecx,4)        #kopiujemy ostateczny wynik na odpowiednia pozycje
subl %ebx, %ecx                   #przywracamy wartość w ecx
jmp inside_loop
end_i:
inc %ebx
jmp outside_loop

end_program:
#zakończenie programu
mov $SYSEXIT32, %eax              #wywołanie funkcji sysexit
mov $EXIT_SUCCESS, %ebx           #argument funkcji, będący kodem wyjścia programu
int $SYSCALL32
