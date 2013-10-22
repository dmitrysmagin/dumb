#!/bin/sh


make COMSPEC="" \
     CC=mipsel-linux-gcc \
     OFLAGS="-mips32 -O2 -ffast-math -fomit-frame-pointer" \
     LINK_ALLEGRO="-lm `allegro-config --libs`"
