**DOCUMENT OUT OF DATE**

## Installation
The installation of the software is described in the [InstallationGuide](install.md).

## Directory structure and contents
Before compiling the package, you will find in the root directory :

  * **cmake** : A directory containing cmake scripts needed to configure the application at compile time
  * **CMakeLists.txt** : The top level cmake file needed to compile the package
  * **COPYING.txt** : The GPL licence of the software
  * **dim4mac** : A directory containing instructions and patches to compile DIM on Ma- cOSX systems
  * **doc** : A directory containing the documentation of the software. A developer guide, an installation guide and a user guide is present. If the package is compiled with Doxygen, you will find the output code documentation in html and latex
  * **icons** : A directory containing icons for the visualisation system
  * **INSTALL.txt** : A file that forward the user to the installation guide in the doc directory
  * **README.txt** : A read-me file
  * **source** : The directory that contains all the sources of the package. You will find also an example directory with some plug-ins samples
  * **bin** : A directory containing all the binaries.
  * **DQM4HEPConfig.cmake** : The cmake script to load via the cmake command find_package(DQM4HEP) in a CMakeLists.txt file. This is the case for the data sending interface use and analysis module implementation in a separate project.
  * **DQM4HEPConfigVersion.cmake** : A cmake script to load the package version correctly in user’s projects.
  * **lib** : A directory containing the shared libraries.

  Except for the README.txt, INSTALL.txt and COPYING.txt all the files and directories are needed to compile correctly the package. After running the make install command in the installation process, some directories and files are appended to the package :

## Global overview
The key points of this software are :

  * A standalone run control : the software provides a run control service/client to send/receive start of run (SOR) and end of run (EOR) commands together with a run number, start/end time, run description and detector name.
  * A data distributing system : it provides a sender interface to send data to data collectors: A data collector to collect data, and a client interface to receive these data on update signal (Automatic or request from the user).
  * An analysis plug-in system : it provides a plug-in mechanism for user analysis module that :
    * processes incoming data in the DQM system
    * produces monitor elements which can be histograms, profiles, scalars, strings, etc.
    * redistributes monitor elements to a dedicated collector via a sender interface.
    * Visualisation interfaces : graphical user interfaces (GUI) to control the DQM processes and to visualise monitor elements coming from user analysis modules.


# Network aspects

## DIM implementation
The [DIM network implementation ](http://dim.web.cern.ch/dim/dim_intro.html) is used as a DNS node (DIM Name Server
Node) where all the services are registered. When a client wants to subscribe to a service, he requests the service machine to the DNS node which forward the connection to the machine on which the service is running.
A connection is thus created between the server machine and the client one and they start to communicate with a TPC/IP socket.
The default port used to initiate a connection is 2505 which can be changed by exporting the DIM_DNS_PORT environment variable. For application servers, one needs to export the environment variable DIM_DNS_NODE to the host name of the machine where the dns is running.

![PlaceHolder for DQM4HEP network implementation]() DQM4HEP network implementation


## DQM4HEP implementation
Since DQM4HEP uses DIM as network interface, the architecture looks the same. The dif- ferent parts of the software are split in different processes that can be run either on the same machine or on multiple ones. Theses processes are connected by DIM services and clients.

Next figure shows the different processes implemented in DQM4HEP. The red part represents the clients processes and in blue the server processes. The data sender process sends data usually coming from DAQ systems or files in order to feed the data collector. The collected data are then re-distributed to data clients.
From here the analysis modules process the data in order to fill elements to monitor. The second server part act in the same way as the data one. The created and filled histograms are sent to a monitor element collector which is in charge of publishing the received elements. The client part that wants to access these elements, sends a query to a data base. The process called Application control is an additional process that watches the state of the different DQM4HEP applications registered over the network. It is also possible through this process to reset or stop one of the application that is linked on the diagram that is to say a data collector, an analysis module or a monitor element collector.

![PlaceHolder for DIM network implementation figure]() DIM network implementation


