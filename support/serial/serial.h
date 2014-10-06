
#ifndef __serial_h_INCLUDED__
#define __serial_h_INCLUDED__

#include "platform.h"

#ifdef STM32F10x

struct serial_comm_parameters {
	int baud_rate;
	int word_length;
	enum serial_comm_parity {NONE, ODD, EVEN} parity;
	enum serial_comm_stop_bits {_1_STOP_BIT, _2_STOP_BITS, _1_5_STOP_BITS} stop_bits;
};

static const struct serial_comm_parameters default_serial_comm_parameters = {9600, 8, NONE, _1_STOP_BIT};

enum xfer_mode {
		XFER_MODE_SYNC	
#ifdef HAS_UART_DMA
		, XFER_MODE_ASYNC
#endif
} ;

typedef struct serial_port* serial_port_t;

#ifdef STM32F10x

struct USART_TypeDef;

void stm32f10x_set_serial_port_device(serial_port_t, USART_TypeDef*);
void stm32f10x_serial_send(serial_port_t, char[], unsigned);
void stm32f10x_wait_for_serial_tx(serial_port_t);

#endif


		


#endif
