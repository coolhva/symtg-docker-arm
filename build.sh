#!/bin/bash
docker image rm coolhva/symtg:arm32
docker build -t coolhva/symtg:arm32 .
docker push coolhva/symtg:arm32
