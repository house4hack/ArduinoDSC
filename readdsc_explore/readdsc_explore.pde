/*
  DigitalReadSerial
 Reads a digital input on pin 2, prints the result to the serial monitor 
 
 This example code is in the public domain.
 */

unsigned long lastread=0;
int datapin = 4;
int clockpin = 2;

#define databytes 8
int data[databytes];
int datavalue = 0;

int databuffer[databytes];
int bufferindex= 0;


int bitcounter = 0;
int dataindex = 0;

int dataread=0;
int lastdataread = 0;
int startbit = 1;
boolean ignorepadding = true;
boolean canprint =true;

int state=0;
int laststate=0;

void setup() {
  Serial.begin(115200);
  pinMode(datapin, INPUT);
  attachInterrupt(0, readbit, CHANGE);
  data[0] = 0;
}

void loop() {
    if(micros() - lastread >2000  && canprint) {

              for(int i=0; i<bufferindex; i++) {
                    Serial.print(databuffer[i], BIN);
                    Serial.print(" ");
              }
              Serial.println();      
              canprint = false;    
    
    }  
}


void readbit(){

  detachInterrupt(0); 
  int clkstate = digitalRead(clockpin);
  delayMicroseconds(10);
  if(clkstate == digitalRead(clockpin)) { // watch for noise
    
      unsigned long changemicros = micros();
      if(changemicros - lastread > 3000) {  // RESET occurred
             
          bufferindex = dataindex;
          for(int i=0; i<=bufferindex; i++){
               databuffer[i] = data[i]; 
          }
          canprint = true;           
          
          dataindex = 0;
          data[dataindex] = 0;
          datavalue = 0;
          bitcounter = 0;
          startbit = 1;
          ignorepadding = true;

       } 
    
       
       delayMicroseconds(100); // centre reading
       
       
         
       if(clkstate == LOW) {
            if(!startbit){
              if(dataindex != 1 || bitcounter!=0 || !ignorepadding){
                data[dataindex] |= datavalue << (7-bitcounter);
                datavalue = 0;
      
                bitcounter++;
                if(bitcounter==8){
                     dataindex++;
                     data[dataindex] = 0;  
                     bitcounter = 0;
                }
              } else {
                ignorepadding = false;
              }    
 
            } else {
              startbit -= 1; //eat startbits
              datavalue = 0;
            }   
            
       } else {    
           datavalue = digitalRead(datapin);
       }

    
       lastread = micros();
  }     
 attachInterrupt(0, readbit, CHANGE);
}






