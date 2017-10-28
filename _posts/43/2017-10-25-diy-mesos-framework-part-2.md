---
layout: post
title:  "D.I.Y. mesos framework part 2"
date:   2017-10-25 22:25:24
categories: environment
excerpt: "using the Mesos API to accept offers, launch tasks, kill tasks and send acks"
tags:
- apache
- mesos
- docker
- cloud
---

[Last time](/environment/2017/10/25/diy-mesos-framework-part-1.html) we launched a simple Mesos framework.  Now let's see how to interact with it.

### Prequisite
**Must complete all the steps from [Part One](/environment/2017/10/25/diy-mesos-framework-part-1.html)**

### Accept an offer and launch a task

The next step is to accept the offer from the Mesos Master and launch a custom task on our running Mesos agent.  This brings us into contact with another part of the Mesos architecture: an Executor.  An Executor is the process on the Mesos agent which is used to launch and monitor a task.  While it is possible to write a custom Executor, for this example we'll just be using the Mesos provided one.

[From the docs:](http://mesos.apache.org/documentation/latest/app-framework-development-guide/#using-the-mesos-command-executor)
> Mesos provides a simple executor that can execute shell commands and Docker containers on behalf of the framework scheduler; enough functionality for a wide variety of framework requirements.

To use the default executor, we simply need to include a `command` as a top-level field under `task_infos`.  If we wanted to use a custom executor, we would nest `command` inside an `executor` node.

Command below.  Remember to update the values for:
{% highlight bash %}
mesos-stream-id
framework_id
offer_ids
agent_id
{% endhighlight %}

In terminal 4:

(due to the size of this outrageous JSON blob I recommend dropping this command into POSTMAN to avoid weird copy/paste issues in a terminal)

{% highlight bash %}
curl -X POST \
  http://localhost:5050/api/v1/scheduler \
  -H 'content-type: application/json' \
  -H 'mesos-stream-id: 274bcc35-78db-42ac-8a10-b02944c5a6eb' \
  -d '{
    "framework_id": {
      "value": "089a7212-4aba-4aac-8425-7337161ece30-0000"
    },
    "type": "ACCEPT",
    "accept": {
      "offer_ids": [
        {
          "value": "089a7212-4aba-4aac-8425-7337161ece30-O0"
        }
      ],
      "operations": [
        {
          "type": "LAUNCH",
          "launch": {
            "task_infos": [
              {
                "name": "My Task",
                "task_id": {
                  "value": "shell hello world loop"
                },
                "agent_id": {
                  "value": "089a7212-4aba-4aac-8425-7337161ece30-S0"
                },
                "command": {
                  "shell": true,
                  "value": "echo starting; while [[ 1 -eq 1 ]]; do echo helloWorld; sleep 5; done"
                },
                "resources": [
                  {
                    "allocation_info": {
                      "role": "hello_world_role"
                    },
                    "name": "cpus",
                    "role": "*",
                    "type": "SCALAR",
                    "scalar": {
                      "value": 1
                    }
                  },
                  {
                    "allocation_info": {
                      "role": "hello_world_role"
                    },
                    "name": "mem",
                    "role": "*",
                    "type": "SCALAR",
                    "scalar": {
                      "value": 128
                    }
                  }
                ]
              }
            ]
          }
        }
      ],
      "filters": {
        "refuse_seconds": 5
      }
    }
  }'
{% endhighlight %}

Mesos responds with a `202` indicating that it Accepted the request but has not processed it.  This is a good example of the Actor model, one-way communication implemented by Mesos.  

Flipping thru the open terminals here is some interesting output:

Master node:
{% highlight bash %}
Status update TASK_RUNNING (UUID: 3abe8974-9d80-4374-9025-aae5d37cda1f) for task shell hello world loop of framework
Forwarding status update TASK_RUNNING (UUID: 3abe8974-9d80-4374-9025-aae5d37cda1f)
{% endhighlight %}

In our Framework terminal:
{% highlight bash %}
"type":"UPDATE" ... "state":"TASK_RUNNING" ...
{% endhighlight %}

