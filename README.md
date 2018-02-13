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

Detailed instructions are now located in this blog article, [Open edX Step-By-Step Production Installation Guide](https://blog.lawrencemcdaniel.com/open-edx-installation/)

**Contributors are welcome. My contact information is on my web site.**

Lawrence McDaniel | https://lawrencemcdaniel.com
