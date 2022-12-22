# Uncomment the next line for a Raspberry Pi or other ARM based devices (Dont forget to comment out the other line)
# FROM arm32v7/ubuntu:22.04
FROM ubuntu:22.04 

ENV network_interface=eth0

RUN apt-get update && apt-get install -y \
        git \
        wget \
        autoconf \
        libtool \
        liblzma-dev \
        cmake \
        libdumbnet-dev \
        flex \
        g++ \
        libhwloc-dev \
        libluajit-5.1-dev \
        openssl \
        libssl-dev \
        libpcap0.8-dev \
        libpcre3-dev \
        pkg-config \
        zlib1g \
        zlib1g-dev

RUN mkdir /snort && \
        cd /snort && \
        wget -O snort3.tar.gz https://github.com/snort3/snort3/archive/refs/tags/3.1.50.0.tar.gz && \
        wget -O libdaq.tar.gz https://github.com/snort3/libdaq/archive/refs/tags/v3.0.10.tar.gz && \
        tar xvf libdaq.tar.gz && \
	    tar xvf snort3.tar.gz

ENV my_path=/usr/local

RUN cd /snort/libdaq-3.0.10 && \
        ./bootstrap && \
        ./configure --prefix=$my_path/lib/daq_s3 && \
        make && \
        make install && \
        ldconfig

RUN cd /snort/snort3-3.1.50.0 && \
        ./configure_cmake.sh --prefix=/usr/local \
	                --with-daq-includes=$my_path/lib/daq_s3/include/ \
                    --with-daq-libraries=$my_path/lib/daq_s3/lib/ && \
        cd build && \
        make -j $(nproc) && \
        make install && \
        ldconfig

#ENTRYPOINT ["$my_path/bin/snort", "-q", "-c", "$my_path/lua/snort.lua", "--daq-dir", "$my_path/lib/daq_s3/lib/daq", "-i", "network_interface"]