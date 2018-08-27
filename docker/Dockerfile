FROM docker-remote.registry.kroger.com/debian:wheezy-slim

RUN DEFAULT_GATEWAY_HEX=$(awk '$2 == "00000000" {print $3}' /proc/net/route);                                              \
    DEFAULT_GATEWAY_IPV4=$(printf '.%d' $(echo $DEFAULT_GATEWAY_HEX | sed 's/../0x& /g' | tr ' ' '\n' | tac) | cut -c 2-); \
    echo "Acquire::http::Proxy \"http://$DEFAULT_GATEWAY_IPV4:3128/\";"   >>/etc/apt/apt.conf;                             \
    echo "Acquire::https::Proxy \"https://$DEFAULT_GATEWAY_IPV4:3128/\";" >>/etc/apt/apt.conf;                             \
    echo "HTTP_PROXY=http://$DEFAULT_GATEWAY_IPV4:3128/"   >> /etc/environment;                                            \
    echo "HTTPS_PROXY=https://$DEFAULT_GATEWAY_IPV4:3128/" >> /etc/environment;                                            \
    echo "http_proxy=http://$DEFAULT_GATEWAY_IPV4:3128/"   >> /etc/environment;                                            \
    echo "https_proxy=https://$DEFAULT_GATEWAY_IPV4:3128/" >> /etc/environment;                                            \
    echo
RUN apt-get update
RUN apt-get install -y curl dnsutils less nano netcat sudo vim

# Install utils for package management and diagnosing build problems
RUN apt-get install -y apt-file apt-utils
RUN apt-file update

# Copy the bootstrap JDK into the image
#COPY jdk1.7.0_80 /opt/jdk1.7.0_80
COPY jdk-7u80-linux-x64.tar.gz /opt/jdk-7u80-linux-x64.tar.gz

# Install all prerequisites for the JDK build
RUN apt-get install -y build-essential
RUN apt-get install -y cpio
RUN apt-get install -y file
RUN apt-get install -y libasound2-dev
RUN apt-get install -y libcups2-dev
RUN apt-get install -y libfreetype6-dev
RUN apt-get install -y libX11-dev
RUN apt-get install -y libxext-dev
RUN apt-get install -y libxrender-dev
RUN apt-get install -y libxt-dev
RUN apt-get install -y libxtst-dev
RUN apt-get install -y unzip
RUN apt-get install -y zip

#COPY binutils-2.19.1.tar.bz2 /opt/binutils-2.19.1.tar.bz2
COPY binutils-2.23.2.tar.gz /opt/binutils-2.23.2.tar.gz
