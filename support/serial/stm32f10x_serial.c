
#include "serial.h"


void stm32f10x_set_serial_port_device(struct serial_port *port, USART_TypeDef* device)
{
	port->device = device;
	switch(device){
	case USART1:
		port->tx_dma_channel = DMA1_Channel4;
		port->rx_dma_channel = DMA1_Channel5;
		port->tx_xfer_complete_flag = DMA1_FLAG_TC4;
		port->rx_xfer_complete_flag = DMA1_FLAG_TC5;
		break;
	}

};

void stm32f10x_reset_serial_port(struct serial_port* port)
{
	USART_DeInit(port->device);
}
void stm32f10x_wait_for_serial_tx(struct serial_port *port)
{
	if (port->tx_xfer_mode == XFER_MODE_SYNC)
		return;

	while(DMA_GetFlagStatus(port->tx_xfer_complete_flag) == RESET)
		;
}

void stm32f10x_serial_send(struct serial_port *port, char buffer[], unsigned size)
{
	switch(port->tx_xfer_mode) {
	case XFER_MODE_SYNC:
		char *ptr = &buffer[0];

		while (size--){
			while(USART_GetFlagStatus(port->base_addr, USART_FLAG_TE) == RESET)
				;
			USART_SendData(port->base_addr, *ptr++);
		}
		break;
			
	case XFER_MODE_ASYNC:

		DMA_InitTypeDef config;
		DMA_StructInit(&config);

		config.DMA_PeripheralBaseAddr = &port->base_addr->DR;
		config.DMA_DIR = DMA_DIR_PeripheralDST;	
		config.DMA_PeripheralInc = DMA_PeripheralInc_Disable;
		config.DMA_MemoryInc = DMA_MemoryInc_Enable;
		config.DMA_PeripheralDataSize = DMA_PeripheralDataSize_Word;
		config.DMA_MemoryDataSize = DMA_MemoryDataSize_Byte;
		
		config.DMA_MemoryBaseAddr = &buffer[0];
		config.DMA_BufferSize = size;
		
		DMA_Init(port->tx_dma_channel, &config);
		DMA_Cmd(port->tx_dma_channel, ENABLE);
		
		break;
	}
}