All of these processes are described in details in followings chapters of this document.

  * DimCommand (receive)
  * DimClient:: sendCommand(data)
  * Data sender
  * DimCommand (receive)
  * DimClient:: sendCommand(histo)
  * Analysis Module
  * Application Control (stop/reset/state)
  * DimService DimRpc
  * Data collector
  * DimInfo
  * Monitor element collector
  * DimService
  * DimUpdatedInfo DimRpcInfo
  * Server Client
  * Vizualisation system

## Network tools
In order to start/stop/reset applications or to get information of the running dqm system, executables and API tools are provided.

  * dqm4hep_start_data_collector  
    Start a data collector application. This process is in charge of running the data collector. The only argument needed for this script is the collector name. For more details see Chapter 3.
* dqm4hep_stop_data_collector
Send a command to the data collector application in order to stop it. The only argument needed for this script is the collector name.
* dqm4hep_reset_data_collector
Send a command to the data collector application in order to reset it. The only argument needed for this script is the collector name.
* dqm4hep_get_data_collectors
Get the list of running data collectors registered on the network.
CHAPTER 2. NETWORK ASPECTS 6
* dqm4hep_get_data_collector_state
Get the data collector state. The only argument needed for this script is the collector name.
* dqm4hep_start_module_application
Start an analysis module application. This process is in charge of running the analysis module. The only argument needed for this script is a xml file. For more details see Chapter 4.
* dqm4hep_stop_module_application
Send a command to the module application in order to stop it. The only argument needed for this script is the collector name.
* dqm4hep_reset_module_application
Send a command to the module application in order to reset it. The only argument needed for this script is the collector name.
* dqm4hep_get_module_applications
Get the list of running module applications registered on the network.
* dqm4hep_get_module_application_state
Get the module application state. The only argument needed for this script is the module name.
* dqm4hep_start_monitor_element_collector
Start a monitor element collector application. This process is in charge of running the monitor element collector. The only argument needed for this script is the collector name. For more details see Chapter 3.
* dqm4hep_stop_monitor_element_collector
Send a command to the monitor element collector application in order to stop it. The only argument needed for this script is the collector name.
* dqm4hep_reset_monitor_element_collector
Send a command to the monitor element collector application in order to reset it. The only argument needed for this script is the collector name.
* dqm4hep_get_data_collectors
Get the list of running monitor element collectors registered on the network.
* dqm4hep_get_monitor_element_collector_state
Get the monitor element collector state. The only argument needed for this script is the collector name.
The same functionalities are available in C++ code. To send commands for starting/reset- ting/stopping an application or get its state, one can use the class DQMApplicationController with the following prototypes :
```c++
class DQMApplicationController :
  {
   public:
    // ...
    void sendResetCommand();
    void sendStopCommand();
    DQMState getApplicationState() const;
};
```
To get the list of data/monitor element collectors or modules applications, one can use the class DQMNetworkTool with the following prototypes :
```c++
class DQMNetworkTool :
  {
   public:
    // ...
    static StringVector getDataCollectors();
    static StringVector getMonitorElementCollectors();
    static StringVector getModuleApplications();
};
```



# Collectors
Collectors are separated in two categories : data collectors and monitor element collectors. A collector aims to collect a given type of data from a unique or multiple sources and to re-distribute these data to clients that have subscribed to it. The two collectors types work in a relatively different way, in terms of capacity and client interface.

## Data collectors

A data collector is a process with which a data sender and data client(s) interact through the network in order to collect (DimCommand) and redistribute (DimService) data. The whole process is implemented in DQMDataCollectorApplication and DQMDataCollector.

Next Figure illustrates the workflow of a data collector when an event is received from a sender and queried by a client. Users may pay attention that when a new event is received by the collector it will replace the previous one whether it has been sent to a client or not. This implies that if a client has not received event n and is not yet ready to receive it when event n+1 arrives in the collector, event n will be lost to the client.

![PlaceHolder for Data collector workflow figure]


