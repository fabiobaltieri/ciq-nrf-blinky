SDK_PATH = $(HOME)/ciq
KEY = developer_key.der

NAME = nrf-blinky
APP_ID = 46af5ff7-b29c-4219-8ad7-a981d852a4c7

JUNGLE = monkey.jungle
ifeq ($(DEVICE),)
DEVICE = fr955
endif

MONKEYC = $(SDK_PATH)/bin/monkeyc
MONKEYDO = $(SDK_PATH)/bin/monkeydo

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
	$(MONKEYC) -e -f $(JUNGLE) -o $(PWD)/$(NAME).iq -y $(KEY)

sim: $(NAME).prg
	$(MONKEYDO) $(NAME).prg $(DEVICE)

graph:
	java -jar $(SDK_PATH)/bin/fit-graph.jar

era:
	$(SDK_PATH)/bin/era -k $(KEY) -a $(APP_ID)

flash:
	nrfjprog --eraseall
	nrfjprog --program $(SDK_PATH)/connectivity_2.0.1_115k2_with_s132_5.0.hex
	nrfjprog --reset