Back in the browser at [http://localhost:5050/#/](http://localhost:5050/#/), we should see the `shell hello world loop` task under active tasks!  Clicking into the sandbox, then the `stdout` will reveal our looping terminal output.  

We've just deployed a task!  Are you feeling the cloud??

### Acknowledge a status update from Mesos

To be a good citizen we need to acknowledge the status update from Mesos. (the Framework terminal will indicate that )

In Terminal 4:
{% highlight bash %}
curl -X POST \
  http://localhost:5050/api/v1/scheduler \
  -H 'content-type: application/json' \
  -H 'mesos-stream-id: 6c83f87e-e1d2-47c7-be1f-43f71d4794a6' \
  -d '{
    "framework_id": {
      "value": "f6480abb-914d-47e4-a802-b123c7925e7a-0000"
    },
    "type": "ACKNOWLEDGE",
    "acknowledge"     : {
      "agent_id"  :  {"value" : "f6480abb-914d-47e4-a802-b123c7925e7a-S0"},
      "task_id"   :  {"value" : "shell hello world loop"},
      "uuid"      :  "F+lGzCYnTam7KN0gWOq+6w=="
    }
  }'
{% endhighlight %}

Flipping to the Master node terminal:
{% highlight bash %}
Processing ACKNOWLEDGE call
{% endhighlight %}

Nice.

### Launch a Docker container

Now scroll back up a bit and you will find another Offer from the Mesos master.  Let's accept that offer and launch a Docker task!

{% highlight bash %}
curl -X POST \
  http://localhost:5050/api/v1/scheduler \
  -H 'content-type: application/json' \
  -H 'mesos-stream-id: 274bcc35-78db-42ac-8a10-b02944c5a6eb' \
  -d '{
    "framework_id": {
      "value": "089a7212-4aba-4aac-8425-7337161ece30-0000"
    },
    "type": "ACCEPT",
    "accept": {
      "offer_ids": [
        {
          "value": "089a7212-4aba-4aac-8425-7337161ece30-O1"
        }
      ],
      "operations": [
        {
          "type": "LAUNCH",
          "launch": {
            "task_infos": [
              {
                "name": "nginx",
                "task_id": {
                  "value": "nginx"
                },
                "agent_id": {
                  "value": "089a7212-4aba-4aac-8425-7337161ece30-S0"
                },
                "command": {
                  "shell": true,
                  "value": "docker run --name mesos-nginx -p 8080:80 nginx"
                },
                "resources": [
                  {
                    "allocation_info": {
                      "role": "hello_world_role"
                    },
                    "name": "cpus",
                    "role": "*",
                    "type": "SCALAR",
                    "scalar": {
                      "value": 1
                    }
                  },
                  {
                    "allocation_info": {
                      "role": "hello_world_role"
                    },
                    "name": "mem",
                    "role": "*",
                    "type": "SCALAR",
                    "scalar": {
                      "value": 128
                    }
                  }
                ]
              }
            ]
          }
        }
      ],
      "filters": {
        "refuse_seconds": 5
      }
    }
  }'
{% endhighlight %}

Now [http://localhost:8080/](http://localhost:8080/) will show nginx running on our system!  Sweet.


### Decline an offer

back in Terminal 4:
{% highlight bash %}
curl -X POST \
  http://localhost:5050/api/v1/scheduler \
  -H 'content-type: application/json' \
  -H 'mesos-stream-id: 274bcc35-78db-42ac-8a10-b02944c5a6eb' \
  -d '{
    "framework_id": {
      "value": "089a7212-4aba-4aac-8425-7337161ece30-0000"
    },
    "type": "DECLINE",
    "decline"         : {
      "offer_ids" : [
                      {"value" : "089a7212-4aba-4aac-8425-7337161ece30-O4"}
                    ],
      "filters"   : {"refuse_seconds" : 5.0}
    }
  }'
{% endhighlight %}


### Kill a task
back in Terminal 4:
{% highlight bash %}
curl -X POST \
  http://localhost:5050/api/v1/scheduler \
  -H 'content-type: application/json' \
  -H 'mesos-stream-id: 274bcc35-78db-42ac-8a10-b02944c5a6eb' \
  -d '{
    "framework_id": {
      "value": "089a7212-4aba-4aac-8425-7337161ece30-0000"
    },
    "type": "KILL",
    "kill"            : {
      "task_id"   :  {"value" : "nginx"},
      "agent_id"  :  {"value" : "089a7212-4aba-4aac-8425-7337161ece30-S0"}
    }
  }'
{% endhighlight %}

{% highlight bash %}
Processing KILL call for task 'nginx'
Telling agent 089a7212-4aba-4aac-8425-7337161ece30-S0 at slave(1)@192.168.1.12:5051 (192.168.1.12) to kill task nginx
{% endhighlight %}

(note that the Task stays in "active" status in the UI, until we acknowledge the update from the Mesos master.)

--

**fin**