### Data sender
The data sender is implemented in the class DQMDataSender. It is the primary step in the DQM system that feeds the system with data to process. Here is the class prototype :
```c++
   class DQMDataSender :
   {
   public:
     // ...
     void       setCollectorName(const std::string &collectorName);
     StatusCode sendEvent(DQMEvent *const pEvent);
     void       setEventStreamer(DQMEventStreamer *pStreamer);
};
```

The DQMEventStreamer is used to stream the event which will be sent by converting it into a raw buffer (char *). By default this class doesn’t know which kind of data the user is going to send and thus no streamer is allocated: the user needs to provide one. See Chapter 5 for more details on data streaming and how to implement a DQMEventStreamer interface.

The collectorName variable is the name of the collector to which the data will be sent. The event is converted into a raw buffer by using the provided streamer and the buffer is sent to the collector. The sender does not require that the collector is running and does not wait for any answer from the collector when data are sent. This allows for a potential crash of a data collector without crashing the sender process. If a data packet is sent to a collector that doesn’t exist or has crashed, it is lost. The user needs to take care that the collector name is the correct one before running the sender process.
No executable is provided since the event type to send is strongly typed and user defined.

### Data client
A map of clients keep track of :
* the client id
* whether the client is ready to receive data or not
* whether the client has received the last available event or not
The data client works thus in both query and update mode. Its interface is implemented in the DQMDataClient class. Here is the class prototype :
```c++
 class DQMDataClient :
{
public:
  // ...
  StatusCode connectToService();
  StatusCode disconnectorFromService();
  void       startReceive();
  void       stopReceive();
  void       setCollectorName(const std::string &collectorName);
  DQMEvent  *takeEvent();
  void       setEventStreamer(DQMEventStreamer *pStreamer);
};
```

The collector with which the client interacts is specified in the method setCollectorName(name). The methods connectToService() (resp. disconnectFromService()) is used to initiate (resp. destroy) the connection to the collector. The methods startReceive() (stopReceive()) are used to unblock (block) the reception of data from the collector. As for the data sender interface, a DQMEventStreamer is needed to de-serialize the incoming event raw buffer and must have the same type as the sender one. An error will occur in case of bad de-serialization of the raw event buffer. A maximum of n consecutive errors (which can be specified by the user) is allowed before an exception is thrown, stopping the data client. This usually happens when the data type is not the same and the streamer is not able to decode the raw buffer each time an event is received.
Internally, the queries to the collector are processed and data received until a queue of n events (settable by the user) is fulfilled. This helps avoiding to miss events in some situations. For example, in the spill structure of test-beams, a massive data flow is entering the DQM system in a short amount of time between pauses of a few seconds.
The method takeEvent() pop back the last received event in the queue (if any) and returns the pointer to the user. Since the pointer is removed from the queue, the responsibility to delete the event pointer is forwarded to the caller (user must delete the event).
As an example, the DQMDataClient class is used in the module application to receive data from a collector.

## Monitor element collectors
A monitor element collector is a process with which a monitor element sender and monitor element client(s) interact through the network in order to collect (DimCommand) and redistribute (using RPCs: DimRpc) monitor elements. The whole process is implemented in DQMMonitorElementCollectorApplication and DQMMonitorElementCollector.
As soon as a monitor element packet is received from a monitor element sender, the packet is stored in a map of module name versus monitor element list. Unlike the data collector, the monitor element collector works only by query. It acts more or less like a data base. Queries are then made from a monitor element client. The collector answer to these queries in order to provide :

* A list of monitor element names and informations on them. This allows the user to browse the collector and see the elements stored in the collector. The query can be done using a filter on the module name, the monitor element name and the type.
* Monitor element collector
* Send monitor element packet to collector
* Query monitor element list
* Query monitor element list info with filter
* Monitor element client
* Monitor element sender
* A list of monitor elements. The client must send a list of pair of module name and monitor element name. This query is generally performed after having a look at the collector content using the previous query above.

![PlaceHolder for Monitor element collector workflow]



