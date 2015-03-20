
#include <termios.h>
#include <unistd.h>
#include <fcntl.h>
#include <stdio.h>
#include <stdlib.h>
#include <strings.h>
#include <signal.h>

#include "../HIL-proto/HIL-proto.h"

struct termios old_termios;
int serialfd;

void cleanup(void)
{
	printf("cleaning up...\n");
	if (tcsetattr(serialfd, TCSANOW,  &old_termios) == -1)
		perror("tsetattr");
	close(serialfd);
}

void int_handler(int sig)
{
	exit(0);
}

int main()
{
	struct termios termios_s;
	char c;

	serialfd = open("/dev/ttyUSB0", O_NOCTTY);

	if (serialfd == -1) {
		perror("invalid file");
		exit(1);
	}
	atexit(cleanup);
	signal(SIGINT, int_handler);
	tcgetattr(serialfd, &termios_s);
	tcgetattr(serialfd, &old_termios);

	cfmakeraw(&termios_s);
	cfsetispeed(&termios_s, B9600);
	termios_s.c_cflag |= CLOCAL | CREAD;
	termios_s.c_cc[VTIME] = 0;
	termios_s.c_cc[VMIN] = 1;
	tcflush(serialfd, TCIFLUSH);
	tcsetattr(serialfd, TCSANOW, &termios_s);
	
	while(1){
		struct status_message m;
		read(serialfd, &m, sizeof(m));
		printf("read: %f %f\n", m.window_pos, m.estimated_error);
		//putchar(c);
	}
	
	return 0;
}
