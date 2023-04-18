// lights controller agent

/* Initial beliefs */

// The agent has a belief about the location of the W3C Web of Thing (WoT) Thing Description (TD)
// that describes a Thing of type https://was-course.interactions.ics.unisg.ch/wake-up-ontology#Lights (was:Lights)
td("https://was-course.interactions.ics.unisg.ch/wake-up-ontology#Lights", "https://raw.githubusercontent.com/Interactions-HSG/example-tds/was/tds/lights.ttl").

// The agent initially believes that the lights are "off"
lights("off").

/* Initial goals */ 

// The agent has the goal to start
!start.

/* 
 * Plan for reacting to the addition of the goal !start
 * Triggering event: addition of goal !start
 * Context: the agents believes that a WoT TD of a was:Lights is located at Url
 * Body: greets the user
*/
@start_plan
+!start : td("https://was-course.interactions.ics.unisg.ch/wake-up-ontology#Lights", Url) <-
    makeArtifact("lights", "org.hyperagents.jacamo.artifacts.wot.ThingArtifact", [Url], ArtId);
    .print("Started Light Controller").

@set_lights_state_plan
+!set_lights_state(State) : true <-
    invokeAction("https://was-course.interactions.ics.unisg.ch/wake-up-ontology#SetState",  ["https://www.w3.org/2019/wot/json-schema#StringSchema"], [State])[ArtId];
    .wait(2000);
    .print("Set lights to state ", State);
    -+lights(State);
    .send(personal_assistant, tell, lights(State)).

@put_lights_on_plan
+!lights_on : true <-
    set_lights_state("on").

@put_lights_off_plan
+!lights_off : true <-
    set_lights_state("off").

@lights_plan
+lights(State) : true <-
    .print("State of the lights is: ", State).

@wake_method_plan
+!wake_method : lights("off") <-
    .send(personal_assistant, tell, wake_method("lights")).

@cfp_reject
+cfp("wakeUp")[source(Controller)] : lights("on") <- 
    .print("received cfp, but lights are already on");
    -cfp("wakeUp")[source(Controller)];
    .send(Controller, tell, refuse("wakeUp")).

@cfp_propose
+cfp("wakeUp")[source(Controller)] :  lights("off") <- 
    .print("received cfp for waking up", "lights");
    -cfp("wakeUp")[source(Controller)];
    .send(Controller, tell, propose("lights")[cfp("wakeUp")]).

@got_accept
+accept_proposal(Proposal)[source(Controller)] : true <-
    .print("Nice, good morning!");
    -accept_proposal(Proposal)[source(Controller)];
    !exec_proposal(Proposal)[source(Controller)].

@got_rejection
+reject_proposal(Proposal)[source(Controller)] : true <-
    .print("Wake up!", Controller);
    -reject_proposal(Proposal)[source(Controller)].

@exec_proposal
+!exec_proposal(Proposal)[source(Controller)]: true <-
    .print("executing Proposal");
    !lights_on;
    +send_success(Proposal)[source(Controller)].

@send_success
+send_success(Proposal)[source(Controller)]: true <-
    .print("success sent");
    .send(Controller, tell, inform_done(Proposal));
    ?lights(Res);
    .print("now the state is: ", Res);
    .send(Controller, tell, inform_result(Res)).

@send_failure_plan
+send_failure(Proposal)[source(Controller)] : true <-
    .print("fail sent");
    .send(Controller, tell, failure(Proposal)).

/* Import behavior of agents that work in CArtAgO environments */
{ include("$jacamoJar/templates/common-cartago.asl") }