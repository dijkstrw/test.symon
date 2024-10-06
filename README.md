Test harness for symon
----------------------

The objective is to test compilation and operation of **symon** on a
variety of operating systems preferably on our local system. To be
able to do so we emulate the target operating systems using `qemu`,
scripting the install to make the process repeatable.

Directory structure:

    symon        - git submodule of symon project
    os           - directory per operating system

With these directories that are considered ephemeral:

    disks   - qemu disks
    iso     - installation isos
    ssh     - ssh credentials that are injected into the os disks

Set your `ROOT` to the root directory of this project. Note that a
`direnv` is included that will do this automatically.

This is work in progress; I expect to be able to reuse much of the
mechanics of building an image and have a nice expect, response
loop. Currently focus is on getting to run for the systems **symon**
reports. Cleanup and looking for common code will happen then.
