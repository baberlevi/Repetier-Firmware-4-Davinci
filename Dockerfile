FROM centos:7

# dependencies
RUN yum -y install git wget ant gcc java-1.8.0-openjdk java-1.8.0-openjdk-devel java-1.8.0-openjdk-headless xz-lzma-compad make bzip2

# get printer firmware and checkout branch with bowden modifications
RUN git clone https://github.com/baberlevi/Repetier-Firmware-4-Davinci.git
WORKDIR /Repetier-Firmware-4-Davinci
RUN git checkout march2019_bowden
WORKDIR /

# takes forever to build arduino from source, just download binary and copy into the container
# can't find direct url for download, tries to route through donate
COPY arduino-1.8.0-linux64.tar.xz /
RUN tar xvf arduino-1.8.0-linux64.tar.xz

# download arduino-cli
RUN wget https://github.com/arduino/arduino-cli/releases/download/0.3.6-alpha.preview/arduino-cli-0.3.6-alpha.preview-linux64.tar.bz2
RUN tar jxvf arduino-cli-0.3.6-alpha.preview-linux64.tar.bz2
RUN mv arduino-cli-0.3.6-alpha.preview-linux64 arduino-cli
#needed to work around: https://github.com/arduino/arduino-cli/issues/133
ENV USER root 

# download DUE board support
RUN /arduino-cli core update-index
RUN /arduino-cli core install arduino:sam@1.6.8

# copy these two files into arduino profile dir
RUN cp /Repetier-Firmware-4-Davinci/src/ArduinoDUE/AdditionalArduinoFiles/Arduino\ -\ 1.8.0\ -Due\ 1.6.8/Arduino15/packages/arduino/hardware/sam/1.6.8/variants/arduino_due_x/variant.cpp ~/.arduino15/packages/arduino/hardware/sam/1.6.8/variants/arduino_due_x/
RUN cp /Repetier-Firmware-4-Davinci/src/ArduinoDUE/AdditionalArduinoFiles/Arduino\ -\ 1.8.0\ -Due\ 1.6.8/Arduino15/packages/arduino/hardware/sam/1.6.8/cores/arduino/USB/USBCore.cpp ~/.arduino15/packages/arduino/hardware/sam/1.6.8/cores/arduino/USB/

# compile davinci repetier firmware
RUN /arduino-cli compile --fqbn arduino:sam:arduino_due_x /Repetier-Firmware-4-Davinci/src/ArduinoDUE/Repetier/

# to upload (to run after container is built and you're connected to the printer)
CMD ["/arduino-cli", "upload", "-p", "/dev/ttyACM0", "--fqbn", "arduino:sam:arduino_due_x", "/Repetier-Firmware-4-Davinci/src/ArduinoDUE/Repetier/Repetier.ino"
