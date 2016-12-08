# Introduction

__DQM4HEP__ (Data Quality Monitoring For High Energy Physics) is a software used to monitor online data coming from a test-beam setup or a full detector experiments like LHC or the future collider ILC. It provides :

  * Network tools to transfer data and histograms
  * A plug-in system to convert data into raw buffers
  * A plug-in system to process fast analysis and publish histograms through a service
  * User interfaces to visualise histograms coming from analysis plug-ins (GUI, Web pages, etc ...) and DQM system control

# Installation
## Download sources
The package sources are available on the github page <https://github.com/DQM4HEP/DQM4HEP>.
You can either download the last head (development) version with:
```console
$ git clone https://github.com/DQM4HEP/DQM4HEP.git
```

Or download and unpack the latest (stable) release version : <https://github.com/DQM4HEP/DQM4HEP/releases/latest>

## Dependencies
The package is implemented in `C++11` and configured via `cmake`. For the lightest install of the software, you’ll need :

* A c++11 compliant copiler (`gcc4.8` or `clang7.0` and later)
* CMake : to compile the package ([www.cmake.org](www.cmake.org))
* DIM : for TCP/IP sockets handling. Used for services and client remote connections in the data transfer and histogram transfer parts ([www.cern.ch/dim](www.cern.ch/dim)).
 On MacOSX>10.9, dim will not compile out of the box but a fix is included with the DQM4HEP sources. Please read the [INSTALL_MAC.txt](https://github.com/DQM4HEP/dim/tree/master/dim4mac/INSTALL_MAC.txt) file for more informations.
* ROOT : for histogram handling ([www.root.cern.ch](www.root.cern.ch))

For a more complete version, you’ll need the optionnal packages :

* LCIO (part of ILCSOFT) : for io data handling with this Event Data Model ([http://lcio.desy.de/](http://lcio.desy.de/))
* Qt : for graphical user interface implementation in the visualization system part ([https://www.qt.io/download/](https://www.qt.io/download/)). You will then need to recompile root with the `--enable-qt option` ( if you did not install Qt through the package manager you may also need to add `--with-qt-incdir=$QTDIR/include` `--with-qt-libdir=$QTDIR/lib`).  

Please note that as of June 2015 Qt4 can no longer be built from sources under MacOSX Mavericks and later. A working alternative is to use mac- ports ([https://www.macports.org](https://www.macports.org)) and the following instructions (taken from: [https://trac.macports.org/ticket/46238](https://trac.macports.org/ticket/46238)):

```console
$ git clone https://github.com/RJVB/macstrop
$ sudo port -v configure qt4-mac +concurrent
$ sudo port -v destroot qt4-mac +concurrent
$ sudo port -v -k install qt4-mac +concurrent [qt4-mac-transitional]
```


* Doxygen : to generate code documentation ([www.doxygen.org](www.doxygen.org)).
* Elog : to use the Elog interface ([https://midas.psi.ch/elog/](https://midas.psi.ch/elog/))


All dependencies are also available through desy's `afs` (/afs/desy.de/project/ilcsoft/sw/$gcc_version/) and `cvmfs` (/cvmfs/ilc.desy.de/sw/$gcc_version/) installation. __(Except for dim and elog?)__

## Compilation and installation
To compile the package :

```console
$ cd DQM4HEP # Where you cloned the package or unziped it
$ mkdir build # if the directory doesn’t exists
$ cmake .. # this will create the makefile
$ make install
```
you might have to give a hint to cmake as to where to find the dependencies with the `-D${DependencyName}_DIR=/path/to/dependency/dir` flag

You can also modify the following options :

* `DOC_INSTALL (ON/OFF)` : to install Doxygen documentation. Requires Doxygen installed. **Default is OFF**.
* `DQM4HEP_VIZUALISATION (ON/OFF)` : to install Qt Graphical user interface. Requires `Qt` installed and `ROOT` compiled with option `--enable-qt`. **Default is ON**.
* `DQM4HEP_USE_LCIO (ON/OFF)` : to build lcio plug streamer for data transfer and lcio data processing. Requires LCIO installed. **Default is ON**.
* `DQM4HEP_USE_ELOG (ON/OFF)` : to build the ELog C++ interface. Requires elog binary installed. **Default is ON**.
* `DQM4HEP_BUILD_EXAMPLES (ON/OFF)` : to build dqm4hep examples. **Default is ON**.

For example to install the Doxygen documentation option only, you can use the following command line :

```console
$ cmake -DDOC_INSTALL=ON ..
```


This will produce a shared library in the `lib` directory called `libDQM4HEP.so` and many executables in the bin directory.  
A cmake script called `DQM4HEPConfig.cmake` is produced in the root directory and will help the user to load correctly the library and find the headers to implements their analysis modules.
