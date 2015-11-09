.PHONY: all clean
APP:=oiuc
APP_SRCS:=oiuc.c

C_DIR:=../common
C_SRCS:=ansi-utils.c

USERVER_DIR:=../userver

PROTOCOL_DIR:=../group-man/protocols
GM_P:=gm-proto.u
GMC_P:=gmc-proto.u
ADV_P:=adv-proto.u
GB_P:=gb-proto.u

NODE_DIR:=../group-man
NODE_SRCS:=node.c gb-receiver.c

ICS_DIR:=../ics
ICS_SRCS:=ics.c ics-event.c ics-command.c

Q_DIR:=../concurrent_queue
Q_SRCS:=queue.c

O_DIR:=../object-pool
O_SRCS:=object-pool.c

GEN_DIR:=gen
GEN_SRCS:=gm-client.c gmc-server.c adv-server.c gb-server.c

JSONC_DIR:=../json-c/output

CFLAGS:=$(shell pkg-config --cflags libpjproject) -fms-extensions
CFLAGS+=-I$(ICS_DIR)/include -I$(Q_DIR)/include -I$(O_DIR)/include
CFLAGS+=-I$(C_DIR)/include
CFLAGS+=-I../json-c/output/include/json-c
CFLAGS+=-I$(PROTOCOLS_DIR)/include
CFLAGS+=-I$(GEN_DIR)
CFLAGS+=-I$(NODE_DIR)/include
CFLAGS+=-D__ICS_INTEL__

LIBS:= $(shell pkg-config --libs libpjproject) $(JSONC_DIR)/lib/libjson-c.a -lpthread

all: gen-gm gen-gmc gen-adv gen-gb  $(APP)

gen-gm: $(PROTOCOL_DIR)/$(GM_P)
	mkdir -p gen
	awk -f $(USERVER_DIR)/gen-tools/gen.awk $<
	touch $@

gen-gmc: $(PROTOCOL_DIR)/$(GMC_P)
	mkdir -p gen
	awk -f $(USERVER_DIR)/gen-tools/gen.awk $<
	touch $@

gen-adv: $(PROTOCOL_DIR)/$(ADV_P)
	mkdir -p gen
	awk -f $(USERVER_DIR)/gen-tools/gen.awk $<
	touch $@

gen-gb: $(PROTOCOL_DIR)/$(GB_P)
	mkdir -p gen
	awk -f $(USERVER_DIR)/gen-tools/gen.awk $<
	touch $@

$(APP): $(NODE_SRCS:.c=.o) $(GEN_SRCS:.c=.o) $(C_SRCS:.c=.o) $(APP_SRCS:.c=.o) $(ICS_SRCS:.c=.o) $(O_SRCS:.c=.o) $(Q_SRCS:.c=.o)
	gcc -o $@ $^ $(LIBS)

$(ICS_SRCS:.c=.o): %.o: $(ICS_DIR)/src/%.c
	gcc -c -o $@ $^ $(CFLAGS)
$(O_SRCS:.c=.o): %.o: $(O_DIR)/src/%.c
	gcc -c -o $@ $^ $(CFLAGS)
$(Q_SRCS:.c=.o): %.o: $(Q_DIR)/src/%.c
	gcc -c -o $@ $^ $(CFLAGS)
$(NODE_SRCS:.c=.o): %.o: $(NODE_DIR)/src/%.c
	gcc -c -o $@ $^ $(CFLAGS)
$(GEN_SRCS:.c=.o): %.o: $(GEN_DIR)/%.c
	gcc -c -o $@ $^ $(CFLAGS)
$(C_SRCS:.c=.o): %.o: $(C_DIR)/src/%.c
	gcc -c -o $@ $^ $(CFLAGS)
$(ANSI_O_SRCS:.c=.o): %.o: $(ANSI_O_DIR)/src/%.c
	gcc -c -o $@ $^ $(CFLAGS)
$(APP_SRCS:.c=.o): %.o: src/%.c
	gcc -c -o $@ $^ $(CFLAGS)

clean:
	rm -fr *.o gen gen-gm gen-gmc gen-adv gen-gb $(APP)
