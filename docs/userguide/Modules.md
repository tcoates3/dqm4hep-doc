# Analysis and Standalone Modules
When using the DQM4HEP framework for monitoring an experiment, the analysis and standalone modules -- collectively referred to as “DQM modules” -- are the most important components for a user to understand. DQM modules receive data coming from data sources and perform a process defined by the user, then encapsulates the result into a monitor element before being sent to the monitoring GUI to be displayed. 

In terms of programming and structure, there is little to no difference between an analysis module and a standalone module and their structure and operation is almost exactly the same. Analysis modules are used to interpret data coming from the data acquisition system so that it can be displayed in graphical form. For example, converting an ADC into an energy, arranging data into a geometrically ordered hitmap, or plotting the individual ADCs of a large number of data points to form an energy spectrum. Standalone modules do similar processes on data that has not come from the data acquisition system. A standalone module may still take data from an external source, such as environmental data like temperature, but they may also be entirely self-contained (e.g. a random noise generator). 

An arbitrary number of DQM modules may be run simultaneously, which is useful for separating unrelated analyses (e.g spectra and hitmaps) as well as allowing the computational load to be distributed across machines on a network.

Other C++ files can be included in DQM modules, which can be used to integrate the features or properties of pre-existing libraries or code. An example of this is to construct geometrically-corrected hitmaps by using a C++ function to convert between the channel numbers of pixels and their physical positions, using an XML file to store the configuration of the detector's pixel to construct a mapping between electronics number and physical location.

## Components
A DQM module is comprised three parts: the source file, the header file, and the steering file. The source and header files are written in C++11 and the steering file is XML. 

###### Source File
The source file contains the initialisation and booking of plots and other resources needed for analysis or processing; a main loop which does the main process(es) of the module. This is the core of the module itself, performing the process(es) via ordinary C++ code.

###### Header File
The header file is used in the normal way a header file is used for C++ source files. Notably, monitor elements, variables that persist over more than one event, and variables that are read in from the steering file (below) must be declared within the header file.

###### Steering file
The steering file defines how the module should run. Networking information is defined here, including the name to give each instance of the module, and the event collector and monitor element collectors that the module should connect to, if any. The monitor elements themselves are also defined here, given names, titles, paths, parameters, etc. It can also be used to include variables or data at runtime.

## Writing and compiling
An example of a DQM module is located in `/dqm4hep-ilc/source/examples/ExampleModule/`. When writing a module, it is a good idea to copy these files to a new directory within the examples folder, editing these to create your module. The files are commented to explain which parts should be edited.

In general, there are three member functions which requires special attention when writing a DQM module.

### Source File
###### readSettings() Function
The `readSettings` function is where the module parses the XML steering file to declare and initialise any variables needed by the module, which includes plots and monitor elements. Plots are declared using the function `RETURN_RESULT_IF()`. There are three arguments, only the last of which needs editing. The last argument is the function to execute, in this case the `DQMXmlHelper::bookMonitorElement()` function. This function in turn has four arguments, which again only the last two should be edited. These should be the title of the plot, and the variable name of the plot, which is declared and defined as equal to NULL in the previous line. Any other variables that need to be read from the XML file should be declared and parsed here, as shown in the example in the file.

###### processEvent() Function
The `processEvent` function is called every time a new event is passed to the module. This is the main loop of the program, and where most event-by-event analysis takes place, such as converting an ADC into an energy and filling a histogram with this value. This is where any information or data should be filled into plots/monitor elements, and any pre-processing that is needed before this is done should be executed here.

###### endOfRun() Function
The `endOfRun` function is called once the end of the run is reached. If your module must collect any information about the run as a whole, this is where that information should be read out or filled into a monitor element. If this is the case, you should also initialise these variables within the `startOfRun()` function, to avoid a previous run affecting values in the current run.

### Header File
[...]

### Steering FIle
[...]