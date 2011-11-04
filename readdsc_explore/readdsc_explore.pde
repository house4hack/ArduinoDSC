unsigned long lastread=0;
int datapin = 4;   // 4 on the uno; 1 on the tiny
int clockpin = 2;  // 2 on the uno ; 2 on the tiny

#define databytes 14
int data[databytes];
int datavalue = 0;


int bitcounter = 0;
int dataindex = 0;

int dataread=0;
int lastdataread = 0;
int startbit = 1;
boolean canprint =false;
boolean ignorepadding = true;
unsigned long lastprint = 0;

#define rxPin 1
#define txPin 3

void setup()  {
  // define pin modes for tx, rx, led pins:
  Serial.begin(115200);
  pinMode(datapin, INPUT); 
  pinMode(clockpin, INPUT);

  attachInterrupt(0, readbit, CHANGE);
  data[0] = 0;
  lastread = micros();
  lastprint = millis();
}

void loop() {

    unsigned long now = micros(); 
    if((abs(now - lastread) >1000) && (abs(now - lastread) <10000) && canprint) {
              if(data[0]!= 0xA && data[0]!= 0x5 && data[0]!= 0){
                 for(int i=0; i<= dataindex; i++){  Serial.print(data[i], HEX); Serial.print(' '); }
                  Serial.println();
              }
              dataindex = 0;
              data[dataindex] = 0;
              datavalue = 0;
              bitcounter = 0;
              startbit = 1;
             ignorepadding = true;

              canprint = false; 
              
    
    } 
     
}


void readbit(){
  lastread = micros();
  int clkstate = digitalRead(clockpin);
  if(1==1 ) { // watch for noise
            
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

    
       
       canprint = true;
  }     
 

}