### Monitor element sender
The monitor element sender works in the same way as the data sender. The interface is also similar:
```c++
   class DQMMonitorElementSender :
   {
   public:
     // ...
     void       setCollectorName(const std::string &collectorName);
     StatusCode sendMonitorElements(const std::string &moduleName, const
       DQMMonitorElementList &meList);
   };
```

The only difference here, is that no streamer has to be specified since it is internal to the package.

### Monitor element client
The monitor element client interface is implemented in the DQMMonitorElementClient class. Here is the class prototype :
```c++
   class DQMMonitorElementClient :
   {
   public:
     class Handler
     {
     // ...
     virtual StatusCode receiveMonitorElementNameList(const
       DQMMonitorElementInfoList &infoList) = 0;
     virtual StatusCode receiveMonitorElementPublication(const
       DQMMonitorElementPublication &publication) = 0;
     };
     // ...
     StatusCode connectToService();
     StatusCode disconnectorFromService();
     void       setCollectorName(const std::string &collectorName);
     void       setHandler(Handler *pHandler);
     StatusCode sendMonitorElementListNameRequest(const
       DQMMonitorElementListNameRequest &request);
     StatusCode sendMonitorElementPublicationRequest(const
       DQMMonitorElementRequest &request);
   };
```

The collector with which the client interacts is specified by the method setCollectorName(name). The methods connectToService() (resp. disconnectFromService()) is used to initiate (resp. destroy) the connection to the collector. The method sendMonitorElementListNameRequest(req) is used to send a query request for the monitor element name list to the collector. This avoids to query thousands of monitor elements to a collector just to know its content. For this query, a filter on the module name, monitor element name and type can be optionally used. Likewise, the method sendMonitorElementPublicationRequest(req) is used to query monitor elements. The request is sent using a query with pairs of list of module name and monitor element name.
In order to receive the answer of the collector, the nested class Handler has to be provided by the user. The implemented methods are call-backs called when the client receives the anwser from the collector. For example, if you send a request for a list of monitor element names, the user call-back method receiveMonitorElementNameList(list) will be processed when the collector answers the request. A handler has to be provided before performing any request to the monitor element client using the method setHandler(h).

# Analysis modules
## Introduction

The DQM system presented in this document offers the possibility to the user to process its own online analysis on raw data coming from a data collector (Chapter 3). The base processing unit is called a module (class DQMModule) that the user has to implement himself. A module instance is run in a module application (one module per application) and process incoming data in specific application flow organized in runs and cycles as shown on next figure

![PlaceHolder for Module Applcation Flow]

The application flow is as follow :

