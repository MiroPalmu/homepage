:blogpost: true
:date: 2024-04-04
:tags: blog, bash, shell, noglob, pipe
:author: Miro Palmu

Journey of disabling filename expansion for Bash alias
------------------------------------------------------

I wanted to disable Bash pathname expansion for my Bash alias:

.. code-block:: bash

    alias g='git'

As expected I found solution from `Stackoverflow`_,
so I modified my alias to be:

.. _`Stackoverflow`: https://stackoverflow.com/a/22945024

.. code-block:: bash

    function consume_noglob() {
        local command="$1"
        shift
        $command "$@"
        set +o noglob
    }
    alias g='set -o noglob; consume_noglob git'

However this solution fails to work with pipes. For example:

.. code-block:: console

    $ echo "commit message" | g commit -F -

will be equivalent to:

.. code-block:: console

    $ echo "commit message" | set -o noglob; consume_noglob git

which means, as pipes have higher precedence over list separators,
the commit message will be piped to :code:`set`
insted of to :code:`git` inside :code:`consume_noglob`.

To solve this problem, I had plan to do following:

.. code-block:: bash

    alias g='<stash_pipe_cmd>; set -o noglob; <pop_pipe_stash_cmd> | consume_noglob git'

where `<stash_pipe_cmd>` would store the piped data sowhere
and then `<pop_pope_stash_cmd>` could pipe it to git.

