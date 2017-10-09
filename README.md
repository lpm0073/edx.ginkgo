# Open edX Step-By-Step Production Installation Guide

This is a step-by-step fully automated script to stand up a single-server full-stack production-ready instance of Open edX release Ginkgo.1 running on an Amazon Web Services (AWS) EC2 (Elastic Compute Cloud -- aka virtual server) R3.Large instance (aka 2-cpu server with 16gb RAM and configurable hard drive space). The script installs the following Open edX modules:
1. Learning Management System (LMS)
2. Course Management System (CMS)
3. Insights Analytics module and api
4. Certification Module (To generate digital course completion certificates)
5. Course Discovery (To provide a comprehensive course search engine capability to learners)
6. Ecommerce Server (for paid courses)
7. Discussion Forum
8. XQueue and RabbitMQ (to enable asynchronous multi-tasking such as automatic computer source code graders)

The Open edX platform leverages a plethora of technologies, and this tends to be a formidable stumbling block for all of us, initially at least. For what it's worth, I know a lot about a few of Open edX's technologies, and almost nothing about everything else. Unlike the official documentation, this page attempts to assume as little as possible. Hopefully it helps. Good luck!

**Contributors are welcome. My contact information is on my web site.**

Lawrence McDaniel | https://lawrencemcdaniel.com

---
## Build Procedure
This installation script is based upon Ned Batchelder's "Native Open edX Ubuntu 16.04 64 bit Installation" method described here: https://openedx.atlassian.net/wiki/spaces/OpenOPS/pages/146440579/Native+Open+edX+Ubuntu+16.04+64+bit+Installation

### I. Create a new AWS EC2 instance
You should create a fresh server instance per the instructions / screen shots that follow. Some advice:
1. Do not attempt to install Open edX on an existing machine. It probably won't work. Worse, you'll probably destroy the existing server.
2. Do not attempt to install Open edX on a version of Linux other than Ubuntu 16.04. It won't work.
3. Do not attempt to use a cloud service provider other than AWS. It might work, but, you'll be flying solo in terms of documentation.
4. Keep in mind that the Open edX documentation's "minimum hardware requirements" are exactly that: the bare minimum that is technically feasible. You need more robust gear for a production deployment.


Following is a down-and-dirty set of screen shots to walk you through the key server attributes in terms of size, security and so on.  If you're unfamiliar with Amazon Web Services then you can start your journey here: https://aws.amazon.com/getting-started/.

#### Login to your AWS Account. Navigate to the EC2 console. Look for an action button that reads "Launch Instance"

<img src="/img/aws-ec2-1.png" width="100%">

#### Step 1: Choose AMI
AWS provides you with a pick list of several common server operating systems. Technically speaking, each of these options is an AMI (Amazon Machine Image) that AWS internally maintains and makes available to their customers. For you, this means that you're able to spin up an Ubuntu server in a few seconds, without needing to worry about where the operating system repo might be located and so on.

<img src="/img/aws-ec2-2.png" width="100%">

#### Step 2: Server Sizing
AWS EC2 Server Sizing: After prolonged experimentation I have gravitated to AWS EC2 R3.Large servers as my virtual server configuration of choice. Generalizing, this provides 2 cpu's and 16gb of memory. I launch these with 100gb of drive space, which thus far has been far more than sufficient for my needs. Bear in mind that my recommendation is almost exactly double that provided in the edX documentation (https://openedx.atlassian.net/wiki/spaces/OpenOPS/pages/146440579/Native+Open+edX+Ubuntu+16.04+64+bit+Installation). My view on this is that it's already challenging enough to get this platform up and running without adding unnecessary challenge by under-sizing your equipment.

Very generally speaking, this server config should handle a **couple hundred** concurrent learners. Look at the bottom of this page for links to downstream repos that are part of a simple horizontal scaling strategy for small (but not tiny) institutions.

_Note: AWS will charge you approximately $0.16 per hour for a R3.large instance. AWS only charges for time that your instance is running. You can stop the server from the AWS EC2 console at any time, which is logically identical to powering down a physical server._

<img src="/img/aws-ec2-4.png" width="100%">

#### Step 3: Instance Details
The default values provided in this screen are what you want. Later on it would be a great idea to revisit these settings to get a better understanding of your infrastructure-level configuration options.

