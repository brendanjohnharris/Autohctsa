# autohctsa

The idea is that you want a simple and lightweight (not necessarily fast) way to calculate _all_ hctsa features, particularly on a cluster.
To do this:
- Put each time series into its own .csv file
- Setup an rsa key for ssh to your cluster. For example, for me (bhar9988) on the USyd School of Physics HPC cluster (headnode.physics.usyd.edu.au) this would look like:
``` 
ssh-keygen
[enter]
[enter]
[enter]
ssh-copy-id -i ~/.ssh/id_rsa.pub bhar9988@headnode.physics.usyd.edu.au
ssh bhar9988@headnode.physics.usyd.edu.au # Requires no password!
```
- Install matlab (2019b) and hctsa on the remote. Put hctsa in `~/hctsa`. Also add `setenv TERM vt100` to `~/.cshrc`.
- Run `autohctsa.sh` (locally) with `-i <localinfilepath>`, `-o <absremoteoutfilepath>` and `-s <hostname>`, which will connect to the cluster, transfer the local file, submit the job script in `PBS_tscompute.sh` to perform hctsa calculations and then terminate.
- Once the job has completed.......................
- Alternatively, the same can be performed using the Julia functions in `autohctsa.jl`


To adapt for different users, job requirements and PBS versions you should only need to edit the `PBS_tscompute.sh` job script, and maybe the qsub command toward the end of `autohctsa.sh`. This has been tested with a local `bash` shell and remote `tcsh`.