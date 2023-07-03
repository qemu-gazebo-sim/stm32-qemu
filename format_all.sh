#!/usr/bin/env bash

###################################################################
#Script Name	:format_all.sh
#Description	:format all files
#Author       	:Vanderson Santos
#Email         	:vanderson.santos@usp.br
###################################################################

# HEADER_FILES=$(find . -name "*.h") - $(find . -wholename "./libcacard/*.h") 
HEADER_FILES=$(find . -name "*.h" -type f \( ! -wholename "./fpu/**" -a  ! -wholename "./build/**" -a  ! -wholename "./hw/dma/**" \) )
SOURCE_FILES=$(find . -name "*.c" -type f \( ! -wholename "./fpu/**" -a  ! -wholename "./build/**" -a  ! -wholename "./hw/dma/**" \) )

uncrustify -c uncrustify.cfg --replace --no-backup $HEADER_FILES
uncrustify -c uncrustify.cfg --replace --no-backup $SOURCE_FILES

# echo $HEADER_FILES