* Init : the application is initialized. The application subscribes to a run control, configure the cycle, the archiver, subscribe to the data service, load the user module plug-in and initialize it. The application waits for a start of run signal.
* Start of run : the application has received a start of run signal. If the run has already begun when the application is launched, the application starts immediately the current run after initialisation.
* Start of cycle : As soon as the run has started, the application starts to receive data from the service. A cycle starts and a series of processEvent(evt) call starts (see section 4.2).
* Process event : received events are forwarded to the user module in order to process it.
* End of cycle : the cycle ends. The monitor elements produced/filled by the user module are sent to the monitor element collector. If the archiver has been initialized (optional), the list of monitor elements is archived. Many possibilities may happened here, i) a new cycle starts, ii) the current run stops, iii) a new run starts.
* End of run : the current run stops. This happens when a run is stopped or when a new run is started.
* End : the application ends. The module application never stops by itself. A signal must be sent to tell the application to exit. This can be done by pressing the CTRL+C key sequence in the console where the application is running. An other possibility is to start the dqm control graphical user interface, to select the application among the available application list and to press the stop button. Note that this last feature is enabled only if the package is compiled with Qt (see InstallationGuide.pdf).
4.2 Cycles
As shown on figure 4.1 and explained above, the application work-flow is scheduled by cycles after the start of run signal received. A cycle is series of processEvent(evt) call, where the user process events and fill monitor elements. At the end of a cycle, the filled monitor elements are sent to the collector. This structure has been chosen for many reasons :
* The user needs enough statistics in order to analyse the incoming data and to send relevant monitor elements.
* Reproduce a sequence of incoming data. For instance :
– a spill structure that spends 30 seconds in which a detector takes 5 seconds of data acquisition.
– a spill structure that spends 30 seconds in which a detector accumulates 100 Mo of data.
* For performance reasons, it is not relevant to send, for example, a packet of 1000 monitor elements each time an event is processed.
The software provides two kinds of cycles :
* A timer cycle (TimerCycle) : a cycle that spends n seconds to process events. The default time is set to 30 seconds.
* An event counter cycle (EventCounterCycle) : a cycle that process n events before ending. The default counter is set to 100 events.
For each cycle type, a timeout is also defined. If during n seconds no event is processed, the cycles ends. The default timeout is set to 5 seconds.
The cycle properties are configurable through an xml file that the user must provides while launching a module application. See section 4.5 for a concrete xml file.
CHAPTER 4. ANALYSIS MODULES 15 4.3 Monitor elements
A monitor element is wrapper of the ROOT class TObject, mother class of most of the ROOT classes. It provides also more features designed for a DQM system :
* A quality flag : the user can assign a quality tag to the monitor element. Possible values are No Quality, Very Good, Good, Normal, Bad, Very Bad. This flag is used of the user interface the monitor elements are visualized to sort them, color them, etc ... Default is No Quality.
* A reset policy flag : a flag that determinates when the monitor element has to be reset in the application workflow. Possible values are No Reset, At End Of Run, At End Of Cycle. The module application will reset the element automatically at the correct moment. If you don’t want an automatic reset, set the flag to No Reset. The user can also reset by himself the monitor element by calling the method reset() of the DQMMonitorElement class. The default flag is At End Of Run.
* A name : a unique name of the element within an application.
* A title : A short description of the element
* A description : A long description of the element
* A run number : the current run number when the element is sent to the collector.
* A publish flag : A boolean value that determines whether the element has to be sent to the collector. This is a useful feature when a particular monitor element has, for instance, not enough statistics to be relevant and the user doesn’t want to make it available in the monitor element collector.
* A directory path : A path in an internal directory structure (see DQMStorage class) used in the user interface.
The booking of monitor elements is performed through the DQMModuleApi class. See section 4.5 for a concrete usage.
4.4 Archiver
The framework offers the possibility to write out monitor elements in a ROOT TFile. This feature is available in DQMArchiver class with the following prototype :
CHAPTER 4. ANALYSIS MODULES 16
    class DQMArchiver :
   {
   public:
   // ...
   // open an archive with the given name and opening mode.
   // Extension .root is added
   StatusCode open(const std::string &archiveFileName, const std::string
       &openingMode);
   // close the opened archive
   StatusCode close();
   // archive the module. If archiveAll is set to false, only
   // the monitor elements with the publish flag set to true
   // will be written
   StatusCode archive(DQMModule *pModule, bool archiveAll = true);
   // get the file name
   const std::string &getFileName() const;
   // Whether an archive is opened
   bool isOpened() const;
   // get the opening mode as provided in the open() method
   const std::string &getOpeningMode() const;
};
In a module application, an internal archiver is available and activated through the xml steering file (see section 4.5). It will archive all the monitor elements with the publish flag set to true in a root file.
4.5 Example
In order to clarify the tools introduced above, we provide here a complete example of a dqm module. For the event data model, we choose the only built-in one, the LCIO event interface EVENT::LCCEvent. Concretely, a dqm module a simple class that implements the DQMModule class.
For this example, we suppose that our data are coming from a calorimeter and provides reconstructed EVENT::Calorimeter objects. The cycle is configured to be a cycle of 15 seconds with a time-out of 6 seconds.
4.5.1 Module implementation
Here is the header file :
   // ExampleModule.h file
   #include "dqm4hep/module/DQMModule.h"

