gcc -c src/mult.c -o mult.o -O3
stack exec ghc -- mult.o src/Bench.hs -o Bench
