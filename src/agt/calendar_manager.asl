// calendar manager agent

/* Initial beliefs */

// The agent has a belief about the location of the W3C Web of Thing (WoT) Thing Description (TD)
// that describes a Thing of type https://was-course.interactions.ics.unisg.ch/wake-up-ontology#CalendarService (was:CalendarService)
td("https://was-course.interactions.ics.unisg.ch/wake-up-ontology#CalendarService", "https://raw.githubusercontent.com/Interactions-HSG/example-tds/was/tds/calendar-service.ttl").

/* Initial goals */ 

// The agent has the goal to start
!start.

/* 
 * Plan for reacting to the addition of the goal !start
 * Triggering event: addition of goal !start
 * Context: the agents believes that a WoT TD of a was:CalendarService is located at Url
 * Body: greets the user
*/
@start_plan
+!start : td("https://was-course.interactions.ics.unisg.ch/wake-up-ontology#CalendarService", Url) <-
    .print("Hello world");
    makeArtifact("calendar", "org.hyperagents.jacamo.artifacts.wot.ThingArtifact", [Url], ArtId);
    !read_upcoming_event. // creates the goal !read_upcoming_event

@read_upcoming_event_plan
+!read_upcoming_event : true <-
    // performs an action that exploits the TD Property Affordance of type was:ReadUpcomingEvent 
    // the action unifies UpcomingEventLst with a list holding the owner's state, e.g. ["asleep"]
    readProperty("https://was-course.interactions.ics.unisg.ch/wake-up-ontology#ReadUpcomingEvent",  UpcomingEventLst);
    .nth(0,UpcomingEventLst,UpcomingEvent); // performs an action that unifies UpcomingEvent with the element of the list OwnerStateLst at index 0
    -+upcoming_event(UpcomingEvent); // updates the beleif owner_state 
    .send(personal_assistant, tell, upcoming_event(UpcomingEvent)). // creates the goal !read_owner_state

@upcoming_event_plan
+upcoming_event(UpcomingEvent) : true <-
    .print("Upcoming event is ", UpcomingEvent).

/* Import behavior of agents that work in CArtAgO environments */
{ include("$jacamoJar/templates/common-cartago.asl") }