<img src="/img/aws-ec2-5.png" width="100%">

#### Step 4: Add Storage
AWS instances by default come with 8gb of "hard drive" storage. However, you can modify this. You'll need at least 50gb of storage for Open edX plus normal amounts of data. I suggest doubling that amount, to 100gb. I have not seen that this impacts the cost of the server in any meaningful way.

<img src="/img/aws-ec2-6.png" width="100%">

#### Step 5: Add Tags
Tags are a way to identify AWS resources inside your account. This is only important if you have many resources (for example, many server instances) in existence in your AWS account. Otherwise you can skip this step.

<img src="/img/aws-ec2-7.png" width="100%">

#### Step 6: Security Profile
**This is important.** You manage server port settings separately from the server itself. Generalizing, you create a port security profile, and then assign this profile to your EC2 instance. Open edX uses many ports as part of the standard installation. Note that this script installs **ALL** modules, and you therefore need to open many ports. Open edX default http addressing uses port numbers rather than subdomains or url paths/routes. The ports in the screen shot that follows correspond with the following Open edX modules.

| Module        | Port           |
| :------------ | -------------: |
| LMS      | 80 |
| CMS		|  18010 |
| Certs		|  18090 |
| Discovery	|  18381 |
| Ecommerce	|  18130 |
| edx-release	|  8099 |
| Forum		|  18080 |
| Xqueue		|  18040 |

Some of these urls lead to a landing page, others do not.

<img src="/img/aws-ec2-8.png" width="100%">

#### Step 7: Review Instance Prior to Launch

<img src="/img/aws-ec2-9.png" width="100%">

#### Step 8: Setup an SSH key pair
You'll use a terminal emulator via SSH to connect to your server. If you're unfamiliar with how to connect to a linux server then you can start your journey here: http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/putty.html. Note that you will run this script as well as execute nearly all Open edX admin utilities from a linux command line. So, if you're new to this then you should bite the bullet and do some online self-study on using linux terminal emulators and SSH.

<img src="/img/aws-ec2-a.png" width="100%">

#### Step 9: Launch Status
Click the blue "View Instances" button at the bottom-right of this screen.

<img src="/img/aws-ec2-b.png" width="100%">

#### Step 10: EC2 Instance Console
If this is your very first EC2 instance then you'll see a single row on this screen that shows the vital signs of your new Linux virtual server. It will take a few minutes for the server to instantiate itself and come online. When the server is ready the "Instance State" field will read "Running" and the icon color will change from yellow to green.

<img src="/img/aws-ec2-c.png" width="100%">

_You are now finished with the AWS management console. Hereon you will interact with your EC2 instance using a terminal window over SSH._

### II. Execute the script

**The script takes around 2 hours to run and is intended to be spawned on a background process as follows:**

`sudo nohup wget https://raw.githubusercontent.com/70F/edx.ginkgo.1/master/install.sh -O - | bash > install.out &`

You can read more about the `nohub` directive here: https://en.wikipedia.org/wiki/Nohup. As relates to this usage, the combination of the `nohup` directive along with the ampersand at the end of the line will cause the script to launch on a new thread. That is, it will not execute on the thread that is managing your terminal connection. Thus, when you logout of the server (or if the connection is inadvertently broken) then the script will continue to run until completion.

I suggest using up to three additional terminal windows to monitor progress of the script.
1. the linux `top` command is similar to Windows and OSX's "System Activities" or "System Monitor" windows. The server cpu usage will remain steady at around 50% cumulative usage while the script is running.
2. the command `sudo /edx/bin/supervisorctl status` will print the Open edX processes that are currently running. You'll see this list grow as the script progresses
3. using `ls` to explore the children folders of /edx/ will at a minimum be informative.

_Editorial Note: I am a Linux neophyte at best, and I hope your newfound knowledge of such fact brings you hope._

### III. Verify that the script worked
Once the script is complete you should be able to open the landing pages for both the LMS and the CMS. See below for additional information about the many port assignments and URL oddities of Open edX. More immediately, the landing pages for the LMS and CMS should look like the following:

<img src="/img/edx-screen-lms.png" width="45%"><img src="/img/edx-screen-cms.png" width="45%">

Also, using the following admin command line script, you can view which Open edX modules are currently running:

`sudo /edx/bin/supervisorctl status`

