#!/bin/bash
wget -O - "https://search-maps.yandex.ru/v1/?\
apikey=2b28be2b-8584-424c-b193-545871bafd85\
&text=Остановка общественного транспорта, Россия, Республика Татарстан, городской округ Набережные Челны\
&lang=ru\
&type=biz\
&results=500" | jq '[.features[] | {name: .properties.name, geometry:  .geometry }]'
