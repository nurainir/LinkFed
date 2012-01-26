#!/bin/bash

#generate the number of links that are connected to other dataset
#author	: Nur Aini
#since	: January 24, 2012
#Usage	:	chmod +x linkstat.sh
#		./linkstat.sh ntriplesfile	

skipproperties='http://www.w3.org/1999/02/22-rdf-syntax-ns#type|\"|http://www.w3.org/2002/07/owl#equivalentclass|http://www.w3.org/2002/07/owl#equivalentProperty|http://www.w3.org/2000/01/rdf-schema#subClassOf|http://www.w3.org/2002/07/owl#equivalentproperty|^_'

grep -E -v -i $skipproperties $1 | 
awk '{
 s=$1; p=$2; o=$3
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

  if (subvalue != objvalue) arr[p]++

}
END { 
total =0
for(no in arr) { 
print arr[no], no 
total=total+arr[no]
}
print total
 }' 
