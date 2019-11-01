#include<stdio.h>
#include<stdlib.h>

#include</usr/local/include/battery.h>
#include</usr/local/include/brightness.h>
//#include</usr/local/include/cpu.h>


int battery_mon(){

  FILE *fptr;
  char ch;
  char che[10];
  int battery_capacity;
  int battery_level;

  fptr = fopen(POWERSTATE, "r");
  if (fptr == NULL){
    printf("Cannot open file\n");
    exit(0);
  }
  ch = fgetc(fptr);

  printf("Power state: ");
  while (ch != EOF)
  {
    printf("%c", ch);
    ch = fgetc(fptr);    
  }
  fclose(fptr);

  /*------------------------------*/

  fptr = fopen(BATTERYCAPACITY, "r");
  if (fptr == NULL){
    printf("Cannot open file\n");
    exit(0);
  }
//  ch = fgetc(fptr);

  while (fgets(che, sizeof(che), fptr) != NULL)
  {
//    fputs(che, stdout);
  }
  fclose(fptr);
  battery_capacity = atoi(che);
  printf("Battery capacity: %d\n", battery_capacity);
  
  /*------------------------------*/

  fptr = fopen(BATTERYLEVEL, "r");
  if (fptr == NULL){
    printf("Cannot open file\n");
    exit(0);
  }
//  ch = fgetc(fptr);

  while (fgets(che, sizeof(che), fptr) != NULL)
  {
//    fputs(che, stdout);
  }
  fclose(fptr);
  battery_level = atoi(che);
  printf("Battery level: %d\n", battery_level);
  printf("Level: %0.2f%\n", ((float)battery_level/battery_capacity) * 100);


  return 0;
}

int brightness_mon(){
  
  FILE *fptr;
  char ch;
  char che[10];
  int brightness_max;
  int brightness_level;

  /*------------------------------*/

  fptr = fopen(BACKLIGHT_SOURCE"/max_brightness", "r");
  if (fptr == NULL){
    printf("Cannot open file\n");
    exit(0);
  }

  while (fgets(che, sizeof(che), fptr) != NULL)
  {
//    fputs(che, stdout);
  }

  fclose(fptr);
  brightness_max = atoi(che);

  fptr = fopen(BACKLIGHT_SOURCE"/brightness", "r");
  if (fptr == NULL){
    printf("Cannot open file\n");
    exit(0);
  }

  while (fgets(che, sizeof(che), fptr) != NULL)
  {
//    fputs(che, stdout);
  }
  fclose(fptr);
  brightness_level = atoi(che);
 

  printf("Brightness: %0.2f%\n", ((float)brightness_level/brightness_max) * 100);
  
  /*------------------------------*/


  return 0;
}

int cpu_mon(){
//echo "Thermal zone0: $(cat /sys/devices/virtual/thermal/thermal_zone0/temp | awk "$AWKCMD")"
//for i in {1..5}; do
//  echo -n "$(cat $HWMON/coretemp.0/hwmon/hwmon1/temp$i\_label) - "
//  cat $HWMON/coretemp.0/hwmon/hwmon1/temp$i\_input | awk "$AWKCMD"
//done
  FILE *fptr;
  char ch;
  char che[10];
  int fan_rpm;

  /*------------------------------*/

  fptr = fopen("/sys/devices/virtual/hwmon/hwmon0/fan1_input", "r");
  if (fptr == NULL){
    printf("Cannot open file\n");
    exit(0);
  }

  while (fgets(che, sizeof(che), fptr) != NULL)
  {
//    fputs(che, stdout);
  }

  fclose(fptr);
  fan_rpm = atoi(che);



  printf("FAN rpm: %d\n", fan_rpm);
 
}

int main(){
  FILE *fptr;
  char filename[15];
  char ch;

  cpu_mon();
  brightness_mon();
  battery_mon();

  return 0;
}