.. note::

    In the follwing discussion enviroment variable `__pipestashdir` contains
    path to directory which can be used as runtime directory [#rundir]_.

In my first impelemntation of `<stash_pipe_cmd>` and `<pop_pipe_stash_cmd>`,
I naively thought that I could just use :code:`cat` and Bash redirections:

.. code-block:: bash

    # <stash_pipe_cmd>
    function pstash() {
        # Use $1 as the name for the stash.
        cat - > "$__pipestashdir/$1"
    }

    # <pop_pipe_stash_cmd>
    function ppstash() {
        local stashname="$__pipestashdir/$1"
        if ! [[ -f "$stashname" ]]; then
            # No stash exits, so do nothing.
            return 0
        fi

        cat  "$__pipestashdir/$1"
        rm "$stashname"
    }

With this solution

.. code-block:: console

    $ echo "commit message" | g commit -F -

seems to work, but if the alias is used on its own it will hang:

.. code-block:: console

    $ g --version

as cat will read until EOF and stdin is connected to terminal.
In :code:`pstash` this can be checked and only use :code:`cat` if it is not:

.. code-block:: bash

    function pstash() {
        local stashname="$__pipestashdir/$1"
        rm -f "$stashname" # Override current potential unused stash

        if [[ -t 0 ]]; then
            # stdin is connected to terminal,
            # so there is nothing to read.
            return 0
        else
            cat - > "$stashname"
        fi
    }

Now alias:

.. code-block:: bash

    alias g='pstash galias; set -o noglob; ppstash galias | consume_noglob git'

will be usable in pipes and everything is good...,
only there is one problem, git's interactive adding:

.. code-block:: console

   $ g add -i

will exit immediatly. This is because, apparently interactive adding reads
standard input for commands and exits if EOF is given, so in:

.. code-block:: bash

    alias g='pstash galias; set -o noglob; ppstash galias | consume_noglob git'

:code:`ppstash galias | consume_noglob git` will always make interactive adding exit immediatly.

To fix this, one would need to conditionally pipe the stash to :code:`git` if it exists.
Condition check can be implemented as simple function:

.. code-block:: bash

    # Pipe stash Contains
    function pstashc() {
        [[ -f "$__pipestashdir/$1" ]]
    }

but simple inline if statement:

.. code-block:: bash

    alias g='pstash galias; set -o noglob; if pstashc galias; then ppstash galias | consume_noglob git; else consume_noglob git; fi'

will not work with arguments, e.g.:

.. code-block:: console

   $ g --version

so the conditional logic has to be done inside of a function.
As :code:`consume_noglob` already is a function I modified it to consume the stash too:

.. code-block:: bash

    function consume_noglob_and_pstash() {
        local stash="$1"
        local command="$2"
        shift 2
        if pstashc "$stash"; then
            ppstash "$stash" | $command "$@"
        else
            $command "$@"
        fi
        set +o noglob
    }

so the final alias ended up being:

.. code-block:: bash

    alias g='pstash galias; set -o noglob; consume_noglob_and_pstash galias git'

this works with in pipes without breaking pipes and :code:`g add -i`.
Full code can be found at [#fullcode]_.

.. rubric:: Footnotes

.. [#rundir] Function to create runtime directory.

.. code-block:: bash

    # Returns 0 if $1 is modifiable directory and 1 otherwise.
    function is_modifiable_directory() {
        [[ -d "$1" ]] && [[ -w "$1" ]] && [[ -r "$1" ]]
    }


    # Creates unique runtime directory: `/runtime/dir/$1-XXXXXXXXXX`,
    # where `/runtime/dir/` is the first that exists from:
    #
    # - $XDG_RUNTIME_DIR
    # - $TMPDIR
    # - /tmp
    #
    # exits with status 10 if none of these is found.
    #
    # The path of created temporary directory is wirtten to stdout.
    function create_runtime_dir() {
        if [[ -z "$1" ]]; then
            echo "error: no label given"
            echo "usage: create_runtime_dir <label>"
            exit 1
        fi

        local runtime_dir
        if is_modifiable_directory "$XDG_RUNTIME_DIR"; then
            runtime_dir="$XDG_RUNTIME_DIR"
        elif is_modifiable_directory "$TMPDIR"; then
            runtime_dir="$TMPDIR"
        elif is_modifiable_directory "/tmp"; then
            runtime_dir="/tmp"
        else
            echo "error: no system runtime directory found"
            return 10
        fi

        mktemp -d "$runtime_dir/$1-XXXXXXXXXX"
    }

.. [#fullcode] Full code.

.. code-block:: Bash

    function program_exists() {
        if ! command -v "$1" &> /dev/null; then
            echo "<the_command> could not be found"
            exit 1
        fi
    }

    # Returns 0 if $1 is modifiable directory and 1 otherwise.
    function is_modifiable_directory() {
        [[ -d "$1" ]] && [[ -w "$1" ]] && [[ -r "$1" ]]
    }

    # Creates unique runtime directory: `/runtime/dir/$1-XXXXXXXXXX`,
    # where `/runtime/dir/` is the first that exists from:
    #
    # - $XDG_RUNTIME_DIR
    # - $TMPDIR
    # - /tmp
    #
    # exits with status 10 if none of these is found.
    #
    # The path of created temporary directory is wirtten to stdout.
    function create_runtime_dir() {
        program_exists mktemp || exit 1
        if [[ -z "$1" ]]; then
            echo "error: no label given"
            echo "usage: create_runtime_dir <label>"
            exit 1
        fi

        local runtime_dir
        if is_modifiable_directory "$XDG_RUNTIME_DIR"; then
            runtime_dir="$XDG_RUNTIME_DIR"
        elif is_modifiable_directory "$TMPDIR"; then
            runtime_dir="$TMPDIR"
        elif is_modifiable_directory "/tmp"; then
            runtime_dir="/tmp"
        else
            echo "error: no system runtime directory found"
            return 10
        fi

        mktemp -d "$runtime_dir/$1-XXXXXXXXXX"
    }

    __pipestashdir="$(create_runtime_dir pipestash)"

    # Pipe stash
    function pstash() {
        if [[ -z $1 ]]; then
            echo "error: missing <stashname>"
            echo "usage: pstash <stashname>"
            return 1
        fi

        local stashname="$__pipestashdir/$1"
        rm -f "$stashname"

        if [[ -t 0 ]]; then
            # stdin is connected to terminal,
            # so there is nothing to read.
            return 0
        else
            cat - > "$stashname"
        fi
    }

    # Pipe stash Contains
    function pstashc() {
        [[ -f "$__pipestashdir/$1" ]]
    }

    # Pop Pipe stash
    function ppstash() {
        if [[ -z $1 ]]; then
            echo "error: missing <stashname>"
            echo "usage: ppstash <stashname>"
            return 1
        fi
        local stashname="$__pipestashdir/$1"
        if ! [[ -f "$stashname" ]]; then
            # No stash exits, so do nothing.
            return 0
        fi

        cat "$stashname"
        rm "$stashname"
    }


    # Pipes pstash $1 to $2 if it exists.
    # Disables noglob after the call.
    function consume_noglob_and_pstash() {
        if [[ -z "$1" ]] && [[ -z "$2" ]]; then
            echo "error: <pstash> and <command> missing"
            echo "usage: consume_noglob_and_pstash <pstash> <command>"
            return 1
        fi

        local stash="$1"
        local command="$2"
        shift 2
        if pstashc "$stash"; then
            ppstash "$stash" | $command "$@"
        else
            $command "$@"
        fi
        set +o noglob
    }

    alias g='pstash g_bash_alias; set -o noglob; consume_noglob_and_pstash g_bash_alias git'
