#!/bin/bash

#generate the number of links that are connected to other datasource in one dataset or 
#author	: Nur Aini
#date	: January 24, 2012
#Usage	:	chmod +x linkstatfragmen.sh
#		./linkstatfragmen.sh ntriplesfile numberofpartition


function clean_up {

	rm /tmp/listsub*
	rm /tmp/listobj*
	rm /tmp/value
	rm /tmp/totalother
	#rm /tmp/otherlink*
	exit $1
}

trap clean_up SIGHUP SIGINT SIGTERM

numbpart=$2
part=0

for file in $1/*
   do
	if [ -d "$file" ]; then
		let part+=1
		grep -E -v -i '\"|http://www.w3.org/2002/07/owl#equivalentclass|http://www.w3.org/2002/07/owl#equivalentProperty|http://www.w3.org/2000/01/rdf-schema#subClassOf' $file/*.n3 | 
		awk -v partno=${part} '{
 		s=$1; p=$2; o=$3
		type="http://www.w3.org/1999/02/22-rdf-syntax-ns#type"
		if(p !~ type && s !~ /^_/)
		{ 
			#calculate links to other dataset
			one=match(s, /<(.*)#/, subj)
			if(one==0)
				one=match(s, /<(.*)\/*>$/, subj) 
			subvalue=subj[1]

			if(one!=0)
				one=match(subj[1], /(.*)resource/, tes) 
			if(one!=0)
				subvalue=tes[1]

			one=match(o, /<(.*)#/, obj)
			if(one==0)
				one=match(o, /<(.*)\/*>$/, obj) 
			objvalue=obj[1]

			if(one!=0)
				one=match(obj[1], /(.*)resource/, tes) 
			if(one!=0)
				objvalue=tes[1]

			 if (subvalue != objvalue) 
			{
				page = match(p, /<*[\/#](.*)>$/, predicate) 
				if(match(predicate[1],"(page|link)")==0 && match(o,"(.php|.htm|.asp|.html)$")==0) arr[p]++
			}
			else
			{
			
				#OBJECT
				list_object[o]=p
			}
			}
			#SUBJECT
			list_subject[s]=p
			}
		END { 
		total =0
		for(no in arr) { 
			print arr[no], no >> "/tmp/otherlink" partno
			total=total+arr[no]
		}
		
		print total >> "/tmp/otherlink" partno
		print total >> "/tmp/totalother"
	
		for (ob in list_object)
		{
			if(!(ob in list_subject))
			{
			print ob >> "/tmp/listobj" partno
	
			}
		}

		for (sb in list_subject)
		{
			if(!(sb in list_object))
			{
			print sb >> "/tmp/listsub" partno
	
			}
		}

	 }' 
	mv /tmp/otherlink$part $file
        cat $file/otherlink$part
	fi
done

nowpart=1
while [ $nowpart -le $numbpart ]
do
	
	while read line; do
				
		other=1
		
		while [ $other -le $numbpart ]
		do
			if [ $other != $nowpart ]; then
			   
			    results=`grep -c $line /tmp/listsub$other`;
			   
			    if [ $results -ne 0 ];
		            then
			       echo "$results	$line	$nowpart	$other" >> /tmp/value
			    fi
			fi
			(( other++ ))
		done
 	done < "/tmp/listobj$nowpart"
	(( nowpart++ ))
done

if [ -a /tmp/value ]; then 
insidelink=`cat /tmp/value | awk '{ sum+= $1 } END { print sum }'`
mv /tmp/value $1/links
fi
if [ -a /tmp/totalother ]; then 
outsidelink=`cat /tmp/totalother | awk '{ sum+= $1 } END { print sum }'`
echo "$1,$insidelink,$outsidelink,`date "+%Y-%m-%d %H:%M:%S"`" >> link.csv
fi

clean_up
