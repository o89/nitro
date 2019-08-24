#LEAN_DIR = # May be set here
LEAN_PATH = $(LEAN_DIR)/library:../n2o/src:./src
export LEAN_PATH

LEAN = src/web/nitro/tags
FLAGS = -g -Wall

LIBNAME = libnitro.a

LIBS = -lwebsockets

SAMPLE = sample-lean/sample

$(LIBNAME): $(addsuffix .o,$(LEAN))
	ar rvs $(LIBNAME) $(addsuffix .o,$(LEAN))

%.o: %.cpp
	$(LEAN_DIR)/bin/leanc $(FLAGS) -c $< -o $@

$(addsuffix .cpp,$(LEAN)): %.cpp: %.olean
	$(LEAN_DIR)/bin/lean -c $@ $(<:.olean=.lean)

$(addsuffix .olean,$(LEAN)): %.olean: %.lean
	$(LEAN_DIR)/bin/lean --make $<

clean:
	rm -f $(addsuffix .cpp,$(LEAN))
	rm -f $(addsuffix .olean,$(LEAN))
	rm -f $(addsuffix .o,$(LEAN))
