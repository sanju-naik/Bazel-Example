# Simple State Sync Service (S4)

Hello, Comrade Trooper! Simple State Sync Service enables syncing a state to a user or a group of users. By Syncing
state, it becomes available for querying locally on the user's phone using the S4 SDK. The philosophy behind S4 is
that any state needed by mobile apps should be stored in the mobile app. Backend services only push states to S4 and
don't need to worry about storing or syncing this state to users.

Comrade, it's time we free our app from the ever-increasing calls on app launch, slow loading, and continuous polling.

All hail the user :raised_hands:

## Basic concepts

1. **State:** A versioned state for a user or a group of users. A state is identified by a `StateId` and is organized
   into Collections. The state version increments whenever a mutation happen to any of the documents in it.
2. **Collection:** A set of Documents. A collection is identifiable by its unique `Name`.
3. **Document:** An entity to be synced to the user.
   Documents have the following properties:
    1. `DocId`: A unique identifier for the document in a collection.
    2. `ExpiresAt`: a timestamp after which the document expires.
    3. `Content`: Byte array
4. **Snapshot:**  Base document of all collections for a given state.
   Snapshot have the following properties:
    1. `Version`: Version of base document
    2. `Documents`: List of documents at particular version
5. **Mutation:** An operation to change a single document.
   Mutation captures following properties:
    1. `StateVersion`: Version of the document
    2. `Type`: Type of mutation (explained below)
    3. `Doc`: Document (explained above)

   There are exactly two types of mutations:
    1. `Upsert`: Adds or Updates a document with some new content.
    2. `Delete`: Deletes an existing document from the State

Example:
If we were to store Push Notifications (PN) sent to a particular Device into S4 to be synced, we would map concepts in following way:
1. **State:** Device, with `StateId` being DeviceId (each client syncs state based on local version of state & upstream version)
2. **Collection:** Push Notification (so other use-cases for the Device could be modelled into separate collections, e.g. Inbox)
3. **Document:** Notification, with `DocId` being NotificationId (each notification is a separate document)
4. **Snapshot:** All Notifications & other Documents from other Collections for given DeviceId
5. **Mutation:** Updates to Notifications (sent, delivered, deleted)

## System Architecture

![S4 Architecture](docs/images/adr_004_approach_05_01.svg)

Architectural Decision Records (ADRs) related to S4 please check [this folder](docs/adrs)

## Running S4 Locally

You can run the full S4 architecture locally on your laptop. you just need to have docker-compose installed and then
execute the command `make run`. Gate would then be accessible at localhost:8080 for gRPC connection and localhost:8081
for REST api. You can drop [gate swagger](docs/openapiv2/gate/gate.swagger.json) in your postman and start playing
around!

To run S4 tests, you can execute the command `make test`

## When do state get synced to users?

S4 syncs state as soon as possible. When the app launches, S4 Mobile SDK establishes makes a call to S4 (gRPC) to
get:
1. All incremental changes that happened since last synced state version.
2. Address of MQTT broker and topic for receiving live incremental changes to the state.

The mobile SDK, will apply the changes to the state, establish a persistent MQTT connection, and subscribe to the state
topic to start receiving state changes and apply them near real-time. This mechanism enables sub-second latency from
the time S4 receives the state update to the time the user receives the state update on their phone.

## How does user state version get tracked?

A user's state is basically, a base snapshot of all the document collections and the list of mutations that were applied
after that base snapshot. Each mutation applied to the state increments the state version. When a new state is created,
its base snapshot is version 1 and only contains a single document. After the base snapshot, mutations are added on top.
Each additional mutation means a new version of the state. Fetching the state at a specific version is a matter of
applying all the mutations that happened on top of the base snapshot.

## How do users sync their state?

* The app maintains a local database containing the user's state in the form of collections of documents.
* The app also tracks the version of the state stored.
* When the app launches it calls S4 to fetch the changes that happened since it went offline and then opens a
  persistent MQTT connection to receive live changes while the app is in use.
* When a Mutator successfully applies a mutation to a state, it publishes the state changes to the MQTT server.

## FAQs

You can find list of all FAQs [here](https://source.golabs.io/s4-devs/s4/-/issues?scope=all&utf8=%E2%9C%93&state=closed&label_name[]=Question).
If you have a question, feel free to create a new issue in repository [here](https://source.golabs.io/s4-devs/s4/-/issues/new?issuable_template=question) and add the tag 'Question' to it
If you have ideas/suggestions, feel free to create them as issues [here](https://source.golabs.io/s4-devs/s4/-/issues/new?issuable_template=idea).

## S4 iOS
This project contains 3 submodules:

1. **gate-client**: contains Gate gRPC API client
2. **sdk**: S4 iOS SDK library
3. **example**: Example project that uses S4

## Updating Gate gRPC client
This can be done by running `./update-gate-client.sh`. You can optionally pass a tag or a branch,
if not it will default to master.