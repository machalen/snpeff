########################################################################
#Dockerfile to build snpeff latest version from:
#http://snpeff.sourceforge.net/download.html#install
#Also the programs: vcftools, samtools, bcftools
########################################################################
FROM ubuntu:16.04

#Mantainer
MAINTAINER Magdalena Arnal <marnal@imim.es>


RUN apt update -y && apt install -y openjdk-8-jdk wget tabix unzip \
   libncurses5-dev vcftools bzip2 g++ make libbz2-dev liblzma-dev \
   build-essential gcc-multilib apt-utils zlib1g-dev git && \
   apt-get clean && \
   rm -rf /var/lib/apt/lists/*
   
#Install samtools
WORKDIR /bin
RUN wget http://github.com/samtools/samtools/releases/download/1.9/samtools-1.9.tar.bz2
RUN tar --bzip2 -xf samtools-1.9.tar.bz2
WORKDIR /bin/samtools-1.9
RUN ./configure
RUN make
RUN rm /bin/samtools-1.9.tar.bz2
ENV PATH $PATH:/bin/samtools-1.9

#Install bcftools
WORKDIR /bin
RUN wget -O tmp2.tar.gz https://github.com/samtools/bcftools/releases/download/1.9/bcftools-1.9.tar.bz2 && \
    mkdir bcftools && \
    tar -C bcftools --strip-components 1 -jxf tmp2.tar.gz && \
    cd bcftools && \
    make && \
    make install && \
    cd .. && \
    rm /bin/tmp2.tar.gz
ENV PATH $PATH:/bin/bcftools

#Install snpeff
WORKDIR /bin
RUN wget -q https://sourceforge.net/projects/snpeff/files/snpEff_latest_core.zip/download && \
    unzip download && rm download
#These steps can be done using a posteriori with a pre defined configuration file
#java -Xmx4g path/to/snpEff/snpEff.jar -c path/to/snpEff/snpEff.config GRCh37.75 path/to/snps.vcf
#We have to change the path of data.dir to the path where we have stored the databases
#Database downloaded, in the case of hg19 for example:
#wget https://sourceforge.net/projects/snpeff/files/databases/v4_3/snpEff_v4_3_GRCh37.87.zip/download
#RUN sed -i 's/.\/data/\/users\/gt\/marnal\/data/g' /bin/snpEff/snpEff.config
#RUN sed -i '126i\# HumanNew\' /bin/snpEff/snpEff.config
#RUN sed -i '127i\GRCh37.87.genome: Homo_sapiens\' /bin/snpEff/snpEff.config
ENV PATH $PATH:/bin/clinEff
ENV PATH $PATH:/bin/snpEff

#Set again the working directory
WORKDIR /
#Cleaning
RUN apt remove -y wget && apt autoclean -y && apt autoremove -y
