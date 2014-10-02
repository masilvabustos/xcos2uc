
vpath stm32f10x_%.c $(STM32VLDISCOVERY_PACKAGE_DIR)/Libraries/STM32F10x_StdPeriph_Driver/src

vpath misc.c $(STM32VLDISCOVERY_PACKAGE_DIR)/Libraries/STM32F10x_StdPeriph_Driver/src

vpath core_cm3.c $(STM32VLDISCOVERY_PACKAGE_DIR)/Libraries/CMSIS/CM3/CoreSupport

vpath system_stm32f10x.c $(STM32VLDISCOVERY_PACKAGE_DIR)/Libraries/CMSIS/CM3/DeviceSupport/ST/STM32F10x

vpath startup_stm32f10x_%.s $(STM32VLDISCOVERY_PACKAGE_DIR)/Libraries/CMSIS/CM3/DeviceSupport/ST/STM32F10x/startup/gcc_ride7

vpath STM32vldiscovery.c $(STM32VLDISCOVERY_PACKAGE_DIR)/Utilities

INCLUDES += -I$(STM32VLDISCOVERY_PACKAGE_DIR)/Libraries/STM32F10x_StdPeriph_Driver/inc \
	-I$(STM32VLDISCOVERY_PACKAGE_DIR)/Utilities \
	-I$(STM32VLDISCOVERY_PACKAGE_DIR)/Libraries/CMSIS/CM3/CoreSupport \
	-I$(STM32VLDISCOVERY_PACKAGE_DIR)/Libraries/CMSIS/CM3/DeviceSupport/ST/STM32F10x

startup_stm32f10x_%.o: startup_stm32f10x_%.s
	$(AS) $(ASFLAGS) -o $@ $^

FIRMWARE_OBJS=$(foreach driver, $(DRIVERS), stm32f10x_$(driver).o) STM32vldiscovery.o misc.o system_stm32f10x.o startup_stm32f10x_md_vl.o

CROSS_PREFIX=arm-none-eabi

CC=$(CROSS_PREFIX)-gcc
AS=$(CROSS_PREFIX)-as
LD=$(CROSS_PREFIX)-gcc -nostdlib 

#copied from https://github.com/h0rr0rrdrag0n/stm32vldiscovery-linux-template/blob/master/Makefile

CFLAGS+=-c -mcpu=cortex-m3 -mthumb -O0 -mapcs-frame -D__thumb2__=1
CFLAGS+=-msoft-float -gdwarf-2 -mno-sched-prolog -fno-hosted -mtune=cortex-m3
CFLAGS+=-march=armv7-m -mfix-cortex-m3-ldrd -ffunction-sections -fdata-sections
CFLAGS+=-I./cmsis -I./stm32_lib -I.
ASFLAGS+=-mcpu=cortex-m3 -gdwarf-2 -gdwarf-2
LDFLAGS+=-T"$(STM32VLDISCOVERY_PACKAGE_DIR)/Projects/link.ld" -Wl,--gc-sections -static
CFLAGS+=$(INCLUDES)

CFLAGS+=-DUSE_STDPERIPH_DRIVER -DSTM32F10X_MD_VL 

firmware: $(FIRMWARE_OBJS)

.PHONY: clean print-drivers firmware

clean:
	rm *.o -v

print-drivers:
	@echo adc bkp can cec crc dac dbgmcu dma exti flash fsmc gpio i2c iwdg pwr rcc rtc sdio spi tim usart wwdg