refactor:
	perltidy shellcoder.pl
	mv shellcoder.pl.tdy shellcoder.pl
	perlcritic shellcoder.pl

clean:
	rm -f .*.o
	rm -f .*.c
	rm -f .*.out
	rm -f .*.dump
	rm -f .*.c
	rm -f .*.exe
	rm -f .*.obj

