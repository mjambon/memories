.PHONY: default all opt doc install uninstall clean
default: all opt
all:
	ocamlc -c memories.mli
	ocamlc -c memories.ml
	ocamlc -c remind.mli
	ocamlc -c remind.ml
opt:
	ocamlc -c memories.mli
	ocamlopt -c memories.ml
	ocamlc -c remind.mli
	ocamlopt -c remind.ml
doc:
	mkdir -p html
	ocamldoc -html -d html memories.mli
	ocamldoc -html -d html remind.mli
install:
	ocamlfind install memories META $$(ls *.mli *.cm[iox] *.o 2>/dev/null)
uninstall:
	ocamlfind remove memories
clean:
	rm -f *.cm[ioxa] *.o *.cmxa *~
	rm -rf html
