SYSEXIT32 = 1
EXIT_SUCCES = 0
SYSCALL32 = 0x80
SYSWRITE = 4
SYSREAD = 3
BUFF_LEN = 200
STDIN = 0
STDOUT = 1

.global _start

.section .bss                  #segment danych niezarejestrowanych
buff1: .space BUFF_LEN          #inicjowanie buforów
.lcomm my_buffer1, 200

buff2: .space BUFF_LEN
.lcomm my_buffer2, 200

buff3: .space 1
.lcomm my_buffer3, 1

.text
msg1: .ascii "Podaj pierwsza liczbe rzeczywista: " #etykieta napisu wraz z dyrektywą rezerwującą pamięć dla napisu
msg1_len = .-msg1                                  #długość napisu
msg2: .ascii "Podaj druga liczbe rzeczywista: "
msg2_len = .-msg2
msg3: .ascii "Podaj operacje do wykonania (+,-,*,/) lub 0 w celu zakonczenia programu: "
msg3_len = .-msg3

_start:
#wypisanie napisu msg1
mov $SYSWRITE, %eax            #wywołanie funkcji write
mov $STDOUT, %ebx              #pierwszy argument funkcji, będący deskryptorem stdout
mov $msg1, %ecx                #drugi argument funkcji, będący adresem początkowym napisu
mov $msg1_len, %edx            #trzeci argument funkcji, będący długością łańcucha
int $SYSCALL32                 #wywołanie przerwania systemowego

#wczytanie napisu do buforu pierwszego
mov $SYSREAD, %eax             #wywołanie funkcji read
mov $STDIN, %ebx               #pierwszy argument funkcji, będący deskryptorem stdin
mov $my_buffer1, %ecx           #drugi argument funkcji, będący adresem bufora
mov $BUFF_LEN, %edx            #trzeci argument funkcji, będący długością bufora
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

calculator_loop:

  #wypisanie napisu msg3
  mov $SYSWRITE, %eax
  mov $STDOUT, %ebx
  mov $msg3, %ecx
  mov $msg3_len, %edx
  int $SYSCALL32

  #wczytanie napisu do buforu trzeciego
  mov $SYSREAD, %eax
  mov $STDIN, %ebx
  mov $my_buffer3, %ecx
  mov $1, %edx
  int $SYSCALL32

  mov $my_buffer3, %eax

  cmpb $'+',(%eax)
  je addition

  cmpb $'-',(%eax)
  je removal

  cmpb $'*',(%eax)
  je multiplication

  cmpb $'/',(%eax)
  je division

  cmpb $'0',(%eax)
  je end

  addition:
      jmp calculator_loop

  removal:
      jmp calculator_loop

  multiplication:
      jmp calculator_loop

  division:
      jmp calculator_loop

#zakończenie programu
end:
mov $SYSEXIT32, %eax            #wywołanie funkcji sysexit
mov $EXIT_SUCCES, %ebx          #argument funkcji, będący kodem wyjścia programu
int $SYSCALL32
