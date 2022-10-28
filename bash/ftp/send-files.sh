#!/bin/bash
#A practice script, find our relevant files and send them up to an FTP server
#Written By Craig Harris.

function usage() 
{
    cat << EOF
Send Files Up To An SFTP Server.
Requries a ftp_username and ftp_password set to authenticate.
EOF
}

#Read .env file to get credentials
export $(grep -v '^#' .env | xargs)

#Local Variables.
baseDir="/home/craig/files"
unsentDir="$baseDir/unsent"
sentDir="$baseDir/sent"
failedDir="$baseDir/failed"
failedCNT=0

if [[ -z $ftpUsername || -z $ftpPassword || -z $ftpServer ]] ; then
    usage
fi

mkdir -p {$baseDir,$unsentDir,$sentDir,$failedDir}

for file in tooLargeFiles=$(find $unsentDir -type f -size +10M -iname *.csv)
do
    mv $file $failedDir
    echo "$file Is Larger Than 10 MB, Moving To Failed"
    let "failedCNT++"
done

unsentFiles=$(find $unsentDir -type f -size -10M -iname *.csv)
if [ $? -ne 0 ] ; then
    echo "No Files Found To Send."
    exit 1
fi

for file in unsentFiles
do
    echo "Uploading $file"
    curl -T $file $ftpUsername:$ftpPassword ftp://$ftpServer/
    if [ $? -ne 0 ] ; then
        echo "Errors processing $file, moving to $failedDir"
        mv $file $failedDir/
        let "failedCNT++"
    else
        echo "$file uploaded successfully, moving to $sentDir"
        mv $file $sentDir/
    fi
done

if [ $failedCNT -gt 0 ]; then
    echo "Some CSVs failed to upload"
    exit 1
else
    echo "Files Uploaded, Complete"
    exit 0
fi
