# Uncomment the next line for a Raspberry Pi or other ARM based devices (Dont forget to comment out the other line)
# FROM arm32v7/ubuntu:22.04
FROM ubuntu:22.04 

# Set up the environment variables
ENV my_path=/usr/local

# Install all the dependencies to build the tools
RUN apt-get update && apt-get install -y \
        git wget autoconf libtool liblzma-dev iproute2 \
        cmake libdumbnet-dev flex g++ libhwloc-dev \
        libluajit-5.1-dev openssl libssl-dev libpcap0.8-dev \
        libpcre3-dev pkg-config zlib1g zlib1g-dev \
        build-essential libnet1-dev luajit hwloc libdnet-dev \
        bison cpputest libsqlite3-dev uuid-dev \
        libcmocka-dev libnetfilter-queue-dev libmnl-dev \
        autotools-dev libunwind-dev libfl-dev

# Download and unzip all the tools that are meant to be built 
RUN mkdir /snort && \
        cd /snort && \
        wget -O snort3.tar.gz https://github.com/snort3/snort3/archive/refs/tags/3.1.50.0.tar.gz && \
        wget -O libdaq.tar.gz https://github.com/snort3/libdaq/archive/refs/tags/v3.0.10.tar.gz && \
        tar xvf libdaq.tar.gz && rm libdaq.tar.gz && \
        tar xvf snort3.tar.gz && rm snort3.tar.gz

# Build the tcmalloc tool to enchance performance at the cost of using more memory
# If running on a low memory device, comment out this block and the --enable-tcmalloc line 
RUN wget -O gperftools.tar.gz https://github.com/gperftools/gperftools/releases/download/gperftools-2.10/gperftools-2.10.tar.gz && \
        tar xvf gperftools.tar.gz && rm gperftools.tar.gz &&\
        cd gperftools-2.10 && \
        ./configure && \
        make && \
        make install && \
        ldconfig

# Build libdaq libraries
RUN cd /snort/libdaq-3.0.10 && \
        ./bootstrap && \
        ./configure --prefix=$my_path/lib/daq_s3 && \
        make && \
        make install && \
        ldconfig

# Build the snort3 application
RUN cd /snort/snort3-3.1.50.0 && \
        ./configure_cmake.sh --prefix=$my_path \
                        --enable-tcmalloc \
                        --with-daq-includes=$my_path/lib/daq_s3/include/ \
                        --with-daq-libraries=$my_path/lib/daq_s3/lib/ && \
        cd build && \
        make -j $(nproc) && \
        make install && \
        ldconfig

# Fix for "/usr/local/bin/snort: error while loading shared libraries: libdaq.so.3: cannot open shared object file: No such file or directory"
RUN ln -s /usr/local/lib/daq_s3/lib/libdaq.so.3 /lib/

# $my_path/bin/snort -q -c $my_path/etc/snort/snort.lua --daq-dir $my_path//lib/daq_s3/lib/daq -A fast -i enp1s0 > $my_path/logs/snort.log
ENTRYPOINT ["/usr/local/bin/snort", "-q", "-c", "/usr/local/etc/snort/snort.lua", "--daq-dir", "/usr/local/lib/daq_s3/lib/daq", "-A", "alert_csv", "-i", "enp1s0"]