If the installation was successful then you should see the following:
<img src="/img/full-stack-pristine-modules.png" width="100%">

### IV. Create an admin account
You can save yourself a lot of future busy work by creating a root / admin account in this instance, prior to creating your AMI. Following are the commands to create a new superuser from the terminal command line:

```
sudo su -s /bin/bash edxapp
cd
/edx/bin/python.edxapp /edx/bin/manage.edxapp lms manage_user staff staff@example.com --staff --superuser --settings=aws
```

### V. Create an AWS AMI
Read more here to learn about what an AMI (Amazon Machine Image) is, and how it is used: http://docs.aws.amazon.com/elasticbeanstalk/latest/dg/using-features.customenv.html

Meanwhile, here's a screen shot short cut that at least points you in the right direction of where to go and what to do.
<img src="/img/aws-ami-create.png" width="100%">

It will take around 15 minutes for the AWS Image to render. Once the process has completed, and only after the process has completed, you can _terminate_ the original EC2 instance from the EC2 instance console.

### VI. Create and customize a new EC2 instance
Here's a screen shot of the AWS AMI launch window just to ensure that we're on the same page. Vastly summarizing, an AMI is a stored image of a server. Think of an AMI as a server template. in just a couple of minutes you can launch a run-time copy of the Open edX platform that this script creates. If you make mistakes, accidentally destroy your Open edX platform, whatever, then you can terminate your instance and start over again by creating another new instance from the AMI. More information from AWS here: https://aws.amazon.com/premiumsupport/knowledge-center/launch-instance-custom-ami/

<img src="/img/awi-ami-launch.png" width="100%">

#### How To Customize Your EC2 Instance
To the best of my knowledge there are four strategies for customizing a pristine installation of Open edX. In each of these cases you should begin with a pristine installation of the Open edX platform, which is what this script does. Furthermore, by creating an AWS AMI of the resulting EC2 instance you'll save yourself two hours of waiting each time you irreparably destroy your Open edX instance due to tinkering -- which will probably be often.

##### 1. RECOMMENDED: Use /edx/app/edx_ansible/server-vars.yml + Ansible Playbooks
Bizarrely, this file is missing from a pristine installation of Open edX. Further, there is no README.1st nor any other kind of breadcrumb to guide you on how to configure the platform once you've succeeded in your initial build. I learned through brute-force experimentation and tons of perusing in Google that the variable names that you find in the four json files located in /edx/app/edxapp/ as well as the config variables found in the many other modules, are all unique to the entire platform, AND, that you can set these variables in a variety of ways; the most important being to create a /edx/app/edx_ansible/server-vars.yml file, which is automagically referenced and imported in the /edx/bin/update script (you'll use this to update the platform later on) and then sent to the myriad Ansible playbooks as needed. the edx/bin/update script downloads and installs an updated repo of whichever module you added on the command line. See: https://openedx.atlassian.net/wiki/spaces/OpenOPS/pages/60227913/Managing+OpenEdX+Tips+and+Tricks#ManagingOpenEdXTipsandTricks-UpdatingVersionsusingedXrepos. The update script will pass and set any variable parameter values that you include in the server-vars.yml file, and conveniently, it ignores any that are not relevant.

Conversely, I also learned that the ansible installation playbooks generate (ie they OVERWRITE) the various json config files that you find scattered around the installation. Furthermore, after inspecting these json files - namely, /edx/app/edxapp/lms.env.json and /edx/app/edxapp/cms.env.json - you'll see that many variable assignments are duplicated, making it especially challenging to determine in which file you would set a customization value. the moral of this story is: it behooves you to use server-vars.yml and the playbooks.

_Tip: You'll find a comprehensive list of edX platform feature flags located here:  http://edx.readthedocs.io/projects/edx-installing-configuring-and-running/en/latest/feature_flags/feature_flag_index.html. You can include any of these flags in your server-vars.yml file._

_Another Tip: You'll find a potentially useful list of variable names and default values in this file: https://github.com/edx/configuration/blob/master/playbooks/sample_vars/server_vars.yml. You can copy paste any of these variables into your own server-vars.yml file, which I found to be a great way to get my feet wet. Mind you, there's no magic much less rhyme or reason to the composition of this list, so don't read too deeply into it._

