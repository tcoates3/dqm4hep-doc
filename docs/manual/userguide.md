**DOCUMENT UNDER CONSTRUCTION**


# Json configuration 
# Module Configuration

# Troubleshooting
## Job control
##### The job control interface is empty
**INSERT screenshot**

Check you provided a configuration file when launching it.
Check the file is properly opened by the application. (check the terminal for some error)
**Add errors given in terminal**

##### Some applications are missing in the job control interface
Check that a hostname is not defined twice in the configuration file
Check terminal for errors in parsing the config file

##### All applications appear to be dead in the JobControlInterface even when I try launching them
**INSERT screenshot**

The jobcontrol daemon is probably not running with sudo right
``` bash
  $ sudo ${DQM4HEP_DIR}/bin/dimjcdqmd start
```
Or daemon is not running with the right `DIM_DNS_NODE`. Check the configfile. If not sure which configfile, check the `envFile` variable in the daemon launch script (default is `/etc/default/dqm4hepenv`)
``` bash 
  $ less ${DQM4HEP_DIR}/bin/dimjcdqmd
```

##### Popup saying no jobcontrol is running on a hostname
**INSERT screenshot**

Make sure it's running on the host
``` bash
  $ ssh hostname
  $ sudo ${DQM4HEP_DIR}/bin/dimjcdqmd status
```
if you see `MESSAGGE PAS OK`, start it :
``` bash
  $ sudo ${DQM4HEP_DIR}/bin/dimjcdqmd start
    MESSAGE OK
```

Otherwise you will see `MESSAGE OK`, try restarting the daemon making sure it's running with sudo rights:
``` bash
$ sudo ${DQM4HEP_DIR}/bin/dimjcdqmd restart
  MESSAGE OK
```
## Run control interface
##### The daq started a run, interface still says it's not running
Sometimes the signal is not properly received, you can manually start the run.
   
##### Even manually I can't start a new run. Nothing is happening when clicking on start
The run control server has died, start it again from the `jc` interface.

## Main monitoring window
##### No me_collector
 - Check it's running in the `jc`
 - Check the `DIM_DNS_NODE` of the monitoring window executable is the same as the rest of the applications
  
##### No histograms
 - Check in the `jc` that analysis modules are running.

##### Interface is stuck
The load on the machine is too important:
  - Too many applications are running on the same host as the main monitoring window (each analysis module can max out a core, running 4+ analysis on a quad core machine will cause lags)
  - You are running on `auto update` mode and receiving too many histograms at once, the interface doesn't have time to update everything before receiving a new `update` command.
      Try stopping the auto update and deactiving some histograms.
    
##### Daq started but histograms are empty
- Clic on update 
- Check in the run control interface that a run is started if not check **add reference to  `## Run control interface`**
- Check the event collector is running
- Check the event collector/analysis modules are receiving events 

# Workflow
  >To avoid some configuration headache, always prefer to launch all application with a script sourcing the `dqm4hepenv` file instead of running directly the executable. You'll find example of such scripts in the `scripts` folder.


All steps in the following list are described later in more details. 
 
    1 Edit the `dqm4hepenv` config file to define the correct `DIM_DNS_NODE`, other env variable (such as the DQM4HEP_DIR) and config files for each applications  
    1 Launch the dqm dimjc daemon on each host  
    2 Launch the job control interface (refered to as `jc` later)  
    3 Start the run control server from the `jc`  
    4 Launch the run control interface : Not needed but useful to check the signals from the daq are properly received   
    4 Start the applications you want from the `jc`  
    5 Wait for a new run to start (or click on `start` in the run control interface if no signal were received from the daq)  
    6 You can start/stop applications during a run, you won't have access to data received before though  
    7 If the `run control server` dies during a run you will have to relaunch it and start manually a new run from the run control interface. You might loose some data in the monitoring in the process 
  
### dqm4hepenv file
Adapt the `DIM_DNS_NODE`, `DQM4HEP_DIR`, and various configuration files path to your setup

### dimjc daemon
Edit the `envFile` variable in `${DQM4HEP_DIR}/bin/dimjcdqmd` to point to the `dqm4hepenv`:
``` bash
  $ sudo ${DQM4HEP_DIR}/bin/dimjcdqmd start
    MESSAGE OK
```
Note that it must be run as root, it won't be able to control the applications otherwise.

You can check it's running with
``` bash
  $ sudo ${DQM4HEP_DIR}/bin/dimjcdqmd status
    MESSAGE OK
```

### job control 
You must provide a json configuration file to run it (you would have a blank interface otherwise).
 
 An example config file is given in the conf folder of the main dqm4hep repository and the syntax is showcased at the end of the section. 
 
 For the monitoring to run properly you at least need the following applications to be defined in the configfile:
  - Data streamer (shm driver for SDHCAL)
  - Run control server
  - Event collector(s)
  - Monitor Element collector(s)
  - Analysis module(s)
  
  
  > Adapt the `dqm4hepenv` config file to point to the correct `jc` config file.

Edit `$DQM4HEP_DIR/scripts/startRunControl` to point to the `dqm4hepenv` config file.

Then you can launch it with:
``` bash
  $ $DQM4HEP_DIR/scripts/startRunControl
```

You can start/kill/restart applications by :
  - Selecting one or more with `ctrl`, right click and `start selected`
  - Right click on any application `Start all jobs`
  - Right click on any application `Start host jobs`
  
To see the log of an application, right click on it -> `open log file`. Or select the application and click on `Open log file`
The application is not self refreshing at launch, you will have to either click on `update` or set the `auto update` eith a timer
You can choose the action performed by the `kill` command with the dropdown menu in the top right corner  

#### Syntax example for the json configuration file:
 Take note that bash style variable expansion and `//` style comment are implemented for ease of use 
 ``` json
 {
   "VARS" : {
     "GLOBAL": {// not needed but showcase the use of variable expansion
       "DQM_DNS_NODE" : "/*host name running */",
       "XML_VAR" : "xmlValue",
       "OtherGlobalVar" : "Value",
       "LIBRARIES" : "path/to/libs",
       "etc" : "etc"
      }
    },
    "HOSTS" :{
      "Host1": [
        { // first application
         "NAME":"appName",
         "ARGS" : [ // args you want to pass to the application
           "--parameter", "xml.parameter=${XML_VAR}",
           "--verbosity", "DEBUG"
          ],
          "ENV" : [ // env variable you want to set for the application
            "DIM_DNS_NODE=${DQM_DNS_NODE}", // Required for all application, they won't start if not set
            "DQM4HEP_PLUGIN_DLL=${LIBRARIES}"
          ],
          "PROGRAM" : "path/to/executable"
        },
        {//second application
          "NAME" : "appName2",
          "..." : "..."
        }
      ],
      "Host2": [
        {"...":"..."}
      ]  
    }
  }
 ```
 
 
 
