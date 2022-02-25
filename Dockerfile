FROM mcr.microsoft.com/mssql/server:2019-CU15-ubuntu-20.04

EXPOSE 1443

#It is a bad practice to have passwords lying around like this. Best is to retrieve it from a keyvault. But for simplicity setting it like this.
ENV ACCEPT_EULA=Y \
    SA_PASSWORD=^BXt2pfR+!j+DjT^ \
    MSSQL_PID=Developer
    
RUN apt-get update && apt-get install -y \
	curl apt-transport-https debconf-utils \
    && rm -rf /var/lib/apt/lists/*
    
RUN curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add -
RUN curl https://packages.microsoft.com/config/ubuntu/20.04/prod.list > /etc/apt/sources.list.d/mssql-release.list

RUN apt-get update && ACCEPT_EULA=Y apt-get install -y msodbcsql mssql-tools
RUN echo 'export PATH="$PATH:/opt/mssql-tools/bin"' >> ~/.bashrc
RUN /bin/bash -c "source ~/.bashrc"
    
CMD [ "/opt/mssql/bin/sqlservr" ]
