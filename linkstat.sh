#!/bin/bash

#generate the number of links that are connected to other dataset
#author	: Nur Aini
#since	: January 24, 2012
#Usage	:	chmod +x linkstat.sh
#		./linkstat.sh ntriplesfile	

skipproperties='\"|http://www.w3.org/2002/07/owl#equivalentclass|http://www.w3.org/2002/07/owl#equivalentProperty|http://www.w3.org/2000/01/rdf-schema#subClassOf|^_|http://www.w3.org/2000/01/rdf-schema#Class|http://www.w3.org/1999/02/22-rdf-syntax-ns#Property'

type="http://www.w3.org/1999/02/22-rdf-syntax-ns#type"

grep -E -v -i $skipproperties $1 | 
awk '{
 s=$1; p=$2; o=$3

if ( p ~ /type/)
	SubEntity[s]=o
else
{
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
	#print obj[1]
	objvalue=obj[1]
	if(one!=0)
	one=match(obj[1], /(.*)resource/, tes) 
	if(one!=0)
	objvalue=tes[1]

	  if (subvalue != objvalue) 
		{
		page = match(p, /<*[\/#](.*)>$/, predicate) 
		if(match(predicate[1],"([Pp]age|link)")==0 && match(o,"(.php|.htm|.asp|.html|.pdf)>$")==0) 
		{	
			arr[p]++
			SubLink[s,p]++
		}
		}
}
}
END { 
total =0
for(no in arr) { 
	print arr[no], no 
	total=total+arr[no]
	
}
print total
print "--------------"
print "Number of Link each Entity"
print "Entity	Link	Total	Average"

for(isublink in SubLink)
	{	
		split(isublink, idsub, SUBSEP);
		EntityLink[SubEntity[idsub[1]],idsub[2]]=EntityLink[SubEntity[idsub[1]],idsub[2]]+SubLink[idsub[1],idsub[2]]
	}

for (idSub in SubEntity)
	EntitySub[SubEntity[idSub]]++

for (ientitylink in EntityLink)
{
	split(ientitylink, identity, SUBSEP)
	average=EntityLink[ientitylink]/EntitySub[identity[1]]	
	print identity[1],identity[2],EntityLink[ientitylink],EntitySub[identity[1]],average
}

 }' 
