plugVim
=======

A vim plugin manager that uses vim 8's native plugin support and git
submodules. If you want more information on the basics of this I
recommend reading `Vim: So long Pathogen, hello native package loading
<https://shapeshed.com/vim-packages/>`_, as it was my reference when
creating the script.

Table of Contents
-----------------

- `Installation`_
- `Usage`_
- `Examples`_
- `License`_


Installation
------------

.. code ::

  git clone git@github.com:tuckerevans/plugvim.git
  cd plugvim
  make install

Usage
-----

Commands
~~~~~~~~
- install
- update
- remove
- list
- help
- version

Options
~~~~~~~

-  **-g "local git directory"** default: ~/dotfiles/
-  **-d "directory containing .vim"** default: GIT_REPO/vim/
-  **-o** place plugin in opt folder instead of start.
-  **-c** commit changes

Examples
~~~~~~~~
Installing `gitgutter <github.com/airblade/vim-gitgutter>`
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
- Basic:
    :code:`plug install https://github.com/airblade/vim-gitgutter.git`
- Install gitgutter and commit changes:
    :code:`plug install -oc https://github.com/airblade/vim-gitgutter.git`
- In a different Git repository (not \*/dotfiles):
    :code:`plug install -g path/to/different/repo https://github.com/airblade/vim-gitgutter.git`

Updating all plugins
^^^^^^^^^^^^^^^^^^^^
- Basic:
    :code:`plug update`
- With a set number(8) of threads:
    :code:`plug update -j 8`

Removing `gitgutter <github.com/airblade/vim-gitgutter>`
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
- Basic:
    :code:`plug remove gitgutter`
- If gitgutter was installed in opt directory:
    :code:`plug remove -o gitgutter`
- If .vim is not located in ``GIT_REPO/vim``
    :code:`plug remove -d path/to/parent/of/.vim`

License
-------
`MIT <github.com/tuckerevans/plugvim/blob/master/LICENSE>`_
