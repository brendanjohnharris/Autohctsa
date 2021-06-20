module Autohctsa
using Preferences

function sethostname(hostname::String)
    @set_preferences!("hostname" => hostname)
    @info("New default hostname set; restart your Julia session for this change to take effect")
end
const hostname = @load_preference("hostname", nothing)
function setremotedir(remotedir::String)
    @set_preferences!("remotedir" => remotedir)
    @info("New default remotedir set; restart your Julia session for this change to take effect")
end
const remotedir = @load_preference("remotedir", nothing)


"""
This one just wraps the shell script
"""
function autohctsa(in::String, out::String, hostname::String)
    sh = abspath(@__DIR__, "autohctsa.sh")
    shcmd = `$sh -i $in -o $out -h $hostname`
    run(shcmd)
end

"""
This one takes an input file, submits the job to the cluster and saves the result in the remote directory and saves placeholder files locally. Once the remote job is complete, the placeholder files can be retrieved using `retrieve()`.
"""
function submit(in::String, outfile::String="hctsa_"*match(r"[^_]+(?=\.)", basename(in))*".csv"; remotedir=remotedir, hostname=hostname)
    isnothing(remotedir) ? (@error "Please provide an absolute path to a remote directory, or set a default") : nothing
    isnothing(hostname) ? (@error "Please provide a `<user>@<hostname>` or set a default") : nothing
    out = joinpath(remotedir, outfile)
    autohctsa(in, out, hostname)
end


"""
Get completed calculations from the cluster, according to any local placeholder files in the specified directory or its subdirectories
"""
function retrieve()

end



end
