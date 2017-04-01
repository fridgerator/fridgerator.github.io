---
layout: post
title:  "Deploying A Crystal Application to AWS Elastic Beanstalk With Docker"
date:   2017-03-30 15:57:00 -0600
comments: true
disqus_url: "http://fridgerator.github.io/2017/03/30/deploying-a-crystal-application-to-aws-elastic-beanstalk-with-docker.html"
disqus_identifier: "/2017/03/30/deploying-a-crystal-application-to-aws-elastic-beanstalk-with-docker.html"
---

![more beer](http://i.imgur.com/cM4EZnH.jpg)

I recently had to deploy an application which uses [Crystal](https://crystal-lang.org/) and [Kemal](http://kemalcr.com/), and wanted to document my experience in case it can benefit others.  I generally prefer utilizing [Amazon AWS](https://aws.amazon.com/) when deploying services, [Elastic Beanstalk](https://aws.amazon.com/elasticbeanstalk/) makes deploying scalable web applications especially easy.  I've created an open source application with some of the code [here](https://github.com/fridgerator/crystal-elastic-beanstalk-deploy-example).  I've also picked up a 12er of New Belgium VooDoo Ranger and a Mikes Harder strawberry lemonade, and I suggest you do the same. Judge me... I don't care.

I initially had a single Dockerfile that would build and serve the application, but I wanted to run on a smaller t2.micro instance size and ran into out of memory errors when compiling the application. What I ended up with was a two step build process:  One Docker container only run locally to build the executables and the Dockerfile deployed to AWS, its only job is to serve the already compiled application.  I actually like this better because building locally doesn't take long, and re-deploying on elastic beanstalk literally takes seconds.  You can [cross compile](https://crystal-lang.org/docs/syntax_and_semantics/cross-compilation.html) crystal but I went this route instead, because Docker is cool yo.

#### BuildDockerfile

The [BuildDockerfile](https://github.com/fridgerator/crystal-elastic-beanstalk-deploy-example/blob/master/docker/BuildDockerfile) installs some system libraries, adds the necessary files to compile the application and compiles.  Running the BuildDockerfile just copies the compiled application to an attached volume on the host computer.

You might notice some [funny business](https://github.com/fridgerator/crystal-elastic-beanstalk-deploy-example/blob/master/docker/BuildDockerfile#L22) going on in there.  I'm greedy and I wanted to run multiple application processes per container, handled by [server.cr](https://github.com/fridgerator/crystal-elastic-beanstalk-deploy-example/blob/master/src/EBTest/server.cr) and [cluster.cr](https://github.com/fridgerator/crystal-elastic-beanstalk-deploy-example/blob/master/src/EBTest/cluster.cr).  Crystal's [`HTTP::Server#listen`](https://crystal-lang.org/api/0.21.1/HTTP/Server.html#listen%28reuse_port%3Dfalse%29-instance-method) has an optional argument `reuse_port` which makes use of the linux kernels [`SO_REUSEPORT`](https://lwn.net/Articles/542629/) socket option, allowing you to bind multiple application instances to the same port.  So this hack is just to change the kemal.cr `server.listen` to pass `true` for the `reuse_port` option before compiling.

#### Dockerfile and deployment

The [Dockerfile](https://github.com/fridgerator/crystal-elastic-beanstalk-deploy-example/blob/master/docker/Dockerfile) just copies the built executable and runs it, nothing fancy going on there.  I created a [helper script](https://github.com/fridgerator/crystal-elastic-beanstalk-deploy-example/blob/master/bin/deploy) to do all of this, and spit out a zip file which can be uploaded to Elastic Beanstalk.  It builds the BuildDockerfile then runs it binding  the `./build/` folder as a volume.  Then zips all the require files into a single archive.

Deployment is simple.  Create an Elastic Beanstalk application and web server environment, choose Generic Docker platform and upload the build zip file, and thats it!

I hope this helps others who might be trying to accomplish some of the same problems.  As always feedback or harsh criticism is accepted and welcome.

DRINK UP!