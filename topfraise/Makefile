.PHONY: default opt demo
default: opt demo
opt:
	ocamlfind ocamlopt -o topfraise -package memories -linkpkg topfraise.ml
demo:
	zcat wonder.txt.gz | ./parser | ./topfraise | sort -u > wonder.out
clean:
	rm -f *.cm[ioxa] *.o *.cmxa *.run *opt *~
	rm -f *.out
