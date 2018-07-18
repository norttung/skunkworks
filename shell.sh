#!/bin/bash

function listChoices() {
	echo
	echo -en "What would you like to run?
	1. mongo
	2. mongos
	3. mongod
	4. edit mongos config
	5. edit mongod config
	6. shutdown\nmongOS> "	

	read answer
}

function fgOrBg() {
	echo -en "Would you like to run the process in the background? (y/n) "


	read fgbg 
}

function main() {

	while true; do
	listChoices
	
	
	if [ $answer -eq 1 ]; then
		mongo --nodb	
	elif [ $answer -eq 2 ]; then
		run=true
		while $run; do
		mkdir -p /data/db/cfg1 && mongod --port 27100 --dbpath /data/db/cfg1 -f ~/Downloads/skunkworks/shard.conf &
		mkdir -p /data/db/cfg2 && mongod --port 27101 --dbpath /data/db/cfg2 -f ~/Downloads/skunkworks/shard.conf &
		mkdir -p /data/db/cfg3 && mongod --port 27102 --dbpath /data/db/cfg3 -f ~/Downloads/skunkworks/shard.conf &
		mongo localhost:27100 --eval 'rs.initiate(
  {
    _id: "demo",
    configsvr: true,
    members: [
      { _id : 0, host : "localhost:27100" },
      { _id : 1, host : "localhost:27101" },
      { _id : 2, host : "localhost:27102" }
    ]
  }
)'
		fgOrBg
		if [ $fgbg = "y" ]; then
			run=false
			mongos -f ~/Downloads/skunkworks/mongos.conf &> /dev/null &
			sleep 1	
		elif [ $fgbg = "n" ]; then
			mongos -f ~/Downloads/skunkworks/mongos.conf #/usr/mongos.conf			
			run=false
			sleep 1
		else
			echo "Invalid choice"
		fi	
		
		done
	elif [ $answer -eq 3 ]; then
		run=true
		while $run; do
		fgOrBg
		if [ $fgbg = "y" ]; then
			run=false
			mongod -f ~/Downloads/skunkworks/mongod.conf &> /dev/null & #2> /dev/null#/usr/mongod.conf &	
			sleep 1
			ps -ax | grep mongo
		elif [ $fgbg = "n" ]; then
			mongod -f ~/Downloads/skunkworks/mongod.conf  #/usr/mongod.conf			
			run=false
			sleep 1
		else
			echo -e "Invalid choice\n"
		fi	
		
		done
	elif [ $answer -eq 4 ]; then
		vim ~/Downloads/skunkworks/mongos.conf #/usr/mongos.conf	
	elif [ $answer -eq 5 ]; then
		vim ~/Downloads/skunkworks/mongod.conf #/usr/mongod.conf	
	elif [ $answer -eq 6 ]; then
		shutdown -h now
	elif [ $answer -eq 42 ]; then
		/bin/bash
	else 
		echo -e "That is not a valid choice\n\n"	
	fi	
	
	done	
}

main
