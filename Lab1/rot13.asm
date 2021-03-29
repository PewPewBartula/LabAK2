SYSEXIT32 = 1
EXIT_SUCCES = 0
SYSCALL32 = 0x80
SYSWRITE = 4
SYSREAD = 3
BUFF_LEN = 100
STDIN = 0
STDOUT = 1

.global _start                 #wskazanie punktu wejścia do programu

.section .bss                  #segment danych niezarejestrowanych
buff: .space BUFF_LEN          #inicjowanie buforów
.lcomm my_buffer, 100


.text
msg1: .ascii "Podaj zdanie: "  #etykieta napisu wraz z dyrektywą rezerwującą pamięć dla napisu
msg1_len = .-msg1              #długość napisu
msg2: .ascii "ROT13: "
msg2_len = .-msg2

_start:
#wypisanie napisu msg1
mov $SYSWRITE, %eax            #wywołanie funkcji write
mov $STDOUT, %ebx              #pierwszy argument funkcji, będący deskryptorem stdout
mov $msg1, %ecx                #drugi argument funkcji, będący adresem początkowym napisu
mov $msg1_len, %edx            #trzeci argument funkcji, będący długością łańcucha
int $SYSCALL32                 #wywołanie przerwania systemowego

#wczytanie napisu do buforu
mov $SYSREAD, %eax             #wywołanie funkcji read
mov $STDIN, %ebx               #pierwszy argument funkcji, będący deskryptorem stdin
mov $my_buffer, %ecx           #drugi argument funkcji, będący adresem bufora
mov $BUFF_LEN, %edx            #trzeci argument funkcji, będący długością bufora
int $SYSCALL32

mov $my_buffer, %eax           #kopiowanie adresu bufora do akumulatora
mov $BUFF_LEN, %ecx            #kopiowanie długości bufora do ecx

#główna pętla - sprawdzenie czy znak jest dużą literą
loop1:
cmpl $0, %ecx                  #sprawdzenie czy ecx jest większy od 0
jz end                         #jeśli jest zerem to skok do end
mov (%eax), %bl                #kopiowanie do bl wartości z eax
cmpb $'A', %bl                 #porównanie bl do wartości znaku A
jb ignore                      #jeśli jest mniejszy to skok do ignore
cmpb $'Z', %bl                 #porównanie bl do wartości znaku Z
ja loop2                       #jeśli jest większy to skok do drugiej pętli
addb $13, %bl                  #dodanie wartości 13 do bl
cmpb $'Z',%bl                  #porównanie bl do wartości znaku Z
jbe okay                       #jeśli jest mniejszy lub równy to skok do okay
subb $26, %bl                  #odjęcie wartości 26 od bl
jmp okay                       #skok do okay

#sprawdzenie czy znak jest małą literą
loop2:
cmpb $'a',%bl                  #porównanie bl do wartości znaku a
jb ignore                      #jeśli jest mniejszy to skok do ignore
cmpb $'z',%bl                  #porównanie bl do wartości znaku z
ja ignore                      #jeśli jest większy to skok do ignore
addb $13, %bl                  #dodanie wartości 13 do bl
cmpb $'z',%bl                  #porównanie bl do wartości znaku z
jbe okay                       #jeśli jest mniejszy lub równy to skok do okay
subb $26, %bl                  #odjęcie wartości 26 od bl

#zapisanie sprawdzonego znaku do rejestru
okay:
movb %bl, (%eax)               #kopiowanie bl do eax

#iteracja głównej pętli
ignore:
incl %eax                      #zwiększenie eax
decl %ecx                      #zmniejszenie ecx
jmp loop1                      #skok do pętli głównej

#koniec pętli
end:

#wypisanie napisu msg2
mov $SYSWRITE, %eax
mov $STDOUT, %ebx
mov $msg2, %ecx
mov $msg2_len, %edx
int $SYSCALL32

#wypisanie zmodyfikowanego bufora
mov $SYSWRITE, %eax
mov $STDOUT, %ebx
mov $my_buffer, %ecx
mov $BUFF_LEN, %edx
int $SYSCALL32

#zakończenie programu
mov $SYSEXIT32, %eax            #wywołanie funkci sysexit
mov $EXIT_SUCCES, %ebx          #argument funkcji, będący kodem wyjścia programu
int $SYSCALL32
