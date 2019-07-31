#!/usr/bin/gawk -f
#
# script to output a row from a csv file to a redis server
#
# the contained function formats the output according to the redis protocol
#
#
# uwe.geercken@datamelt.com
# http://datamelt.com
#
# last update: 2019-07-31
#
#

# function to construct the redis message according to the redis protocol
function toRedisProtocol(redisKey, recordKey, keys, values) 
{
    # redis command
    redisCommand="HMSET"
    # devider between the redis key and the UID of the record/row
    devider=":"
    # the first number is the number of total parts of the command
    part1="*28\r\n$" length(redisCommand) "\r\n" redisCommand "\r\n"
    # the length of the redis kay and the key itself
    part2="$" length(redisKey) + length(devider)+ length(recordKey) "\r\n" redisKey devider recordKey "\r\n"
    result = part1 part2

    # the loop creates the appropriate output for each key and value pair
    for(i=1;i<=numberOfValues;i++)
    {
    	result= result "$" length(keys[i]) "\r\n" keys[i] "\r\n"
	result= result "$" length(values[i]) "\r\n" values[i] "\r\n"
    }
    return result
} 

# begin of processing
BEGIN {
	# setting the file's field separator
	if(separator)
	{
		FS=separator
	}
	else
	{
		FS=",";
	}

	# the key to use for redis
	redisKey="test333"
}

NR <= 1 {
	# split the header row into its individual fields
	numberOfKeys=split($0,keys,FS);
}

NR > 1 {
	# split the record into its individual values
	numberOfValues=split($0,values,FS)
	# the unique id of the record
	recordKey = values[1]
	# create the redis command
	print toRedisProtocol(redisKey, recordKey, keys, values)
}


