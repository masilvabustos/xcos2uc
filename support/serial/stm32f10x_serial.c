
#include "serial.h"


#include <stm32f10x_usart.h>
#include <stm32f10x_dma.h>


struct serial_device {
	USART_TypeDef* base_addr;
	DMA_TypeDef* tx_dma_channel, rx_dma_channel;
	int tx_xfer_complete_flag, rx_xfer_complete_flag;
};

static const struct serial_device COM[] = {{USART1, DMA1_Channel4, DMA1_Channel5, DMA1_FLAG_TC4, DMA1_FLAG_TC5}};

void stm32f10x_setup_serial_port_comm_parameters(struct serial_port *port, struct serial_comm_parameters params)
{
	USART_InitTypeDef init;
	USART_StructInit(&init);
	
	init.USART_BaudRate = params.baud_rate;
	
	switch (params.word_length) {
	case 8:
		if (params.parity == NONE){ 
			init.USART_WordLength = USART_WordLength_8b;
			port->mask = 0xff >> params.word_length;
		} else {
			init.USART_WordLength = USART_WordLength_9b;
			init.USART_Parity = (params.parity == EVEN) ? USART_Parity_Even : USART_Parity_Odd;
		}
		break;
	case 9:
		init.USART_WordLength = USART_WordLength_9b;
		break;
	default:
		break;
	}

	switch (params.stop_bits) {
	case _1_STOP_BIT:
		init.USART_StopBits = USART_StopBits_1;
		break;
	case _2_STOP_BITS:
		init.USART_StopBits = USART_StopBits_2;
		break;
	case _1_5_STOP_BITS:
		init.USART_StopBits = USART_StopBits_1_5;
		break;
	default:
		break;
	}
	
	USART_Init(DEV[port->device].base_addr, &init);
}

void stm32f10x_reset_serial_port(struct serial_port* port)
{
	USART_DeInit(DEV[port->device].base_addr);
}

void stm32f10x_wait_for_serial_tx(struct serial_port *port)
{
	if (port->tx_xfer_mode == XFER_MODE_SYNC)
		return;

	while(DMA_GetFlagStatus(DEV[port->device].tx_xfer_complete_flag) == RESET)
		;
}

void stm32f10x_serial_send(struct serial_port *port, char buffer[], unsigned size)
{
	switch(port->tx_xfer_mode) {
	case XFER_MODE_SYNC:
		char *ptr = &buffer[0];

		while (size--){
			while(USART_GetFlagStatus(DEV[port->device].base_addr, USART_FLAG_TE) == RESET)
				;
			USART_SendData(DEV[port->device].base_addr, *ptr++);
		}
		break;
			
	case XFER_MODE_ASYNC:

		DMA_InitTypeDef config;
		DMA_StructInit(&config);

		config.DMA_PeripheralBaseAddr = &DEV[port->device].base_addr->DR;
		config.DMA_DIR = DMA_DIR_PeripheralDST;	
		config.DMA_PeripheralInc = DMA_PeripheralInc_Disable;
		config.DMA_MemoryInc = DMA_MemoryInc_Enable;
		config.DMA_PeripheralDataSize = DMA_PeripheralDataSize_Word;
		config.DMA_MemoryDataSize = DMA_MemoryDataSize_Byte;
		
		config.DMA_MemoryBaseAddr = &buffer[0];
		config.DMA_BufferSize = size;
		
		DMA_Init(DEV[port->device].tx_dma_channel, &config);
		DMA_Cmd(DEV[port->device].tx_dma_channel, ENABLE);
		
		break;
	}
}
