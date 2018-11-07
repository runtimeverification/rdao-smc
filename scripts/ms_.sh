#!/bin/bash
## Run verification scenarios for matchScore
##

######################################################
## INCLUDE FUNCTION LIBRARY
######################################################

. lib.sh

######################################################                           
## PRELUDE                                                                   
######################################################                              

## script parameters
mfile='rdao.maude'
mpfile='rdao-params.maude'
ffile='ms.quatex'
ofile='ms_new_sf0_sf1.out'
nthrd='5'

## Initialize model parameters
simtimelimit='1000.0'
cyclelength='10'
initvlistsize='100 * #CYCLE-LENGTH'
maxseedvalue='4294967295'

attackprob='0.2'
scorefunction='1'
minattackscore='#CYCLE-LENGTH / 10'

transmissiondelay='genRandom(0.01, 0.1)'
msgdropprob='0'

dynamicvlist='false'
validatorarrivaldelay='sampleExpWithMean(1.5)'
depositsize='32'

## zero the file
printf '\nInitial model parameters\n\n'
printf '\nInitial Model parameters\n\n' > $ofile

## Output model parameters to output file
output=''
output+='#SIM-TIME-LIMIT = '"$simtimelimit"'\n'
output+='#CYCLE-LENGTH = '"$cyclelength"'\n'
output+='#INIT-VLIST-SIZE = '"$initvlistsize"'\n'
output+='#MAX-SEED-VALUE = '"$maxseedvalue"'\n'

output+='#ATTACK-PROB = '"$attackprob"'\n' 
output+='#SCORE-FUNCTION = '"$scorefunction"'\n' 
output+='#MIN-ATTACK-SCORE = '"$minattackscore"'\n'

output+='#TRANSMISSION-DELAY = '"$transmissiondelay"'\n' 
output+='#MSG-DROP-PROB = '"$msgdropprob"'\n' 

output+='#DYNAMIC-VLIST? = '"$dynamicvlist"'\n' 
output+='#VALIDATOR-ARRIVAL-DELAY = '"$validatorarrivaldelay"'\n' 
output+='#DEPOSIT-SIZE = '"$depositsize"'\n' 
printf "$output" 
printf "$output" >> $ofile 

## Run the servers
./run-servers.sh $nthrd


##########################################################          
## SCENARIO SCRIPTS                                           
##########################################################            

cnt=1

v_clength_lst="10"
v_ivsizef_lst="100 500 1000"
v_aprob_lst="0.1 0.2 0.3 0.4 0.5"
v_sfun_lst="0 1"
v_mascore_lst="1"

for v_clength in $v_clength_lst ; do
	for v_aprob in $v_aprob_lst ; do
    	for v_mascore in $v_mascore_lst ; do 
    		for v_ivsizef in $v_ivsizef_lst ; do 
    			for v_sfun in $v_sfun_lst ; do 
	    
		    		## Prepare the header
				    scen='##########################################################\n'
				    scen+='## Scenario '"$cnt"': matchScore vs. simulation time\n'
				    scen+='## Assuming\n'
				    scen+='##    - #CYCLE-LENGTH = '"$v_clength"'\n'
				    scen+='##    - #ATTACK-PROB = '"$v_aprob"'\n'
				    scen+='##    - #MIN-ATTACK-SCORE = '"$v_mascore"'\n'
				    scen+='##    - #INIT-VLIST-SIZE = '"$v_ivsizef"' * #CYCLE-LENGTH\n'
				    scen+='##    - #SCORE-FUNCTION = '"$v_sfun"'\n'
				    scen+='##########################################################\n\n'
		    
				    printf "$scen"
				    printf "$scen" >> $ofile		

		            ## Set the assumed constants
				    cyclelength=$v_clength
				    attackprob=$v_aprob
				    minattackscore=$v_mascore
				    initvlistsize=''"$v_ivsizef"' * #CYCLE-LENGTH'
				    scorefunction=$v_sfun

		            ## Output the independent variable 
				    xname='simtimelimit'
				    ls="100.0 200.0 400.0 600.0 1000.0"
				    setIV "$xname" "$ls"		

		            ## Collect Data points
					collectData \
						"$xname" "$ls" \
						"$simtimelimit" "$cyclelength" "$initvlistsize" "$maxseedvalue" \
						"$attackprob" "$scorefunction" "$minattackscore" \
						"$transmissiondelay" "$msgdropprob" "$dynamicvlist" \
						"$validatorarrivaldelay" "$depositsize" 

				    cnt=$((cnt+1))
				done
			done
	    done
    done
done

