# rdao-smc
This is a formal model of RANDAO-based RNG schemes as a probabilistic rewrite theory specified in Maude. The model is (1) computational, enabling automated reasoning about protocol exploitability and attack profitability, and (2) parametric, allowing for the analysis of a wide range of configuraitons and assumptions. 

*Please note that this is work-in-progress, and the model is currently being actively developed.*

*This is part of work being done at Runtime Verificaiton Inc.*

## Model Basics
The model uses a representation of actors in rewriting logic, in which each uniquely identifiable actor models either a physical entity (like a validator node) or a virtual one (such as an attacker controlling a set of validators) and reacts to incoming messages by updating its internal state, emitting new messages and/or spawning new actors. The model is **real-time**, where the time domain is modeled by the field of reals, and every event is timestamped. The model currently uses one time unit to model a time slot in the RANDAO process. Therefore, a proposers list of size '#PROP-SIZE' means that a game round will consume exactly `#PROP-SIZE` time slots. 

Although the RANDAO process is mostly deterministic, there are a few important sources of non-determinism, which are captured by the model:

1. In each game round, (honest) proposers generate new random seeds for future rounds of the game in which they participate.
2. Uncertainty in attacker behavior is probabilistically captured, based on a suitable attack model.
3. Environment uncertainties, such as transmission delays and network failures, are also captured with probabilities, governed by reasonable assumptions that can be made about the environment.

## Running Simulations

The model can be readily used to obtain sample runs of the protocol. The model is primarily specified in three files:

1. **apmaude.maude**, a generic representation of actors, messages and configurations, 
2. **rdao-params.maude**, a module in which all model parameters are specified,
3. **rdao.maude**, a specification of the different RANDAO actors and their actions. 

The specifications can be found in the **/specs** directory. 

The model parameters are declared as Maude operators, and are given values using Maude equations given in the module `PARAMS` in **rdao-params.maude**. Different scenarios can be investigated by changing the values in this module (*Note: there may be several parameters declared in this module but not currently used by the model as it is still under development*).

A fairly recent version of Maude ([Maude 2.4](http://maude.cs.illinois.edu/ "Maude") or newer) will need to be downloaded and installed. Installation insructions are available in the linked website above. Having the Maude executable available in your `PATH` (e.g. in bash: `export PATH=<path_to_the_maude_executable>:$PATH`) is recommended (will be required later for statiscal verification with PVeStA).

Once Maude is installed and added to `PATH`, one may run simulations by following the steps below:

1. Switch to the **/specs** directory, and run Maude to get into its prompt `Maude>`.
2. Issue the command: `set clear rules off .` to explicitly ask Maude to maintain its state between command runs (this is necessary for pseudo-random number generation).
3. load the model files: `load apmaude.maude`, `load rdao-params.maude`, and then `load rdao.maude`.
4. Use the rewrite command to obtain a sample run: `rew tick(initState) .`. The result is a configuration term that specifies the final state of the protocol session. You may repeat the command to obtain potentially different runs of the protocol.

The directory **/specs** includes a Maude script named **rdao-tests.maude** that automates the steps above. The script also includes a directive to enable the `print` attribute, which can show a complete log of events generated in the sample run.

## Running Statistical Model Checking Tasks

*[TBA]*

## Getting Help

For inquiries or to report problems, feel free to drop me an email.




