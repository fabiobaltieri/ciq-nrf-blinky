SDK_PATH = $(HOME)/ciq/bin
KEY = $(HOME)/ciq/key/developer_key.der

NAME = nrf-blinky

JUNGLE = monkey.jungle
ifeq ($(DEVICE),)
DEVICE = fr245
endif

MONKEYC = $(SDK_PATH)/monkeyc
MONKEYDO = $(SDK_PATH)/monkeydo

.PHONY: all clean sim graph

all: $(NAME).prg

clean:
	rm -f $(NAME)-fit_contributions.json
	rm -f $(NAME)-settings.json
	rm -f $(NAME).iq
	rm -f $(NAME).prg
	rm -f $(NAME).prg.debug.xml

$(NAME).prg: manifest.xml resources/*.xml source/*.mc
	$(MONKEYC) -d $(DEVICE) -f $(JUNGLE) -o $(NAME).prg -y $(KEY)

$(NAME).iq: manifest.xml resources/*.xml source/*.mc
	$(MONKEYC) -e -f $(JUNGLE) -o $(NAME).iq -y $(KEY)

sim: $(NAME).prg
	$(MONKEYDO) $(NAME).prg $(DEVICE)

graph:
	java -jar $(SDK_PATH)/fit-graph.jar