CHAPTER 4. ANALYSIS MODULES 17
 using namespace dqm4hep;
class ExampleModule : public DQMModule
{
public:
ExampleModule();
StatusCode initModule();
StatusCode readSettings(const TiXmlHandle &xmlHandle);
StatusCode processEvent(DQMEvent *pEvent);
StatusCode startOfCycle();
StatusCode endOfCycle();
StatusCode startOfRun(DQMRun *pRun);
StatusCode endOfRun(DQMRun *pRun);
StatusCode resetModule();
StatusCode endModule();
private:
// elements
DQMMonitorElement
DQMMonitorElement
DQMMonitorElement
DQMMonitorElement
*m_pNumberOfHitsHistogram;
*m_pEnergyHistogram;
*m_pHitTimeWithinSpill;
*m_pXYHitPositionsHistogram;
// additional parameters
std::string
unsigned int
float
float
};
m_collectionName;
m_minNHitToPublish;
m_minHitPosition;
m_maxHitPosition;
Here the header of the implementation file :
   // our header include
   #include "ExampleModule.h"
   #include "dqm4hep/core/DQMMonitorElement.h"
   #include "dqm4hep/core/DQMRun.h"
   #include "dqm4hep/core/DQMXmlHelper.h"
   #include "dqm4hep/module/DQMModuleApi.h"
   ExampleModule anExampleModule;
An instance of our module is declared in the implementation file. When the plugin will be loaded, the instance of our module will be automatically registered in the application.

CHAPTER 4. ANALYSIS MODULES 18
    ExampleModule::ExampleModule() :
     DQMModule("ExampleModule")
   {
     setDetectorName("MySweetCalorimeter");
     setVersion(1, 0, 0);
}
The constructor gives simply a type to our module. The name of the module will be decided at runtime. The (sub)detector name is set and the version. The latter may be used to identify the version of the module through the user interface.
   StatusCode ExampleModule::readSettings(const TiXmlHandle &xmlHandle)
   {
     RETURN_RESULT_IF(STATUS_CODE_SUCCESS, !=, DQMXmlHelper::readValue(xmlHandle,
                           "CollectionName", m_collectionName));
     RETURN_RESULT_IF(STATUS_CODE_SUCCESS, !=, DQMXmlHelper::readValue(xmlHandle,
                           "MinNHitToPublish", m_minNHitToPublish));
     RETURN_RESULT_IF(STATUS_CODE_SUCCESS, !=, DQMXmlHelper::readValue(xmlHandle,
                           "MinHitPosition", m_minHitPosition));
     RETURN_RESULT_IF(STATUS_CODE_SUCCESS, !=, DQMXmlHelper::readValue(xmlHandle,
                           "MaxHitPosition", m_maxHitPosition));
     return STATUS_CODE_SUCCESS;
   }
The settings are read from the xml handle. The xml helper helps to read the values. For instance, the collection name in our event is labelled by "CollectionName" and will be put in the string m_collectionName.
   StatusCode ExampleModule::initModule()
   {
     RETURN_RESULT_IF(STATUS_CODE_SUCCESS, !=, DQMModuleApi::mkdir(this,
       "/Hits"));
     RETURN_RESULT_IF(STATUS_CODE_SUCCESS, !=, DQMModuleApi::mkdir(this,
       "/Energy"));
     RETURN_RESULT_IF(STATUS_CODE_SUCCESS, !=, DQMModuleApi::mkdir(this,
       "/Time"));
     RETURN_RESULT_IF(STATUS_CODE_SUCCESS, !=, DQMModuleApi::cd(this, "/Hits"));
     RETURN_RESULT_IF(STATUS_CODE_SUCCESS, !=,
       DQMModuleApi::bookIntHistogram1D(this,
     m_pNumberOfHitsHistogram, "NumberOfHits", "Number of hits", 1501, 0, 1500));

CHAPTER 4. ANALYSIS MODULES 19 RETURN_RESULT_IF(STATUS_CODE_SUCCESS, !=, DQMModuleApi::cd(this,
       "/Energy"));
     RETURN_RESULT_IF(STATUS_CODE_SUCCESS, !=,
       DQMModuleApi::bookFloatHistogram1D(this,
     m_pEnergyHistogram, "HitEnergy", "Hits energy", 101, 0, 100));
     RETURN_RESULT_IF(STATUS_CODE_SUCCESS, !=, DQMModuleApi::cd(this, "/Time"));
     RETURN_RESULT_IF(STATUS_CODE_SUCCESS, !=,
       DQMModuleApi::bookFloatHistogram1D(this,
     m_pHitTimeWithinSpill, "HitTimeWithinSpill", "Hit time within a spill",
       101, 0, 100));
     m_pHitTimeWithinSpill->setResetPolicy(RESET_AT_END_OF_CYCLE);
     DQMModuleApi::cd(this);
     DQMModuleApi::ls(this, true);
     return STATUS_CODE_SUCCESS;
   }
