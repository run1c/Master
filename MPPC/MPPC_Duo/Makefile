MCU=atmega88pa
OBJ=m88pa_usart.o m88pa_timer.o m88pa_adc.o m88pa_spi.o
BIN=mppc_d

SRC=./src/
INC=./inc/

FE_ADDR=0x21

all: $(BIN).elf

$(BIN).o: $(BIN).c
	avr-gcc -O2 -mmcu=$(MCU) $^ -c -I$(INC)

%.o: $(SRC)%.c
	@echo Frontend board address $(FE_ADDR)
	avr-gcc -O2 -mmcu=$(MCU) -DMODULE_NO=$(FE_ADDR) $^ -c -I$(INC)

%.elf: $(BIN).o $(OBJ)
	avr-gcc -O2 -mmcu=$(MCU) $^ -o $@ 
	avr-objcopy -O ihex -j .text -j .data $(BIN).elf $(BIN).hex

%.eep: %.elf
	avr-objcopy -j .eeprom --set-section-flags .eeprom="alloc,load" --change-section-lma .eeprom=0 -O ihex $< $@

fuse:
	avrdude -p m88p -P usb -c avrispmkII -U hfuse:w:0xDF:m

program: $(BIN).hex
	avrdude -p m88p -P usb -c avrispmkII -U flash:w:$(BIN).hex

eeprom: $(BIN).eep
	avrdude -p m88p -P usb -c avrispmkII -U eeprom:w:$(BIN).eep

read:
	avrdude -p m88p -P usb -c avrispmkII -U lfuse:r:-:h -U hfuse:r:-:h -U efuse:r:-:h -U lock:r:-:h

clean: 
	rm -rf $(OBJ) 
	rm -rf $(BIN).elf 
	rm -rf $(BIN).hex 
	rm -rf $(BIN).eep 
