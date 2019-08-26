#LEAN_DIR = # May be set here
LEAN_PATH = $(LEAN_DIR)/library:../n2o/src:./src:./sample-lean
export LEAN_PATH

LEAN = src/web/nitro/tags src/web/nitro/elements src/web/nitro/javascript src/web/nitro/proto
FLAGS = -g -Wall

LIBNITRO = libnitro.a
LIBN2O = ../n2o/libn2o.a

LIBS = -lwebsockets

SAMPLE = sample-lean/sample

$(LIBNITRO): $(addsuffix .o,$(LEAN))
	ar rvs $(LIBNITRO) $(addsuffix .o,$(LEAN))

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

# Build sample

define lean-olean
$(LEAN_DIR)/bin/lean --make $(1).lean

endef

define lean-compile
$(LEAN_DIR)/bin/lean -c $(1).cpp $(1).lean

endef

$(SAMPLE): $(LIBNITRO)
	$(call lean-compile,$(SAMPLE))
	$(call lean-olean,$(SAMPLE))
	$(LEAN_DIR)/bin/leanc $(FLAGS) $(SAMPLE).cpp $(LIBN2O) $(LIBNITRO) $(LIBS) -o $(SAMPLE)

sample: $(SAMPLE)

run: $(SAMPLE)
	./$(SAMPLE)
