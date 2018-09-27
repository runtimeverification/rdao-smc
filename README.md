# rdao-smc
This is a formal model of RANDAO-based RNG schemes as a probabilistic rewrite theory specified in Maude. The model is computational, enabling automated reasoning about protocol exploitability and attack profitability, and parametric, allowing for the analysis of a wide range of configuraitons and assumptions. 

*This is part of work being done at Runtime Verificaiton Inc.*

## Model Basics
The model uses a representation of actors in rewriting logic, in which each uniquely identifiable actor models either a physical entity (like a validator) or a virtual one (such as an attacker) and reacts to incoming messages by updating its internal state, emitting new messages and/or spawning new actors. The model is **real-time**, where the time domain is modeled by the field of reals, and every action is timestamped. The model currently uses one time unit to model a time slot in the RANDAO process. Therefore, a proposers list of size '#PROP-SIZE' means that a game round will consume exactly '#PROP-SIZE' time slots. 

Although the RANDAO process is mostly deterministic, there are a few important sources of randomness, which are captured by the model:

1. In each game round, (honest) proposers generate new random seeds for future rounds of the game in which they participate.
2. Uncertainty in attacker behaviors is probabilistically captured, based on a suitable attack model.
3. Environment uncertainties, such as transmission delays and network failures, is also captured with probabilities, governed by reasonable assumptions that can be made about the environment.

## Running Simulations

The model can be readily used to obtain sample runs of the protocol. The model is specified in **apmaude.maude** and **rdao.maude**, which can be found in the **/specs** subdirectory. The model parameters are declared as Maude operators, and are given values using Maude equations given in the module `PARAMS` in **rdao.maude**. 

A recent version of Maude ([Maude 2.4](http://maude.cs.illinois.edu/ "Maude") or newer) will need to be downloaded and installed. Having the Maude executable available in your PATH (e.g. in bash: `export PATH=<path_to_the_maude_executable>:$PATH`) is recommended (will be required for statiscal verification with PVeStA).

To run the simulations:

1. Run Maude to get into its prompt `Maude>`.
2. Issue the command: `set clear rules off .` to explicitly ask Maude to maintain its state between command runs (this is necessary for pseudo-random number generation).
3. load the model files: `load apmaude.maude .` and then `load rdao.maude .`.
4. Use the rewrite command to obtain a sample run: `rew tick(initState) .`. The result is a configuration term that specifies the final state of the protocol session. You may repeat the command to obtain potentially different runs of the protocol.

The directory **/specs** includes a Maude script named **rdao-tests.maude** that automates the steps above.

## Running Statistical Model Checking Tasks

*[TBA]*

## Getting Help

For inquiries or to report problems, please contact musab.alturki [at] gmail [dot] com.




