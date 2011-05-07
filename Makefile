.PHONY: default all opt doc install uninstall clean
default: all opt
all:
	ocamlc -c memories.mli
	ocamlc -c memories.ml
	ocamlc -c remind.mli
	ocamlc -c remind.ml
	ocamlc -a -o memories.cma memories.cmo remind.cmo
opt:
	ocamlc -c memories.mli
	ocamlopt -c memories.ml
	ocamlc -c remind.mli
	ocamlopt -c remind.ml
	ocamlopt -a -o memories.cmxa memories.cmx remind.cmx
doc:
	mkdir -p html
	ocamldoc -html -d html memories.mli
	ocamldoc -html -d html remind.mli
install:
	ocamlfind install memories META \
		$$(ls *.mli *.cm[ioxa] *.cmxa *.o *.a 2>/dev/null)
uninstall:
	ocamlfind remove memories
clean:
	rm -f *.cm[ioxa] *.o *.cmxa *~
	rm -rf html
	cd topfraise; $(MAKE) clean
