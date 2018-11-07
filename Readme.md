#About
Some simple scripts that show how to set up and use Red Hat AMQ 7 with Red Hat Openshift Container Platform.

Important notes: 
- Assumes password authentication
- In general these scripts attempt to do simple validation checks and attempt to prevent uncessary processes. It _should_ be generally safe to rerun any of these at any time without causing any harm.
- When in doubt, run the **clean.sh** script

#Prerequisites

You'll need a couple of things for this demo to work. The scripts were created for a Mac so your bash mileage may vary...

1. an existing installation of Openshift Container Platform, OpenShift CDK or Minishift
- an account with default privileges on this instance
- sufficient resource quotes (2-6 CPUs, 6 GB Ram, minimal TBD GB storage)
	- a local workstation with a (tiny) amount of storage;
- command line tools: bash 4.2+ ; openshift [cli tools](https://access.redhat.com/downloads/content/290/ver=3.11/rhel---7/3.11.16/x86_64/product-software) (user account at access.redhat.com required)
- Optional Eclipse with openshift, git, maven, and a handful of other plugins; [JBoss Developer Studio 10.0+](http://developers.redhat.com/products/devstudio/download/) (user account at access.redhat.com required) recommended as it already has the necessary plugins
- a web browser; Firefox 63+ or Chrome 69+ in my case

#Workflow

The recommend workflow is

1. clone this repository
- set your password via an environment variable; if present OPENSHIFT_USER_PASSWORD_DEFAULT will be used, otherwise it expects OPENSHIFT_PRIMARY_USER_PASSWORD_DEFAULT
- verify any settings in **config.sh** are correct; primarily this will be to point to the correct Openshift instance and **setting your username**
- run **setup.sh** on your local workstation
	- when rerunning you may also use **setup.sh clean** to clean up previous runs
- check out the resources that are created on the Openshift instance you are using (via the console, cli, or eclipse plugin)
- run **scale.sh** on your local workstation
	- you may also use **scale.sh {number}** to scale to some number of pods
- run **clean.sh** to remove any script and openshift artifacts; the eclipse project/artifacts are left in place in case you want to keep them


#Working with Fuse OCP Templates
1. you can also use web console, **add to project** to create a fuse with amq test instance
- use the **filter** option in the OCP Services Catalog with "AMQ" to find an appropriate Fuse instance that uses AMQ
	- Fuse expects AMQ to be running, then you just need the **AMQ\_USER, AMQ\_PASSWORD**
	- in my case I used the Red Hat Fuse 7.1 Camel A-MQ with Spring Boot template
- It may take a while for the images to download and mave to complete
	- ***and it currently crashes***


#Working with Fuse (unverified)
1. create an eclipse maven project using the camel-archetype-activemq archetype
- make the necessary modification's indicated by the setup script to the default camel-context.xml provided at *<the project location on disk>/src/main/resources/META-INF/spring/camel-context.xml*
- run the camel route
  either in eclipse
    1. select the project
    2. go to the menu "Run >> Run Configurations..."
    3. alt-select "Maven Build"
    4. select new
    5. enter for the base directory the workspace location of the project, and "camel:run" for the goal
    6. apply changes and you may now use the combo-box run icon on the default icon-bar
  or command line (from the location of the pom.xml file in your project), **mvn camel:run**
- observe the messages being pushed from your local workstation ( *<the project location on disk>/src/data/message&ast;.xml* ), to the openshift hosted A-MQ broker, to the target location ( either *<the project location on disk>/target/messages/other* or *<the project location on disk>/target/messages/uk* )
- observe the A-MQ destination being created on the broker's console (go the openshift console, find the broker's pod, select open java console) and messages enqueued/dequeued

