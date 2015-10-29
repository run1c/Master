## Compiler...
MCU=atmega88pa
OBJ=m88pa_usart.o m88pa_timer.o m88pa_adc.o m88pa_spi.o
BIN=mppc_d
## Default frontend address, has to be passed by commandline argument
ADDR=0x10
PROG=stk500 # avrispmkii
PORT=/dev/cu.usbmodem1421 # usb

SRC=./src/
INC=./inc/

all: 	
	@echo "\n>>> Compiling firmware for MPPC D board address '$(ADDR)' <<< \n"
	@make $(BIN).elf 
	@make $(BIN).eep


$(BIN).o: $(BIN).c
	avr-gcc -O2 -mmcu=$(MCU) -D MODULE_NO=$(ADDR) $^ -c -I$(INC)

%.o: $(SRC)%.c
	avr-gcc -O2 -mmcu=$(MCU) -D MODULE_NO=$(ADDR) $^ -c -I$(INC)

%.elf: $(BIN).o $(OBJ)
	avr-gcc -O2 -mmcu=$(MCU) $^ -o $@ 
	avr-objcopy -O ihex -j .text -j .data $(BIN).elf $(BIN).hex

%.eep: %.elf
	avr-objcopy -j .eeprom --set-section-flags .eeprom="alloc,load" --change-section-lma .eeprom=0 -O ihex $< $@

fuse:
	avrdude -p m88p -P $(PORT) -c $(PROG) -U lfuse:w:0x62:m #hfuse:w:0xDF:m
	## Clock must be set 1 MHz for correct serial communication @9600BAUS -> lfuse=0x62

program: $(BIN).hex
	@echo "> Transfer firmware '$<' to controller:" 
	@echo "\tEEPROM will be erased! FE address and calibration results"
	@echo "\thave to be transferred again using 'make eeprom'.\n"
	avrdude -p m88p -P $(PORT) -c $(PROG) -U flash:w:$(BIN).hex

eeprom: $(BIN).eep
	@echo "> Transfer eeprom '$<' to controller:"
	@echo "\tFE address and calibration results are stored in the EEPROM.\n" 
	avrdude -p m88p -P $(PORT) -c $(PROG) -U eeprom:w:$(BIN).eep

read:
	avrdude -p m88p -P $(PORT) -c $(PROG) -U lfuse:r:-:h -U hfuse:r:-:h -U efuse:r:-:h -U lock:r:-:h

clean: 
	rm -rf *.o
	rm -rf $(OBJ) 
	rm -rf $(BIN).elf 
	rm -rf $(BIN).hex 
	rm -rf $(BIN).eep 
