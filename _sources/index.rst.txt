Bio
---

- Miro Palmu
- email at miropalmu.cc
- `github <https://github.com/MiroPalmu>`_

Theoretical physics student interested in C++, HPC, compilers and systems programming.

:download:`Here is my CV as downloadable pdf. <cv.pdf>`

Blog
----

.. postlist::
   :tags: blog

Projects
--------

- Guilander
    - Dependency free C++26 Wayland client library.
    - Greenfield design implemented from ground up.
    - `<https://github.com/MiroPalmu/guilander>`_
- Kuutti
    - Custom HPC cluster provision tool for bare metal written as an `Ansible`_ role.
    - Utilizes `OpenHPC`_ packages for installing: `Slurm`_, `MPI`_, `Lmod`_, etc.
    - Written for team Norppa (`Finnish IT Center for Science, CSC`_) to utilize in
      `Indy Student Cluster Competition 2023`_, where our team came second in the competition.
    - `<https://github.com/MiroPalmu/kuutti>`_
- Awk.hpp
    - Minimal awk implementation as proof of concept C++ library for
      EDSL (embedded domain spesific langauge) implementation
      technique called EDSL compilation which is heavily used in my other still WIP project.
    - `<https://github.com/MiroPalmu/awk.hpp>`_
- C++ repository template for new projects
    - Uses Meson_ build tool.
    - Testing using UT_ (C++20 Unit Testing Framework).
    - Automatic code documentation using Doxygen_.
    - User docs using Sphinx_ with Breathe_ pluging bridging cap to Doxygen documentation.
    - `<https://github.com/MiroPalmu/meson-template>`_
- This website
    - Automatic Sphinx_ debloyment to `Github pages`_.
    - `<https://github.com/MiroPalmu/homepage>`_
.. - IndexDiffGeom, idg (WIP)
..     - Compile time tensor index contraction C++ library
..     - Write tensor contractions using Latex notation which will be check for correctness at compile time.
..     - `<https://github.com/MiroPalmu/idg>`_
.. - Conway's Game of Life (C++ practice project)
..     - `<https://github.com/MiroPalmu/gol>`_

.. _Meson: https://mesonbuild.com/
.. _UT: https://github.com/boost-ext/ut
.. _Doxygen: https://www.doxygen.nl/
.. _Breathe: https://breathe.readthedocs.io/en/latest/
.. _Sphinx: https://www.sphinx-doc.org/en/master/
.. _`Github pages`: https://pages.github.com/ 
.. _`Ansible`: https://www.ansible.com/
.. _`OpenHPC`: https://openhpc.community/
.. _`Slurm`: https://slurm.schedmd.com/
.. _`MPI`: https://en.wikipedia.org/wiki/Message_Passing_Interface
.. _`Lmod`: https://lmod.readthedocs.io/en/latest/
.. _`Finnish IT Center for Science, CSC`: https://www.csc.fi/
.. _`Indy Student Cluster Competition 2023`: https://studentclustercompetition.us/2023/index.html

.. .. toctree::
..    :maxdepth: 2
..    :caption: Contents:
..
..    developing_guidelines
