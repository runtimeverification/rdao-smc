#!/bin/bash
## Function library common to all verification scripts
##

## assumes the following global script parameters
## These must be deinfed by the main script importing lib.sh
## $mfile   The model file name
## $mpfile  The model parameters file name
## $ffile   The QuaTEx formula file name
## $ofile   The output file name
## $nthrd   The number of parallel threads

#######################################################                          
## Function definitions                                                        
#######################################################                 

## Output the independent variable                  
function setIV {
    printf '\nThe independent variable x '"$1"
    printf '\nThe independent variable x is '"$1" >> $ofile
    printf '\nValues are '"$2"'\n'
    printf '\nValues are '"$2"'\n' >> $ofile
}

## Update the model, run the simulations and collect data points      

function collectData {
    ## initialize paramter names                                         
    local simtimelimit_name='simtimelimit'
    local cyclelength_name='cyclelength'
    local initvlistsize_name='initvlistsize'
    local maxseedvalue_name='maxseedvalue'
    
    local attackprob_name='attackprob'
    local scorefunction_name='scorefunction'
    local minattackscore_name='minattackscore'

    local transmissiondelay_name='transmissiondelay'
    local msgdropprob_name='msgdropprob'
    
    local dynamicvlist_name='dynamicvlist'
    local validatorarrivaldelay_name='validatorarrivaldelay'
    local depositsize_name='depositsize'

    ## initializa their values
    simtimelimit=${3}
    cyclelength=${4}
    initvlistsize=${5}
    maxseedvalue=${6}

    attackprob=${7}
    scorefunction=${8}
    minattackscore=${9}

    transmissiondelay=${10}
    msgdropprob=${11}

    dynamicvlist=${12}
    validatorarrivaldelay=${13}
    depositsize=${14}

    ## update parameter names based on $1                   
    local x_name=${1}
    case $x_name in
        simtimelimit)           simtimelimit_name='x'
            ;;
        cyclelength)            cyclelength_name='x'
            ;;
        initvlistsize)          initvlistsize_name='x'
            ;;
        maxseedvalue)           maxseedvalue_name='x'
            ;;
        attackprob)             attackprob_name='x'
            ;;
        scorefunction)          scorefunction_name='x'
            ;;
        minattackscore)         minattackscore_name='x'
            ;;
        transmissiondelay)      transmissiondelay_name='x'
            ;;
        msgdropprob)            msgdropprob_name='x'
            ;;
        dynamicvlist)           dynamicvlist_name='x'
            ;;
        validatorarrivaldelay)  validatorarrivaldelay_name='x'
            ;;
        depositsize)            depositsize_name='x'
            ;;
    esac

    ## Cycle through the values for x_name to collect data        

    for x in $2 ; do
        ## Update the model (NOTE: one of the these parameter names resolves to 'x'!!)
	
        printf 'Setting up the model for '"$x_name"'='"$x"'\n'

        sed -i '' 's|eq[[:space:]]#SIM-TIME-LIMIT[[:space:]]*=.*|eq #SIM-TIME-LIMIT = '"${!simtimelimit_name}"' .|' $mpfile
        sed -i '' 's|eq[[:space:]]#CYCLE-LENGTH[[:space:]]*=.*|eq #CYCLE-LENGTH = '"${!cyclelength_name}"' .|' $mpfile
        sed -i '' 's|eq[[:space:]]#INIT-VLIST-SIZE[[:space:]]*=.*|eq #INIT-VLIST-SIZE = '"${!initvlistsize_name}"' .|' $mpfile
        sed -i '' 's|eq[[:space:]]#MAX-SEED-VALUE[[:space:]]*=.*|eq #MAX-SEED-VALUE = '"${!maxseedvalue_name}"' .|' $mpfile

        sed -i '' 's|eq[[:space:]]#ATTACK-PROB[[:space:]]*=.*|eq #ATTACK-PROB = '"${!attackprob_name}"' .|' $mpfile
        sed -i '' 's|eq[[:space:]]#SCORE-FUNCTION[[:space:]]*=.*|eq #SCORE-FUNCTION = '"${!scorefunction_name}"' .|' $mpfile
        sed -i '' 's|eq[[:space:]]#MIN-ATTACK-SCORE[[:space:]]*=.*|eq #MIN-ATTACK-SCORE = '"${!minattackscore_name}"' .|' $mpfile

        sed -i '' 's|eq[[:space:]]#TRANSMISSION-DELAY[[:space:]]*=.*|eq #TRANSMISSION-DELAY = '"${!transmissiondelay_name}"' .|' $mpfile
        sed -i '' 's|eq[[:space:]]#MSG-DROP-PROB[[:space:]]*=.*|eq #MSG-DROP-PROB = '"${!msgdropprob_name}"' .|' $mpfile

        sed -i '' 's|eq[[:space:]]#DYNAMIC-VLIST?[[:space:]]*=.*|eq #DYNAMIC-VLIST? = '"${!dynamicvlist_name}"' .|' $mpfile
        sed -i '' 's|eq[[:space:]]#VARRIVAL-DELAY[[:space:]]*=.*|eq #VARRIVAL-DELAY = '"${!validatorarrivaldelay_name}"' .|' $mpfile
        sed -i '' 's|eq[[:space:]]#DEPOSIT-SIZE[[:space:]]*=.*|eq #DEPOSIT-SIZE = '"${!depositsize_name}"' .|' $mpfile

        ## Run the clients and record the result             
                                                                                 
        printf 'Running the simulations...\n'
        printf '\n('"$x"' ,' >> $ofile
        ./run-client.sh $nthrd $mfile $ffile | awk /Result:/'{printf "%2.4f",$2}' >> $ofile
        printf ')' >> $ofile
        printf 'Done.\n'
    done
    printf '\n' >> $ofile

}



