
#ifndef __HIL_proto_h_INCLUDED__
#define __HIL_proto_h_INCLUDED__

struct std_message {
	unsigned char channel;
	unsigned tick_count;
	float value;
};

struct control_message {
	enum {
		NOP
	} command;
	char data[];
};

struct status_message {
	float window_pos;
	float estimated_error;
};
	
	
	
#endif
