#include <string>
#include <sstream>
#include <cstdlib>
#include <cstdio>
#include <iostream>
#include <stdio.h>
#include <cstring>
#include <iostream>
#include <fstream>
#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <unistd.h>
#include <string>
#include <vector>
#include <sstream>
#include <bitset>
#include <time.h>
#include <sys/time.h>
#include <sys/types.h>       // For data types
#include <sys/socket.h>      // For socket(), connect(), send(), and recv()
#include <poll.h>   

//Subsystem client
#include <sclient.h>

using namespace std;

class CooliHandler
{
	private:
		sclient subsys;
		
		struct cooliMessage{
			int timeStamp;
			string command;
			string value;
		};
		
		struct cooliMessage get_status_message();
		struct cooliMessage formatMessage(packet_t data);
		
	public:
		CooliHandler();
		~CooliHandler();
		
		int setTemperature(string nominalTemperature);
		double getTemperature();
		bool isReady(string nominalTemperature);
};
