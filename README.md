# rdao-smc
This is a formal model of RANDAO-based RNG schemes as a probabilistic rewrite theory specified in Maude. The model is (1) *probabilistic*, specifying randomized behaviors and environment uncertainties, (2) *real-time*, capturing timed events and message transmission delays, (3) *computational*, enabling automated reasoning about protocol exploitability and attack profitability, and (4) parametric, allowing for the analysis of a wide range of configuraitons and assumptions. 

In this document, we describe generally the model, and outline how the model may be used to simulate executions of the RANDAO scheme, play with the model parameters and perform full-fledged statistical verification tasks using Maude and PVeStA. A more detailed technical report describing the analysis performed using this model and the analysis results can be found [here](https://github.com/runtimeverification/rdao-smc/blob/master/report/rdao-analysis.pdf). 

*This is part of work being done at Runtime Verificaiton Inc.*

## Model Basics
The model uses a representation of actors in rewriting logic, in which each uniquely identifiable actor models either a physical entity (like a node) or a virtual one (such as an attacker controlling a set of validators) and reacts to incoming messages by updating its internal state, emitting new messages and/or spawning new actors. The model is **real-time**, where the time domain is modeled by the field of reals, and every event is timestamped. 

The model uses one time unit to model a time slot in the RANDAO process. Therefore, a proposers list of size `#CYCLE-LENGTH` means that a game round will consume exactly `#CYCLE-LENGTH` time slots. A validator represents one unit of validation in the protocol (so all validators are have the same weight). However, an attacker my control more than one validator and thus may have more than one unit of share in the network. 

Initially, the state of the protocol is bootstrapped with a validator set of size `#INIT-VLIST-SIZE`, of which `#CYCLE-LENGTH` validators are pseudo-randomly selected as proposers. The RANDAO contract and the validators are all initialized with pseudo-randomly generated seeds. While the protocol executes, an incoming validator (which could be attacker-controlled) may join the RANDAO process and become available to participate in the next round of the game. 

Although the RANDAO process itself is mostly deterministic, there are a few important sources of (probabilistic) non-determinism, which are captured by the model:

1. In each game round, (honest) proposers generate new random seeds for future rounds of the game in which they participate. Furthermore, new validators may join the network (and some of which may be compromised by the attacker).
2. Uncertainty in attacker behavior is probabilistically captured, based on a suitable attack model.
3. Environment uncertainties, such as transmission delays and network failures, are also captured with probabilities, governed by reasonable assumptions that can be made about the environment.

## Running Simulations

The model can be readily used to obtain sample runs of the protocol. The model is primarily specified in three files:

1. **apmaude.maude**, a generic representation of actors, messages and configurations, 
2. **rdao-params.maude**, a module in which all model parameters are specified,
3. **rdao.maude**, a specification of the different RANDAO actors and their actions. 

The specifications can be found in the **/specs** directory. 

The model parameters are declared as Maude operators, and are given values using Maude equations given in the module `PARAMS` in **rdao-params.maude**. Different scenarios can be investigated by changing the values in this module.

A fairly recent version of Maude ([Maude 2.4](http://maude.cs.illinois.edu/ "Maude") or newer) will need to be downloaded and installed. Installation insructions are available in the linked website above. Having the Maude executable available in your `PATH` (e.g. in bash: `export PATH=<path_to_the_maude_executable>:$PATH`) is recommended (will be required later for statistical verification with PVeStA).

Once Maude is installed and added to `PATH`, one may run simulations by following the steps below:

1. Switch to the **/specs** directory, and run Maude to get into its prompt `Maude>`.
2. Issue the command: `set clear rules off .` to explicitly ask Maude to maintain its state between command runs (this is necessary for pseudo-random number generation).
3. load the model files: `load apmaude.maude` and then `load rdao.maude`.
4. Use the rewrite command to obtain a sample run: `rew tick(initState) .`. The result is a configuration term that specifies the final state of the protocol session (as determined by the `#SIM-TIME-LIMIT` parameter). You may repeat the command to obtain potentially different runs of the protocol.

The directory **/specs** includes a Maude script named **rdao-tests.maude** that automates the steps above. The script also includes a directive to enable the `print` attribute, which can show a complete log of events generated in the sample run.

## Changing the Model Parameters

The model is heavily parameterized to enable experimenting with different setups and attack behaviors. The parameters are defined in the module `MODEL-PARAMS` in **rdao-params.maude**. The relevant equations are listed below:

    ---- Runtime limit of a single macro step in the simulation 
    ---- (in logical time units -- or slots in our case as the 
    ---- length of a time slot is exactly one logical time unit)
    ---- e.g. 1000.0 time units (or time slots)
    eq #SIM-TIME-LIMIT = 200.0 .

    ---- The number of steps in a cycle (or round) of the game, which is
    ---- also the number of proposers in the list of proposers in any 
    ---- round. 
    eq #CYCLE-LENGTH = 10 .

    ---- Initial size of the list of approved validators (the list  
    ---- from which #CYCLE-LENGTH proposers are sampled at the begining
    ---- of a round). Note that if the validator list is dynamic, the 
    ---- actual size of the validator list during protocol execution 
    ---- may be higher or lower than this initial value. The value  
    ---- can be specified as an absolute value (e.g. 10000) or as a 
    ---- multiple of the size of the proposers list #CYCLE-LENGTH 
    ---- (e.g. 500 * #CYCLE-LENGTH)
    eq #INIT-VLIST-SIZE = 500 * #CYCLE-LENGTH .

    ---- Maximum seed value: this is fixed to the maximum allowed by 
    ---- Maude's implementaion of the (pseudo-)random function random()
    eq #MAX-SEED-VALUE = 4294967295 .

    ---- Probability of a validator being compromised (controlled by the 
    ---- attacker), e.g. 0.2 means that, on average, 20% of validators are
    ---- attacker-controlled
    eq #ATTACK-PROB = 0.1 .
 
    ---- The score function the attacker is trying to optimize for. 
    ---- There are two score functions: 
    ---- 1. countCompromised(L): which counts the total number of 
    ----    compromised proposers among the proposers list L (regardless
    ----    of where they actually appear in L). For example, assuming 
    ----    only proposers v(3), v(5) and v(6) are compromised, we have 
    ----    countCompromised(1 . 2 . 3 . 4 . 5 . 6) = 3.
    ---- 2. countCompromisedTail(L): which counts the number of 
    ----    compromised proposers occupying the tail of the list L (the
    ----    length of the compromised tail of the list). For instance, 
    ----    for the example above, we have 
    ----    countCompromisedTail(1 . 2 . 3 . 4 . 5 . 6) = 2 (since
    ----    the compromised tail consists of v(5) and v(6)). 
    ---- 0 denotes countCompromised, while 1 denotes countCompromisedTail
    eq #SCORE-FUNCTION = 0 .

    ---- One-way message transmission delay (0.0 means instantaneous 
    ---- message delivery, and thus synchrnous communication). 
    ---- Transmission delays are typically uniformly sampled from a 
    ---- reasonable range that represents the actual network latency.
    eq #TRANSMISSION-DELAY = genRandom(0.01, 0.1) .

    ---- A flag indicating wether a scheduled message is to be dropped
    ---- modeling a potentially unreliable communication network.
    ---- 0 means "not to be dropped", while 1 means "to be dropped".
    ---- Message drops in a realistic communication medium can be modeled 
    ---- by a Bernoulli distribution with a (drop) probablility p
    eq #MSG-DROP-PROB = 0 .

    ---- A flag indicating whether the validator list is dynamic, allowing
    ---- new validators to join in during the execution of the protocol, or 
    ---- not. 
    eq #DYNAMIC-VLIST? = false .

    ---- The arrival delay of new validators joining the network (relevant 
    ---- only when #DYNAMIC-VLIST? is true). The delay is usually sampled 
    ---- from an appropriate distribution (typically the exponential 
    ---- distribution)
    eq #VARRIVAL-DELAY = sampleExpWithMean(1.5) .

    ---- The size in Ether of a validator's deposit to join the network.
    ---- This has no significant role in the current version of the 
    ---- specification and can safely be ignored. 
    eq #DEPOSIT-SIZE = 32 .

Once the parameters are set, the steps explained in the previous section may now be used to obtain new sample runs.


## Running Statistical Model Checking Tasks

The model can be used not only to simulate the protocol but also to statistically verify certain properties about it, most importantly the attacker's ability to bias the randomness of the protocol. For this, we use the statistical model checking and quantitiative analysis tool [PVeStA](http://maude.cs.uiuc.edu/tools/pvesta/ "PVeStA") alongside [Maude](http://maude.cs.illinois.edu/ "Maude"). The properties to be verified are specified as temporal quantitative expressions in QuaTEx, and are fed into PVeStA (along with the Maude models) for evaluation. 

To get a quantitative measure of the potential bias achievable by an attacker, we define two properties:

1. Matching Score (MS): Within `t` time units, how much bias will the attacker be able to achieve on the protocol's randomness measured in terms of the number of compromised proposers? (`ms.quatex`)

2. Last-Word Score (LWS): Within `t` time units, how much bias will the attacker be able to achieve on the protocol's randomness measured in terms of the number of compromised last proposers (the length of the longest compromised tail)? (`lws.quatex`)

These two properties can be analyzed assuming different setups (e.g. static vs. dynamic validator sets) and assumptions (e.g. attacker controls 20% of the network). To get started with the analysis, you will need to:

*  Download and install [Maude 2.4](http://maude.cs.illinois.edu/ "Maude") or newer, and have it available in your PATH (e.g. in bash: `export PATH=<path_to_the_maude_executable>:$PATH`). Maude will have to be accessible from anywhere in your terminal.
*  Download the [PVeStA](http://maude.cs.uiuc.edu/tools/pvesta/ "PVeStA") binaries (the server and client jar files). Note that PVeStA needs Java 1.6 or later installed (there is, however, an apparent incompatibility with Java 9).

As explained [here](http://maude.cs.uiuc.edu/tools/pvesta/usage.html "PVeStA Usage"), there are three steps for running a verification task with PVeStA:

1. Running the server executable pvesta-server.jar 
2. Creating a server-list file
3. Running the client executable pvesta-client.jar 

For simplicity, we will assume two server instances running on the same machine, and that we would like to estimate the first property  `ms.quatex`. Furthermore, PVeStA requires that the Maude model files and the QuaTEx formula files are all in the current directory. To initiate the verification task, follow the steps below:

1. Make a working directory `workarea` and change to it.
2. Copy the files **apmaude.maude**, **rdao-params.maude**, **rdao.maude** **ms.quatex** and **portlist2** to `workarea` (the current directory).
3. Run the servers using the following commands (`<pvesta-jar-files-path>` is the path to PVeStA's binaries):

      ``` 
      java -jar <pvesta-jar-files-path>/pvesta-server.jar 49046 > server1.out &
      ```

      ```
      java -jar <pvesta-jar-files-path>/pvesta-server.jar 49047 > server2.out &
      ```
      
4. Run the client using the following command:

      ```
      java -jar <pvesta-jar-files-path>/pvesta-client.jar -l portlist2 -m rdao.maude -f ms.quatex -a 0.05 -d1 0.05
      ```

The last command initiates the verification task and may take a while to execute (depending on the parameters chosen for the model). Once it finishes, the result is output to the screen. The servers will continue to run in the background waiting for further requests. So, you may repeat step 4 above right away to verify other properties, or re-verify the same property but with different model parameters. Of course, sequences of verification tasks can be automated by writing appropriate scripts. Sample shell scripts to automate these steps can also be found the **/scripts** subdirectory.


## Getting Help

For inquiries or to report problems, feel free to drop me an email.




