#include "CooliHandler.h"


using namespace std;

CooliHandler::CooliHandler(){
	subsys.setid("Client");
	subsys.supply("/cooli2/control");
}

CooliHandler::~CooliHandler(){
	subsys.unsupply("/cooli2/control");
	subsys.terminate();
}

struct CooliHandler::cooliMessage CooliHandler::get_status_message(){
	struct pollfd poll_fd[1];
	poll_fd[0].events = POLLIN;
	poll_fd[0].fd = subsys.getfd();
	
	packet_t packet;
	subsys.subscribe("/cooli2/status");
	while(true){
		if(poll(poll_fd,1,100)>0){	// 100 -> reviece_timeout
			subsys.recvpacket(packet);
			cooliMessage lastMessage = formatMessage(packet);
			subsys.unsubscribe("/cooli2/status");
			return lastMessage;
		}
	}
}

struct CooliHandler::cooliMessage CooliHandler::formatMessage(packet_t data){
	cooliMessage ret;
	
	string rxtext(data.data());
	size_t blank1 = rxtext.find(" ");
	string timestamp = rxtext.substr(0,blank1);
	ret.timeStamp = strtod(timestamp.c_str(),NULL);
	size_t blank2 = rxtext.find(" ",blank1+1);
	ret.command = rxtext.substr(blank1+1,blank2-blank1-1);
	size_t endofline = rxtext.find("\n",blank2+1);
	ret.value = rxtext.substr(blank2+1, endofline-blank2-1);
	
	return ret;
}

int CooliHandler::setTemperature(string nominalTemperature){
	while(true){
		cooliMessage tempCM = get_status_message();
		if(tempCM.command == "NominalTemperature"){
			if (strtod(nominalTemperature.c_str(),NULL) == strtod(tempCM.value.c_str(),NULL)){
				return 0;
			} else {
				string setTempCommand = "NOMINAL_TEMPERATURE "+nominalTemperature+"\n";
				subsys.aprintf("/cooli2/control", setTempCommand.c_str());
				sleep(10);
			}
		}
	}
}

double CooliHandler::getTemperature(){
	cooliMessage tempCM;
	double ret_val;
	while (true){
		tempCM = get_status_message();
		if (tempCM.command == "RegulatedTemperature"){
			ret_val = strtod(tempCM.value.c_str(), NULL);
			break;
		}
	}
	return ret_val;
}

bool CooliHandler::isReady(string nominalTemperature){
	bool cooliRightNomTemp = false;
	bool cooliTempStable = false;
	bool cooliTempAtNom = false;
	bool recvdNomTemp = false;
	bool recvdTempStable = false;
	bool recvdTempAtNom = false;
	
	while(!( recvdNomTemp && recvdTempStable && recvdTempAtNom )){
		cooliMessage tempCM = get_status_message();
		if(tempCM.command == "NominalTemperature"){
			recvdNomTemp = true;
			if (strtod(nominalTemperature.c_str(),NULL) == strtod(tempCM.value.c_str(),NULL)){
				cooliRightNomTemp = true;
			} else {
				setTemperature(nominalTemperature);
			}
		} else if (tempCM.command == "TemperatureAtNominal"){
			recvdTempAtNom = true;
			if (tempCM.value == "YES") cooliTempAtNom = true;
		} else if (tempCM.command == "TemperatureStable"){
			recvdTempStable = true;
			if(tempCM.value == "YES") cooliTempStable = true;
		}
	}
	
	if (cooliRightNomTemp && cooliTempStable && cooliTempAtNom) return true;
	return false;
}
