---
layout: post
title:  "REST alternative"
date:   2017-11-25 11:41:23
categories: web-programming
excerpt: "using asynchronous messaging instead of HTTP request/response in a distributed system"
tags:
  - kafka
  - rest
  - microservice
  - broker
  - message
  - standard
  - protocol
  - http
---

Here's an example of a distributed system using REST for inter-service communication:

- A user has come to an online travel booking platform and purchased some airline tickets
- the UI communicates user actions to a `Booking Gateway` backend service
- The UI puts a loading spinner on the screen until `Booking Gateway` responds
- meanwhile, the `Booking Gateway` service sends a http `POST` request to the `Ticket Service` to confirm the tickets are available
- `Booking Gateway` waits for a response from `Ticket Service`
- Once a response is received, `Booking Gateway` then makes a `POST` request to the `Billing Service` to charge the card
- `Booking Gateway` waits for a response from `Billing Service`
- Once a response is received, `Booking Gateway` finally updates the UI which removes the spinner and prints a confirmation.
- `Booking Gateway` also sends a HTTP request to the `Email Service` to send user a confirmation

![rest diagram](/media/rest_version.png)

##### please forgive the amateur diagram - I'm an engineer not an architect

--

Here are the key points that make this RESTful:
- the services are using synchronous HTTP request/response communication
- services own their own "resources", aka business objects, and they take requests to modify those object. (i.e. create a new credit card charge etc.)

The obvious issue to me here is that one link can break the chain.  Say for example the tickets are available, but the `Billing Service` is already overwhelmed with requests and a 503 `Unavailable` response is received.  What happens to the user experience?  

There are many way to handle this.  One is to implement an alternative protocol for service communication using 1-way, Asynchronous messaging similar to the one seen in my [`Mesos` example](/environment/2017/10/25/diy-mesos-framework-part-1.html) a few weeks back.

In this new approach, services communicate thru a message broker, such as Kafka, instead of direct HTTP calls.  Here's how it might look:

- A user has come to an online travel booking platform and purchased some airline tickets
- the UI communicates user actions to a `Booking Gateway` service
- `Booking gateway` responds immediately to the UI request and creates transaction (with a UUID) and puts it into a "pending" state
- User is informed their transaction is pending - no loading spinner needed
- `Booking gateway` drops a message into the `Tickets` topic about this order
- `Tickets` topic is consumed by `Ticket Service`
- `Ticket Service` processes the request and drops a response in the `Order Updates` topic
- `Booking Gateway` consumes the `Order Updates` topic
- Once `Booking Gateway` gets an update on the transaction, it changes the internal state for the order and sends a new message to the `Billing` topic
- Meanwhile, the UI can poll the `Booking Gateway` and find out that its order has changed state
- `Billing Service` consumes from `Billing` topic, processes the message and drops an update in the `Order Updates` topic when finished
- `Booking Gateway` service consumes the message, updates the order state and sends a message to the `Email` topic

![broker diagram](/media/broker_version.png)

##### holy shit that is a crappy diagram - don't quit your day job

--

In this new pattern, we have `Actors` sending `Messages` to topics and then moving on to their next order of business.  There's no waiting around for a response, or breaking when another service is down (unless the messaging broker system is down...that's a whole another situation)

The nice thing about this model is that messages are not lost in the HTTP abyss if a service call fails...messages live in topics and consumers can come back online and continue reading them, never missing a message.  This means the state of the system will "eventually" be correct.   Additionally the state of the system is easy to reason about by checking expected state against actual state using consumer offsets for example.

--

Diagrams made on [https://www.youidraw.com/](https://www.youidraw.com/)










CREATE TABLE streaming_update_table (
  id serial PRIMARY KEY,
  data varchar(256) NOT NULL,
  is_soft_deleted boolean default false,
  create_date timestamp NOT NULL default now(),
  last_updated timestamp NOT NULL default now()
);

CREATE OR REPLACE FUNCTION update_last_updated_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.last_updated = now();
  RETURN NEW;
END;
$$ language 'plpgsql';

## CREATE TRIGGER
CREATE TRIGGER update_last_updated_column
BEFORE UPDATE ON streaming_update_table
FOR EACH ROW EXECUTE PROCEDURE update_last_updated_column();

INSERT INTO streaming_update_table (data) values ('testing');

UPDATE streaming_update_table
SET data = 'some new data'
WHERE id = 1;
