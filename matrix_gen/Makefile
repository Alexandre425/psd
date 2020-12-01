RELEASE = $(shell v)

CFLAGS    = -g -Wall -pedantic -ansi -Wextra -fno-diagnostics-color -m32
CFLAGSMAC = -g -Wall -pdeantic -ansi -std=gnu99


adet linux cygwin: adet.c
	gcc $(CFLAGS) -DPLAT=1 -o adet adet.c -lm

# Cross compilation (in linux for windows)
adet.exe win32: adet.c
	i686-w64-mingw32-gcc   $(CFLAGS) -DPLAT=2 -o adet.exe adet.c -lm

#adet.exe win64: adet.c
#	x86_64-w64-mingw32-gcc $(CFLAGS) -DPLAT=2 -o adet.exe adet.c -lm

adet.bin mac: adet.c
	gcc $(CFLAGSMAC) -DPALT=4 -o adet.bin adet.c -lm


clean:
	- rm adet adet.exe adet.bin
	- rm -r adet.bin.dSYM

cleandata:
	rm *.dat *.itr *.out


zip: README.pdf Makefile adet.c adet adet.exe hexdump.exe sd765.dat sd765.itr

	- rm adet-${RELEASE}.zip
	zip adet-${RELEASE}.zip README.pdf Makefile adet.c adet adet.exe hexdump.exe sd765.dat sd765.itr
