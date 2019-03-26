FROM centos:7

RUN yum -y install git wget

RUN git clone https://github.com/baberlevi/Repetier-Firmware-4-Davinci.git

RUN wget https://github.com/arduino/Arduino/archive/1.8.0.tar.gz
# https://www.arduino.cc/download_handler.php?f=/arduino-1.8.1-linux64.tar.xz
# incase the precompiled disto disappears from main site, try these
# https://github.com/arduino/Arduino.git
# https://github.com/arduino/Arduino/archive/1.8.0.tar.gz

RUN tar xzvf 1.8.0.tar.gz

# download DUE board support
RUN /Arduino-1.8.0/arduino --install-boards arduino:sam:1.6.8

# copy these two files into arduino profile dir
RUN cp /Repetier-Firmware-4-Davinci/src/ArduinoDUE/AdditionalArduinoFiles/Arduino\ -\ 1.8.0\ -Due\ 1.6.8/Arduino15/packages/arduino/hardware/sam/1.6.8/variants/arduino_due_x/variant.cpp ~/.arduino15/packages/arduino/hardware/sam/1.6.8/variants/arduino_due_x/
RUN cp /Repetier-Firmware-4-Davinci/src/ArduinoDUE/AdditionalArduinoFiles/Arduino\ -\ 1.8.0\ -Due\ 1.6.8/Arduino15/packages/arduino/hardware/sam/1.6.8/cores/arduino/USB/USBCore.cpp ~/.arduino15/packages/arduino/hardware/sam/1.6.8/cores/arduino/USB/

# compile
MKDIR /build
RUN /Arduino-1.8.0/arduino \
--board arduino:sam:due:cpu=atmega168 \
--pref build.path=/build \
--verify /Repetier-Firmware-4-Davinci/src/ArduinoDUE/Repetier/Repetier.ino

# to upload
CMD ["xhost", "si:localuser:root"]

# then use the gui to upload

# or do something like
# RUN /Arduino-1.8.0/arduino \
--board arduino:avr:sam:due=armcortexm3 \
--pref build.path=/build \
--port /dev/ttyACM0 \
--upload /Repetier-Firmware-4-Davinci/src/ArduinoDUE/Repetier/Repetier.ino