The three first lines create internal directories to store the monitor elements. The next line changes the current directory to "/Hits". The two next lines book monitor elements. The first one is a histogram in 1D of int type, with name "NumberOfHits", title "Number of hits", with 1501 bins from 0 up to 1500. Note that the second argument is a null pointer on a monitor element. The latter is allocated in the function. The directory is again changed in order to book the "HitEnergy" histogram and "HitTimeWithinSpill" in two different directories. The last booked element has an additional line to set the reset policy. Since a cycle corresponds in our case to a spill, we want to reset this element at the end of each cycle. The two last lines change the current directory to the root one and print the structure in the console recursively (true as second argument).
   StatusCode ExampleModule::processEvent(DQMEvent *pEvent)
   {
     EVENT::LCEvent *pLCEvent = pEvent->getEvent<EVENT::LCEvent>();
     if(NULL == pLCEvent)
       return STATUS_CODE_FAILURE;
     EVENT::LCCollection *pCaloHitCollection =
       pLCEvent->getCollection(m_collectionName);

CHAPTER 4. ANALYSIS MODULES 20
      for(unsigned int e=0 ; e<pCaloHitCollection->getNumberOfElements() ; e++)
     {
       EVENT::CalorimeterHit *pCaloHit = pCaloHitCollection->getElementAt(e);
       if(NULL == pCaloHit)
         continue;
       m_pEnergyHistogram->get<TH1F>()->Fill(pCaloHit->getEnergy());
       m_pHitTimeWithinSpill->get<TH1F>()->Fill(pCaloHit->getTime());
     }
     m_pNumberOfHitsHistogram->get<TH1I>()
       ->Fill(pCaloHitCollection->getNumberOfElements());
     return STATUS_CODE_SUCCESS;
   }
Here is the most interesting part of the module. The processEvent(evt) function receives the data coming from the collector as soon as it is available. The DQMEvent class wraps an event that you can access via the template method getEvent<T>(). In the example here, a EVENT::LCEvent is cast. It is usually a good idea to check that the event is correctly cast (NULL pointer comparison). Our calorimeter hit collection is then accessed. Inside the loop, the accessors on wrapped TObject work also by template method. Use the method get<T>() to get the corresponding class. This class must corresponds to the type declared while booking the element. For instance, if a float histogram 1D is booked, the user must cast it into a TH1F by using the get<TH1F>() method. For the available methods you can use on the ROOT cast object, please refers to the ROOT documentation on the official website.
   StatusCode ExampleModule::startOfCycle()
   {
     // no operation
     return STATUS_CODE_SUCCESS;
   }
   StatusCode ExampleModule::endOfCycle()
   {
     double meanNHit = m_pNumberOfHitsHistogram->get<TH1I>()->GetMean();
     if(meanNHit > 160 && meanNHit < 180)
       m_pNumberOfHitsHistogram->setQuality(GOOD_QUALITY);
     else
       m_pNumberOfHitsHistogram->setQuality(BAD_QUALITY);
     if(m_pNumberOfHitsHistogram->get<TH1I>()->GetEntries() < 500)
       m_pNumberOfHitsHistogram->setToPublish(false);
     else
       m_pNumberOfHitsHistogram->setToPublish(true);
     return STATUS_CODE_SUCCESS;
   }
 For the start of cycle, we have nothing to process. But for the end of cycle, it is usually