##### 2. Django Admin Console
Interestingly, the official documentation runs counter to my suggested approach above, and instead suggests that you should use the Django admin console to create a JSON site environment object with all of the same stuff you'd include in the server-vars.yml file. To be fair, this strategy does provide immediate effect to your variable modifications. You could even combine a server-vars.yml approach with this approach - *even though it would be epically stupid to do so.* Note however that I've found that Django pays attention to some variables while ignoring others. I've never figured out why or under what circumstances, but suffice it to say that i abandoned this strategy early-on. Documentation is here if you feel so compelled:  http://edx.readthedocs.io/projects/edx-installing-configuring-and-running/en/latest/configuration/sites/configure_site.html

##### 3. JSON config files
**Broadly speaking, this is a bad idea.** Once this script completes you'll find a set of json config files in /edx/app/edxap which contain settings for most/all of the types of things that you need to modify in order to cusotmize your Open edX installation. But beware:

1. *these files are overwritten any time your update the platform*
2. variable names are sometimes referred to, and set in multiple locations
3. /edx/app/edxap is not the sole location of json config settings

Despite these repercussions, I've found considerable documentation in the various Google groups and tech blogs that infer this strategy in many otherwise really good "how-to" articles. Mind you, articles following this approach are useful, but only to the extent that you want a better understanding of what's going on with Open edX under the hood.

##### 4. Editing Application Source Code
**This is unequivocally a terrible idea.** Open edX is an open source platform and so there's certainly nothing stopping you diving in and mucking around with the source code. Caveat emptor.

---

### Additional Information and General Description
This is a pushbutton script to install the Gingko release of the Open edX platform + all optional modules, and all required subsystems on the single server instance in which you initiated the script. Note that the script does not provision nor assume any additional AWS resources. Once completed you'll find the complete application software code base in /edx/ and the multitude of automatically-generated strong passwords at ~/my-passwords.yml. You should make an offline copy of the passwords file. You should keep the passwords file in your home directory because downstream devops procedures need this file and expect to find it in this location. do not change the file ownership, nor group, nor permissions of this file.

_A word of caution: after this script complete, and even though it will appear that everything functions 100% (which superficially speaking at last, it will), be aware you are NOT "good to go" yet. There are bugs in the named release that will prevent many of the necessary and very rudimentary system admin functions like say, "update", from working correctly. These bugs are documented and addressed in my downstream repos. Again, the only goal of this script is to get a pristine instance up and running with the minimum of steps._


### How This Script Fits Into The Bigger Picture
To create a fully customized ready-to-run production instance of Open edX I've found it to be best practice to start with an AWS AMI of a pristine (ie unaltered) single-server full stack instance of Open edX. I've found it relatively painless to instantiate this pristine image, and then configure it as necessary for my needs. Incidentally, I use this image as my starting point for both production full stack implementations as well subsystem clusters. I use an AMI resulting from this script for the following:
1. Full Stack deployments: Configuring the pristine instance is simple (read more below)
2. Creating Subsystem Clusters: with Open edX I've found it easier to pare down a full stack than to attempt to build up from scratch. I create specialized permutations of the full-stack installation for scaling purposes, such as:
  - a dedicated Forum server
  - a common cluster
  - standalone MySQL and MongoDB environments
  - a dedicated RabbitMQ server or XQueue server
  - common web server & memcached cluster




### Open edX Github Repositories
This installation script will download exactly two repositories:
 - The Open edX platform: https://github.com/edx/edx-platform
 - the official installation scripts: https://github.com/edx/configuration
edX uses github tags with both of these repositories to point to named releases. You'll find the various named releases and their various github tag names here: https://openedx.atlassian.net/wiki/spaces/DOC/pages/11108700/Open+edX+Releases

Note that https://github.com/edx is the official repository organization for Open edX software. Also note that there are a gazillion repos in this organization. Peruse, download and experiment with these at your own peril. And at any rate, keep in mind that the only two repos you need in order to stand up your instance are the two listed above -- the names and purposes of which i assume will never change in future.

The script installs a multitude of subsystems, including:

