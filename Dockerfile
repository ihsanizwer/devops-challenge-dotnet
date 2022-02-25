FROM mcr.microsoft.com/mssql/server:2019-CU15-ubuntu-20.04

EXPOSE 1443

#It is a bad practice to have passwords lying around like this. Best is to retrieve it from a keyvault. But for simplicity setting it like this.
ENV ACCEPT_EULA=Y \
    SA_PASSWORD=^BXt2pfR+!j+DjT^ \
    MSSQL_PID=Developer

    
CMD [ "/opt/mssql/bin/sqlservr" ]
