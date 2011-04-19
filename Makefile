.PHONY: default all opt doc install uninstall clean
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
install:
	ocamlfind install memories META $$(ls *.mli *.cm[iox] *.o 2>/dev/null)
uninstall:
	ocamlfind remove memories
clean:
	rm -f *.cm[ioxa] *.o *.cmxa *~
	rm -rf html
