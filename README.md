# OSS-Fuzz Repair: Automated repair on OSS-Fuzz data

Please see `README_OSSFUZZ.md` for the renamed original OSS-Fuzz `README.md`.

This software is built on top of
[OSS-Fuzz](https://github.com/google/oss-fuzz). As with OSS-Fuzz, it
mainly consists of a number of *projects*.  The new projects added to
the original OSS-Fuzz are for running the automated repair tools on a
version of software that contains a bug. For example
`projects/ffmpeg_1298` directory contains the project files for FFmpeg
bug 1298. The number 1298 is assigned by OSS-Fuzz issue tracker.

Here we mention several important files:

* `Makefile`: This is used to execute all of the automated repair
  experiments in parallel. For example, do
  ```
  make -j 55
  ```
  To execute all of the experiments, each on a different project (buggy
  software) in parallel using at most 55 cores.
  ```
  make -j 55 ffmpeg
  ```
  will only execute the projects for the FFmpeg software, in parallel using at most 55 cores.
  ```
  make ffmpeg_1298
  ```
  will only execute the project for the issue 1298 of the FFmpeg
  software. Please try not to edit the `Makefile` as it is automatically
  generated by `build_makefile.sh`.

* `run.sh`: The actual execution is done by this script. `Makefile` is actually just a parallelization wrapper for it. In case you want to use it directly, here is some examples:
  ```
  ./run.sh
  ```
  will run all the projects sequentially.
  ```
  ./run.sh wireshark
  ```
  will run only the wireshark projects sequentially.
  ```
  ./run.sh wireshark 3372
  ```
  will run only the project 3372 of wireshark.
  ```
  The repository does not contain the source code of the buggy code subjects:
  The code will be automatically downloaded and the right
  commit hash will be checked out.
