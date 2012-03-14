#!/bin/bash

#generate the number of links that are connected to other dataset
#author	: Nur Aini
#since	: January 24, 2012
#Usage	:	chmod +x linkstat.sh
#		./linkstat.sh ntriplesfile	

skipproperties='\"|http://www.w3.org/2002/07/owl#equivalentclass|http://www.w3.org/2002/07/owl#equivalentProperty|http://www.w3.org/2000/01/rdf-schema#subClassOf|^_|http://www.w3.org/2000/01/rdf-schema#Class|http://www.w3.org/1999/02/22-rdf-syntax-ns#Property|http://xmlns.com/foaf/0.1/page'

type="http://www.w3.org/1999/02/22-rdf-syntax-ns#type"

grep -E -v -i $skipproperties $1 | 
awk '
BEGIN { FS = ">[\t ]<" }
{

s=$1
p=$2
o=substr($3, 1, length($3)-4)


if ( match($2,"http://www.w3.org/1999/02/22-rdf-syntax-ns#type")!=0)
{
	SubinClass[s]=o
	
}
else if ( $3 !~ /.*\.(pdf|html|asp|php|jpg)/ ) 
{
	
	if(match(s, "<http://(.*)#", subj)!=0 || match(s, /<http:\/\/(.*):/, subj) !=0)
	{
		subvalue=subj[1]
		
	}
	else (match(s, /<http:\/\/(.*)\/.+$/, subj) !=0)
	{
		
		if(match(subj[1], /(.*)(resource|inserts)/, tessub) !=0)
		{
		subvalue=tessub[1]
				
		}
		else
		subvalue=subj[1]
		
	}
	
		
	
	if(match(o, "http://(.*)#", obj)!=0 || match(o, /http:\/\/(.*):/, obj) !=0)
	{
		objvalue=obj[1]		
	}

	else (match(o, "http://(.*)/.*", obj) !=0)
	{
		if(match(obj[1], /(.*)(resource|inserts)/, tes) !=0)
			objvalue=tes[1]
		else
			objvalue=obj[1]
	}

	  if (subvalue != objvalue) 
		{
	
				
		if(match(p,".*[#/].*([Pp]age|[Ll]ink).*$")==0 )
		{	
			arr[p]++
			#drugbank issue
			if(match(objvalue,"129.128.185.122/drugbank2/*"))
				objvalue="129.128.185.122/drugbank2"
			SubLink[s,p,objvalue]++
			otherdataset[objvalue]++
			
		}
		}
}
}
END { 
total =0
print "Link to other dataset"
for(no in arr) { 
	print arr[no], no 
	total=total+arr[no]	
}
print total
delete arr

print "--------------"
print "Other dataset"
total =0
for(idother in otherdataset) { 
	
	print otherdataset[idother], idother 
	total=total+otherdataset[idother]
	
}
print total
delete otherdataset
print "--------------"
print "Number of Link each Class"
print "Class	Link	OtherDataset	TotalLink	Distinct Subject	Average"

for(isublink in SubLink)
	{	
		split(isublink, idsub, SUBSEP);
		ClassLink[SubinClass[idsub[1]],idsub[2],idsub[3]]=ClassLink[SubinClass[idsub[1]],idsub[2],idsub[3]]+SubLink[isublink]
	}

#calculate distinct subject each class
for (idSub in SubinClass)
	EntitySub[SubinClass[idSub]]++

cost_p=0
cost_c=0
for (iClassLink in ClassLink)
{
	split(iClassLink, identity, SUBSEP)
	cost_p = cost_p + EntitySub[identity[1]]
	cost_c++
	average=ClassLink[iClassLink]/EntitySub[identity[1]]	
	print identity[1],identity[2],identity[3],ClassLink[iClassLink],EntitySub[identity[1]],average
}
print "cost publisher " cost_p
print "cost consumer " cost_c
print "total cost " cost_p+cost_c
 }' 