CHAPTER 4. ANALYSIS MODULES 21
the place where we evaluate quality of the processed data. In our case, we evaluate the quality of the number of hits histogram by looking at the mean within a range. We also check that enough data have been processed to publish our histogram.
   StatusCode ExampleModule::startOfRun(DQMRun *pRun)
   {
     std::cout << "Module : " << getName() << " -- startOfRun()" << std::endl;
     std::cout << "Run no " << pRun->getRunNumber() << std::endl;
     std::string timeStr;
     DQMCoreTool::timeToHMS(pRun->getStartTime(), timeStr);
     std::cout << "Starting time : " << timeStr << std::endl;
     return STATUS_CODE_SUCCESS;
   }
   StatusCode ExampleModule::endOfRun(DQMRun *pRun)
   {
     std::cout << "Module : " << getName() << " -- startOfRun()" << std::endl;
     std::cout << "Run no " << pRun->getRunNumber() << std::endl;
     std::string timeStr;
     DQMCoreTool::timeToHMS(pRun->getStartTime(), timeStr);
     std::cout << "Ending time : " << timeStr << std::endl;
     return STATUS_CODE_SUCCESS;
   }
For the start of run and end of run, we just do some printout. This is also the place where you may initiate a connection with a database to grab useful information for the next run.
   StatusCode ExampleModule::resetModule()
   {
     return DQMModuleApi::resetMonitorElements(this);
   }
   StatusCode ExampleModule::endModule()
   {
     // no operation
     return STATUS_CODE_SUCCESS;
   }
The reset function simply reset all the monitor elements booked by this module by using the module API. No operation is processed in the endModule() function.
4.5.2 Steering file
4.5.3 Compiling the example
Since the package is compiled using CMake, we propose here to compile our example with CMake. We propose the following directory structure :
* root
* source

CHAPTER 4. ANALYSIS MODULES 22
* ExampleModule.h
* ExampleModule.cc * build
* xml
* ExampleModule.xml
* CMakeLists.txt
In the source directory our source files are put, the steering file for our application in the xml directory and the CMakeLists.txt file in the root directory. The steering file contents will be described in the next section. The CMakeLists.txt is needed to generate the MakeFile according to your plateform. Here is a complete CMakeLists.txt to compile our example :



```cmake
# CMakeList.txt for ExampleModule
CMAKE_MINIMUM_REQUIRED( VERSION 2.6 FATAL_ERROR )
# project name
PROJECT( ExampleModule )
# append DQM4HEPConfig.cmake location to the default cmake module list

LIST( APPEND CMAKE_MODULE_PATH path/to/dqm4hep )
# load dqm4hep package
FIND_PACKAGE( DQM4HEP REQUIRED )
# include the dqm4hep directories
INCLUDE_DIRECTORIES( ${DQM4HEP_INCLUDE_DIRS} )
# link lbDQM4HEP.so (.dylib) to our library
LINK_LIBRARIES( ${DQM4HEP_LIBRARIES} )
# add specific flags to compilation from dqm4hep soft
ADD_DEFINITIONS ( ${DQM4HEP_DEFINITIONS} )
# specify where our includes are
INCLUDE_DIRECTORIES( source )
# build our shared library libModuleExample.so (.dylib)
ADD_SHARED_LIBRARY( ExampleModule source/ExampleModule.cc )
# install the shared library in the lib directory
INSTALL(
      TARGETS ExampleModule
      LIBRARY DESTINATION lib
)
```

4.5.4 Running the example
Chapter 5
Data streaming
5.1 Streaming interface
5.2 Data streamer plugin
23
Chapter 6
ELog interface
24
