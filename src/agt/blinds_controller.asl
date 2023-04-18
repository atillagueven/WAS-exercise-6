// blinds controller agent

/* Initial beliefs */

// The agent has a belief about the location of the W3C Web of Thing (WoT) Thing Description (TD)
// that describes a Thing of type https://was-course.interactions.ics.unisg.ch/wake-up-ontology#Blinds (was:Blinds)
td("https://was-course.interactions.ics.unisg.ch/wake-up-ontology#Blinds", "https://raw.githubusercontent.com/Interactions-HSG/example-tds/was/tds/blinds.ttl").

// the agent initially believes that the blinds are "lowered"
blinds("lowered").

/* Initial goals */ 

// The agent has the goal to start
!start.

/* 
 * Plan for reacting to the addition of the goal !start
 * Triggering event: addition of goal !start
 * Context: the agents believes that a WoT TD of a was:Blinds is located at Url
 * Body: greets the user
*/
@start_plan
+!start : td("https://was-course.interactions.ics.unisg.ch/wake-up-ontology#Blinds", Url) <-
    makeArtifact("blinds", "org.hyperagents.jacamo.artifacts.wot.ThingArtifact", [Url], ArtId);
    .print("Hello world").

@blinds_state_plan
+!set_blinds_state(State) : true <-
    invokeAction("https://was-course.interactions.ics.unisg.ch/wake-up-ontology#SetState",  ["https://www.w3.org/2019/wot/json-schema#StringSchema"], [State])[ArtId];
    .wait(2000);
    -+blinds(State);
    .print("Set the blinds to the according State: ", State);
    .send(personal_assistant, tell, blinds(State)).

@lowering_blinds_plan
+!lower_blinds : true <-
    set_blinds_state("lowered").

@raising_blinds_plan
+!raise_blinds : true <-
    set_blinds_state("raised").

@blinds_plan
+blinds(State) : true <-
    .print("State of the blinds is ", State).

@wake_method_plan
+!wake_method : blinds("lowered") <-
    .send(personal_assistant, tell, wake_method("blinds")).

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