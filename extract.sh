# Blackboard cleaner
# Author: Richard Torenvliet
# Github-alias: icyrizard
#
# This bash script is used to unpack the zipfile blackboard generates when
# you download all the files in the "full grade center" -> Assignment Download
# File -> select all students -> download zipfile. Use help functionality to
# guide you to use this bash script.
#
# The MIT License (MIT)
#
# Copyright (c) 2014 Richard Torenvliet #
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.

# default extract directory
BB_EXTRACT_DIR=/tmp/blackboard

#Set Script Name variable
SCRIPT=`basename ${BASH_SOURCE[0]}`

#Initialize variables to default values.
OUTPUT_DIR=/tmp/bb_cleaned

#Set fonts for Help.
NORM=`tput sgr0`
BOLD=`tput bold`
REV=`tput smso`

function extract() {
   ARCHIVE=$1
   OUTPUT=$2

   if [ -f $ARCHIVE ] ; then
       case $ARCHIVE in
           *.tar.bz2)   tar xvjf $ARCHIVE -C $OUTPUT;;
           *.tar.gz)    tar xvzf $ARCHIVE -C $OUTPUT;;
           *.rar)       unrar x $ARCHIVE $OUTPUT   ;;
           *.tar)       tar xvf $ARCHIVE   -C $OUTPUT;;
           *.tbz2)      tar xvjf $ARCHIVE  -C $OUTPUT;;
           *.tgz)       tar xvzf $ARCHIVE  -C $OUTPUT;;
           *.zip)       unzip $ARCHIVE     -d $OUTPUT;;
           *)           echo "'$ARCHIVE' cannot be extracted via >extract<" && exit 1;;
       esac
   else
       echo "'$ARCHIVE' is not a valid file $OUTPUT"
       exit 1
   fi
}

# forloop delimiter
IFS=$'\n'

# get all non-txt and non-pdf files
function find_and_unpack() {
    INPUT_DIR=$1
    OUTPUT_DIR=$2

    for i in `ls $INPUT_DIR/*.txt`
    do
        PREFIX=`echo $i | awk '{split($0, prefix,".txt"); print prefix[1]}'`
        SUBMIT_NAME=$OUTPUT_DIR/`head -1 $PREFIX.txt| cut -d " " -f2,3,4,5,6 | \
            sed -e "s/\ /_/g;s/(//g;s/)//g;" | awk '{print tolower($0)}'`

        mkdir -p $SUBMIT_NAME 
        FIND_PREFIX=`basename $PREFIX`
        ARCHIVE_LIST=`find $INPUT_DIR -name "$FIND_PREFIX\_*.tar.gz" \
                    -o -name "$FIND_PREFIX\_*.tar"\
                    -o -name "$FIND_PREFIX\_*.zip"\
                    -o -name "$FIND_PREFIX\_*.rar"\
                    -o -name "$FIND_PREFIX\_*.tgz"\
                    -o -name "$FIND_PREFIX\_*.tar.bz2"`


        PDF_LIST=`find "$INPUT_DIR" -name "$FIND_PREFIX\_*.pdf" -print0`

        if [ -n "$PDF_LIST" ]; then
            cp $PDF $SUBMIT_NAME
        fi

        if [ -z "$ARCHIVE_LIST" ]; then
            echo $SUBMIT_NAME >> "error.txt"
        else
            for ARCHIVE in $ARCHIVE_LIST; do
                extract $ARCHIVE $SUBMIT_NAME
            done
        fi
    done
}

function echo_original_filecount() {
    FILE_COUNT=`ls $DIR -I *.txt -I *.pdf | grep -o -E \
        "\.([[:alpha:]])*(\.[[:alpha:]]*)*$" | sort | uniq -c`

    echo "archive files in orig_folder: \n" $FILE_COUNT
}

# delete old output directory, create new empty one
function create_directory() {
    rm -rf $1
    mkdir -p $1
}

#Help function
function HELP {
  echo -e \\n"Help documentation for ${BOLD}${SCRIPT}.${NORM}"\\n
  echo -e "${REV}Basic usage:${NORM} ${BOLD}$SCRIPT file.ext${NORM}"\\n
  echo "Command line switches are optional. The following switches are recognized."
  echo "${REV}-d${NORM}  --Set output directory ${BOLD}a${NORM}. Default\n\
                            is ${BOLD}/tmp/blackboard${NORM}."
  echo -e "${REV}-h${NORM}  --Displays this help message. No further functions are performed."\\n
  echo -e "Example: ${BOLD}$SCRIPT -d /tmp/assignment1 gradebook.zip${NORM}"\\n
  exit 1
}


#Check the number of arguments. If none are passed, print help and exit.
NUMARGS=$#
echo -e \\n"Number of arguments: $NUMARGS"
if [ $NUMARGS -eq 0 ]; then
  HELP
fi

while getopts :d:h: FLAG; do
  case $FLAG in
    d)
      OUTPUT_DIR=$OPTARG
      ;;
    h)  #show help
      HELP
      ;;
    \?) #unrecognized option - show help
      echo -e \\n"Option -${BOLD}$OPTARG${NORM} not allowed."
      HELP
      ;;
  esac
done

# shift ops, all optional args are now removed $1 will have to be the filename
shift $((OPTIND-1))

while [ $# -ne 0 ]; do
    ZIPFILE=$1
    echo "creating dir $BB_EXTRACT_DIR ..."
    create_directory $BB_EXTRACT_DIR
    create_directory $OUTPUT_DIR

    echo "extracting $ZIPFILE to $BB_EXTRACT_DIR"
    extract $ZIPFILE $BB_EXTRACT_DIR

    echo "find and unpack all submitted assignments"
    find_and_unpack $BB_EXTRACT_DIR $OUTPUT_DIR

    shift
done

exit 0