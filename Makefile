.PHONY: default all opt doc clean
default: all opt
all:
	ocamlc -c memories.mli
	ocamlc -c memories.ml
opt:
	ocamlc -c memories.mli
	ocamlopt -c memories.ml
doc:
	mkdir -p html
	ocamldoc -html -d html memories.mli
clean:
	rm -f *.cm[ioxa] *.o *.cmxa *~
	rm -rf html
