SRCS = $(wildcard *.svg)
TARGETS = ${SRCS:.svg=.png}

all: $(TARGETS)

%.png: %.svg
	convert $< $@

clean:
	-rm $(TARGETS) *~

