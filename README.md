To adapt for different users, job requirements and PBS versions you should only need to edit the `PBS_tscompute.sh` job script, and maybe the qsub command toward the end of `autohctsa.sh`. This has been tested with a local `bash` shell and remote `tcsh`.s
# autohctsa

The idea is that you want a simple and lightweight (not necessarily fast) way to calculate _all_ hctsa features, particularly on a cluster.
To do this in a completely automated way:
- Put a small number of time series into a .csv file, each time series occupying a column.
- Setup an rsa key for ssh to your cluster. For example, for me (bhar9988) on the USyd School of Physics HPC cluster (`headnode.physics.usyd.edu.au`) this would look like:
``` 
ssh-keygen
[enter]
[enter]
[enter]
ssh-copy-id -i ~/.ssh/id_rsa.pub bhar9988@headnode.physics.usyd.edu.au
ssh bhar9988@headnode.physics.usyd.edu.au # Requires no password!
```
<!--- - Set up ssh on local ([Windows](https://winscp.net/eng/docs/guide_windows_openssh_server#:~:text=Go%20to%20Control%20Panel%20>%20System%20and%20Security%20>%20Administrative%20Tools%20and,type%20to%20Automatic%20and%20confirm.), [MacOS](https://support.apple.com/en-au/guide/mac-help/mchlp1066/mac), [Ubuntu](https://linuxize.com/post/how-to-enable-ssh-on-ubuntu-20-04/)) --->
- Set up another key so that the remote can ssh to local ([the procedure in general](https://winscp.net/eng/docs/guide_public_key))
- Install matlab (2019b) and hctsa on the remote. Put hctsa in `~/hctsa`. Also add `setenv TERM vt100` to `~/.cshrc`.
- Run `autohctsa.sh` (locally) with `-i <localinfilepath>`, `-o <absremoteoutfilepath>` and `-s <hostname>`, which will connect to the cluster, transfer the local file, submit the job script in `PBS_tscompute.sh` to perform hctsa calculations and then terminate.

Note that some skipped for partial auomation; a reverse ssh connection is not required to simply retrieve the files using `scp` after the job has finished
Also note the Julia functions in `autohctsa.jl` which can be used to initiate the scripts.
Obviously you should be connected to the same network as the cluster, or be using a vpn, for this whole process.

