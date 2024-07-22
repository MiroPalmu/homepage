:blogpost: true
:date: 2024-07-16
:tags: blog, tools, workflow, git, git-stash
:author: Miro Palmu

Async git-stash workflow enables test test-driven development
-------------------------------------------------------------

Edit: some comments about this post at `Hacker News <https://news.ycombinator.com/item?id=40972488>`_.

This blog post is showcase of a workflow aimed for developing
systems and its consisting components following test-driven development.

In it, features are build from top down while eagerly developing the components when needed.
Git stash enables the asynchronous development and stash messages storing
dependency information among the asynchronously developed features.

Let's say that we are developing a library in C++ which provides a computer type :code:`DeepThought`
that can generate Answer to The Ultimate Question of Life, the Universe, and Everything.
Following shell script that emulates the steps taken in development which follows
the async git-stash workflow.

.. code-block:: bash

    # Assume that magic exists and can be interfaced with program magic.

    magic test add "DeepThought::answer() returns 42."
    magic test # Fails.

    # Can not implement computer without a processor.
    git stash push -um "DeeptThought (deps: processor)"

    magic test add "Processor performs admirably in arithmetics."
    magic test # Fails.

    # Can not implement processor without memory.
    git stash push -um "processor (deps: memory)"

    magic test add "Memory lasts for millions of millennia."
    magic test # Fails.

    # Can not implement memory without technique to store information."
    git stash push -um "memory (deps: book)"

    magic test add "Book can store 100 pages."
    magic test # Fails.

    # Can not implement books without pages"
    git stash push -um "book (deps: page)"

    git stash list

    # stash@{0}: On main: book (deps: page)
    # stash@{1}: On main: memory (deps: book)
    # stash@{2}: On main: processor (deps: memory)
    # stash@{3}: On main: DeepThought (deps: processor)

    magic test add "Page can be used as memory."
    magic test # Fails.

    magic implement page
    magic test # Passes.

    git add *
    git commit -m "feat: page"

    git stash pop # book (deps: page)"
    magic test # Still fails.

    magic implement "Books that fit 100 pages."
    magic test # Passes.

    git add *
    git commit -m "feat: book"

    git stash pop # memory (deps: book)"
    magic test # Still fails.

    magic implement "Memory that lasts millions of millennia using books."
    magic test # Passes.

    git add *
    git commit -m "feat: memory"

    git stash pop # processor (deps: memory)"
    magic test # Still fails.

    magic implement "Processor that performs admirably in arithmetics."
    magic test # Passes.

    git add *
    git commit -m "feat: processor"

    git stash pop # DeepThought (deps: processor)
    magic test # Still fails.

    magic implement "DeepThought computer that can give the answer."
    magic test # Passes but takes a while.

    magic refactor "Make memory out of pages directly removing reduntant book."
    magic test # Passes but takes a while.

    git add *
    git commit -m "refactor: use pages directly from memory"
    git log --oneline HEAD~6..HEAD

    # bc9a81d (HEAD -> main) refactor: use pages directly from memory
    # 9652c97 feat: Deep Thought
    # 3rer23j feat: processor
    # a21f96e feat: memory
    # 49577b3 feat: book
    # 6f9315c feat: page
