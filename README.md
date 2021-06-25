To adapt for different users, job requirements and PBS versions you should only need to edit the `PBS_tscompute.sh` job script, and maybe the qsub command toward the end of `autohctsa.sh`. This has been tested with a local `bash` shell and remote `tcsh`.s
# autohctsa

The idea is that you want a simple way to calculate _all_ hctsa features for a timeseries, using a remote cluster.
To do this:
- Put a small number of time series into a .csv file, each time series occupying a column.
- Setup an rsa key for ssh to your cluster. For example, for me (bhar9988) on the USyd School of Physics HPC cluster (`headnode.physics.usyd.edu.au`) this would look like (in a local shell):
```
ssh-keygen
[enter]
[enter]
[enter]
ssh-copy-id -i ~/.ssh/id_rsa.pub bhar9988@headnode.physics.usyd.edu.au
ssh bhar9988@headnode.physics.usyd.edu.au # Requires no password!
```
- Install matlab (2019b) and hctsa on the remote. Put hctsa in `~/hctsa`. Also add `setenv TERM vt100` to the remote `~/.cshrc`.

Obviously you should be connected to the same network as the cluster, or be using a vpn, for this whole process as well during all of the steps below.
## Shell interface
Run `autohctsa.sh` (locally) with `-i <localinfilepath>`, `-o <absremoteoutfilepath>` and `-s <hostname>`, which will connect to the cluster, transfer the local file, submit the job script in `PBS_tscompute.sh` to perform hctsa calculations and then terminate. `scp` to collect your files once the jobs are complete.
## Julia interface
A couple of functions allow calculations to be initiated from Julia and results to be easily retrieved:
- `Autohctsa.submit(in::String)` handles execution of `autohctsa.sh`. This will create placeholder `.autohctsa` files adjacent to the input `.csv` file, `in`.
- `Autohctsa.retrieve(dir::String)` will scan the directory `dir` for any placeholder files and look for any matching files on the remote. It will then download these files locally and replace the placeholders (so run this after you have checked all remote jobs are complete).

This requires a one-time setup of the `Autohctsa.jl` package; call `Autohctsa.sethostname(hostname::String)` and `Autohctsa.setremotedir(dir::String)` to record the remote hostname and target directory, respectively.
