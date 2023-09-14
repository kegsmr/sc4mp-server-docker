FROM python:alpine3.18

ENV PORT=7240
ENV VERSION=0.3.0

# add system deps first to keep it cached for rebuilds
RUN apk add --no-cache wget unzip

RUN mkdir -p /server/src

ADD ./serverconfig.sh /serverconfig.sh
ADD ./startup.sh /startup.sh

WORKDIR /server

# download server release, unpack and remove redundant files in docker single layer
RUN wget https://github.com/kegsmr/sc4mp-server/archive/refs/tags/v${VERSION}.zip \
    && unzip ./v${VERSION}.zip -d ./src \
    && mv ./src/sc4mp-server-${VERSION}/* . \
    && rm -r ./src ./v${VERSION}.zip

RUN sed -i -e 's/import os/import os, getpass/g' /server/sc4mpserver.py
RUN sed -i -e 's/os\.getlogin()/getpass\.getuser()/g' /server/sc4mpserver.py

RUN mkdir /server/_SC4MP

EXPOSE ${PORT}

CMD [ "/startup.sh" ]
