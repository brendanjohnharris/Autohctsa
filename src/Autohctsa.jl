module Autohctsa
using Preferences
using CSV

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

function __init__()
    if isnothing(hostname)
        @warn "No default hostname set. Use `sethostname(hostname::String)` to do so."
    end
    if isnothing(remotedir)
        @warn "No default remotedir set. Use `setremotedir(hostname::String)` to do so."
    end

    # Try connecting to remote with defaults
    shcmd = `ssh $hostname "pwd"`
    f() = run(shcmd)
    go = Task(f)
    schedule(go)
    g() = istaskdone(go)
    check = timedwait(g, 5)
    # if check != :ok
    #     println("")
    #     @warn "Could not automaticaly connect to default remote. Please check preferences, and try connecting to `hostname` manually. You might need to set up a key pair so that password authentication is not required."
    # else
    #     @info "Successfully attempted a connection to the default host. Check terminal outpu for connection status."
    # end
end



"""
This one just wraps the shell script
"""
function autohctsa(in::String, out::String, hostname::String)
    inn = abspath(in)
    @assert isfile(inn)
    sh = abspath(@__DIR__, "autohctsa.sh")
    hm = pwd()
    cd(@__DIR__)
    in = replace(inn, "\\"=>"/")
    out = replace(out, "\\"=>"/")
    @assert isfile(inn) && isfile(sh)
    @info "Submitting: $inn\n to: $out\n on: $hostname\n with: $sh\n"
    try
        #run(`dos2unix $sh`)
        shcmd = `"$sh" -i "$inn" -o "$out" -h "$hostname"`
        run(shcmd)
    catch e
        cd(hm)
        throw(e)
    end
    cd(hm)
end

"""
This one takes an input file, submits the job to the cluster and saves the result in the remote directory and saves placeholder files locally. Once the remote job is complete, the placeholder files can be retrieved using `retrieve()`.
"""
function submit(in::String, outfile::String="hctsa_"*match(r"[^_]+(?=\.)", basename(in)).match*".csv"; remotedir=remotedir, hostname=hostname, replace=false)
    isnothing(remotedir) ? (@error "Please provide an absolute path to a remote directory, or set a default") : nothing
    isnothing(hostname) ? (@error "Please provide a `<user>@<hostname>` or set a default") : nothing
    out = joinpath(remotedir, outfile)
    tmp = abspath(dirname(in), splitext(outfile)[1]*".autohctsa")
    if isfile(splitext(tmp)[1]*".csv") && !replace
        @warn "Result file already exists, skipping job"
    else
        autohctsa(in, out, hostname)
        tmpdict = Dict(:hostname=>hostname, :in=>in, :out=>out, :tmp=>tmp)
        CSV.write(tmp, tmpdict; header=false)
    end
    return nothing
end


"""
Get completed calculations from the cluster, according to any local placeholder (.autohctsa) files in the specified directory or its subdirectories
"""
function retrieve(dir::String; remotedir=remotedir, hostname=hostname)
    # We will walk the given directory recursively for files that have the extension .autohctsa
    remotefs = readlines(`ssh $hostname "find $remotedir -name \* -print"`)
    for (root, dirs, files) in walkdir(dir)
        for f ∈ files
            if splitext(f)[2] == ".autohctsa"
                D = CSV.File(abspath(root, f), header=false) |> Dict
                lookingfor = splitext(basename(f))[1]*".csv"
                if hostname == D["hostname"] && dirname(remotedir*"/") == dirname(D["out"]) && any(lookingfor .== basename.(remotefs))
                    dest = abspath(root, lookingfor)
                    remff = joinpath(remotedir, lookingfor)
                    run(`scp "$hostname:$remff" "$dest"`)
                    rm(splitext(dest)[1]*".autohctsa")
                end
            end
        end
    end
end

end
