
#ifndef __serial_h_INCLUDED__
#define __serial_h_INCLUDED__

#include "platform.h"

struct serial_comm_parameters {
	int baud_rate;
	int word_length;
	enum serial_comm_parity {NONE, ODD, EVEN} parity;
	enum serial_comm_stop_bits {_1_STOP_BIT, _2_STOP_BITS, _1_5_STOP_BITS} stop_bits;
};

static const struct serial_comm_parameters default_serial_comm_parameters = {9600, 8, NONE, _1_STOP_BIT};

enum xfer_mode {
		SYNC	
#ifdef HAS_UART_DMA
		, ASYNC
#endif
} ;

struct serial_port {
        unsigned device;
	enum xfer_mode tx_xfer_mode, rx_xfer_mode;
	uint8_t mask;

};

typedef struct serial_port* serial_port_t;

#ifdef STM32F10x

void stm32_f10x_reset_serial_port(struct serial_port*);
void stm32f10x_setup_serial_port_comm_parameters(struct serial_port*, struct serial_comm_parameters);
void stm32f10x_serial_send(struct serial_port*, char[], unsigned);
void stm32f10x_wait_for_serial_tx(serial_port_t);

#define reset_serial_port stm32f10x_reset_serial_port
#define setup_serial_port_comm_parameters stm3232f10x_setup_serial_port_comm_parameters
#define serial_send  stm32f10x_serial_send
#define wait_for_serial_tx stm32f10x_wait_for_serial_tx

#endif


		


#endif
