
SUPPORT_DIR=../../

vpath stm32f10x_%.c $(SUPPORT_DIR)/stm32vldiscovery_package/Libraries/STM32F10x_StdPeriph_Driver/src

vpath misc.c $(SUPPORT_DIR)/stm32vldiscovery_package/Libraries/STM32F10x_StdPeriph_Driver/src

vpath core_cm3.c $(SUPPORT_DIR)/stm32vldiscovery_package/Libraries/CMSIS/CM3/CoreSupport

vpath system_stm32f10x.c $(SUPPORT_DIR)/stm32vldiscovery_package/Libraries/CMSIS/CM3/DeviceSupport/ST/STM32F10x

vpath startup_stm32f10x_%.s $(SUPPORT_DIR)/stm32vldiscovery_package/Libraries/CMSIS/CM3/DeviceSupport/ST/STM32F10x/startup/gcc_ride7

vpath STM32vldiscovery.c $(SUPPORT_DIR)/stm32vldiscovery_package/Utilities

INCLUDES += -I$(SUPPORT_DIR)/stm32vldiscovery_package/Libraries/STM32F10x_StdPeriph_Driver/inc -I$(SUPPORT_DIR)/stm32vldiscovery_package/Utilities -I$(SUPPORT_DIR)/stm32vldiscovery_package/Libraries/CMSIS/CM3/CoreSupport -I$(SUPPORT_DIR)/stm32vldiscovery_package/Libraries/CMSIS/CM3/DeviceSupport/ST/STM32F10x

startup_stm32f10x_%.o: startup_stm32f10x_%.s
	$(AS) $(ASFLAGS) -o $@ $^

FIRMWARE_OBJS=$(foreach subsys,adc bkp can cec crc dac dbgmcu dma exti flash fsmc gpio i2c iwdg pwr rcc rtc sdio spi tim usart wwdg, stm32f10x_$(subsys).o) STM32vldiscovery.o misc.o system_stm32f10x.o startup_stm32f10x_md_vl.o

CROSS_PREFIX=arm-none-eabi-
TOOLS_PATH=/opt/gcc-arm-none-eabi-4_8-2014q2/
TOOLS_VERSION=4.8.4

CC=$(CROSS_PREFIX)gcc
AS=$(CROSS_PREFIX)as

#copied from https://github.com/h0rr0rrdrag0n/stm32vldiscovery-linux-template/blob/master/Makefile

CFLAGS=-c -mcpu=cortex-m3 -mthumb -Wall -O0 -mapcs-frame -D__thumb2__=1
CFLAGS+=-msoft-float -gdwarf-2 -mno-sched-prolog -fno-hosted -mtune=cortex-m3
CFLAGS+=-march=armv7-m -mfix-cortex-m3-ldrd -ffunction-sections -fdata-sections
CFLAGS+=-I./cmsis -I./stm32_lib -I.
ASFLAGS=-mcpu=cortex-m3 -I./cmsis -I./stm32_lib -gdwarf-2 -gdwarf-2
#LDFLAGS+=-T"$(SUPPORT_DIR)/stm32vldiscovery_package/Project/Master Workspace/TrueSTUDIO/stm32_flash.ld" -Wl,--gc-sections -static
LDFLAGS+=-T"$$HOME/Proyectos/STM32Discovery/stm32f100_project/link.ld" -Wl,--gc-sections -static
CFLAGS+=$(INCLUDES)

LD=$(CROSS_PREFIX)gcc -nostdlib 

PROJECT_NAME=comm
PROJECT_OBJS=main.o stm32f10x_it.o
CFLAGS+=-Iinc

CFLAGS+=-DUSE_STDPERIPH_DRIVER -DSTM32F10X_MD_VL 
$(PROJECT_NAME).elf: $(PROJECT_OBJS) $(FIRMWARE_OBJS)
	$(LD) -o $@ $(LDFLAGS) $^ 

.PHONY: clean

clean:
	rm *.o -v