| |  |  |
| :------------ | -------------: | -------------: |
|   pip |   prettytable==0.7.2 |  RabbitMQ |
|   ansible==2.2.0.0 |   awscli==1.11.58 |   python-simple-hipchat==0.2 |   
|   PyYAML==3.12 |   requests==2.9.1 | MongoDB |
|   Jinja2==2.8 |   datadog==0.8.0 |   docopt==0.6.1 |
|   MarkupSafe==0.23 |   networkx==1.11 |   MySQL |
|   boto==2.48.0 |   pathlib2==2.1.0 |   wsgiref==0.1.2 |
|   ecdsa==0.11 |   boto3==1.4.4 |    Ngnx |
|   paramiko==2.0.2 |   pymongo==3.2.2 | MySQL-python==1.2.5 |
|   pycrypto==2.6.1 |   Elastic Search | memcached |

And others

### Important edX Platform Folders
The complete platform creates a labyrinth of folders within /edx. However, a short list of these are of particular interest, and are worth the time it takes to explore in order know each's contents.
 - `/edx/app` - application software files for all edx modules
 - `/edx/app/edx_ansible/edx_ansible/playbooks` - all Ansible playbooks. You'll learn a lot about how Ansible works simply by learning more about its folder structure.
 - `/edx/app/edx_ansible` - location to store server-vars.yml (further described in downstream repos)
 - `/edx/app/edxapp/edx-platform/themes` - app theme home folder. Exploring these folders will help to crystalize how Open edX's theming architecture works.
 - `/edx/bin` - "home" folder for all pip, ansible and bash admin utilities
 - `/edx/etc` - configuration files for all edx modules
 - `/edx/var` - all data (app, logs, etcetera)




### Words of Advice
The installation scripts are based nearly entirely on Ansible playbooks and bash scripts. In both cases the Open edX devops team pushes the envelope on what these technologies can do. As impressive as this is from a technology professional's perspective, it's daunting to wrap your head around what this code does at ground level. I leave you with two suggestions:
1. Build your pristine AMI from a named release. This script is pre-initialized to open-release/ginkgo.1. Using a named release as a base will make online documentation more relevant, and accurate, which might make the difference between you understanding what you've just installed (or not).
2. Review the scripts before executing. This install script calls four bash scripts written by Ned. To avoid future brain damage, invest the time necessary to get acquainted with what his scripts do.
3. Avoid modifying the code base. I understand that this is the beauty of open source programming, but, a) it's not necessary, and b) this platform is a beast: you're inviting misery upon yourself if you tinker.
4. Kubernetes. If you intend to create your own Open edX environment, for your institution's purposes, then it's unlikely that Kubernetes will figure into your devops strategy. However, here's a great starting point in the event that you want to dig deeper into the topic: https://www.appsembler.com/blog/open-edx-at-scale-using-kubernetes/. Keep in mind that Kubernetes are **experimental** with Open edX.

While the playbooks are challenging to read and understand, I can vouch that they all work as intended; at least, during the initial installation. Future admin activities to fire-up, shut-down, upgrade, downgrade the various subsystems also depend on use of these playbooks, so, do not attempt to circumvent using these or you will regret it.




### Additional Resources
1. Platform Documentation: http://edx.readthedocs.io/projects/edx-installing-configuring-and-running/en/latest/
2. Building and Running an edX Course: http://edx.readthedocs.io/projects/open-edx-building-and-running-a-course/en/latest/
3. Managing Open edX Tips & Tricks: https://openedx.atlassian.net/wiki/spaces/OpenOPS/pages/60227913/Managing+OpenEdX+Tips+and+Tricks
3. Native Installation documentation: https://openedx.atlassian.net/wiki/spaces/OpenOPS/pages/146440579/Native+Open+edX+Ubuntu+16.04+64+bit+Installation
4. edX Helper Tools Wiki page: https://github.com/edx/edx-tools/wiki
5. How to make SMTP mail work on Open edX: https://openedx.atlassian.net/wiki/spaces/OpenOPS/pages/64913413/How+to+make+SMTP+work+in+your+Open+EdX+fullstack+instance

### Downstream Repositories
1. Instantiate New EC2 from AMI -- With server-vars.yml (coming soon)
2. Upgrade edX-Platform to latest verson (coming soon)
3. Create Common Cluster from AMI (coming soon)
4. Create RabbitMQ and Celery workers cluster (coming soon)
5. Create MySQL on RDS and migrate (coming soon)
6. Create MongoDB on EC2 and migrate
