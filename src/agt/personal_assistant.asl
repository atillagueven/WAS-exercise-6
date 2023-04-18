// personal assistant agent

wake_owner_up :- upcoming_event(UpcomingEvent) & owner_state(State) & Event == "now" & State == "asleep".
all_good :- upcoming_event(UpcomingEvent) & owner_state(State) & Event == "now" & State == "awake".

appropriate_wake_method("lights") :- wake_method("lights") & wake_up_artificial_light(X) & wake_up_natural_light(Y) & X < Y.
appropriate_wake_method("blinds") :- wake_method("blinds") & wake_up_artificial_light(X) & wake_up_natural_light(Y) & X > Y.

wake_up_natural_light(0).
wake_up_artificial_light(1).

// The agent has the goal to start
!start.

/* 
 * Plan for reacting to the addition of the goal !start
 * Triggering event: addition of goal !start
 * Context: true (the plan is always applicable)
 * Body: greets the user
*/
@start_plan
+!start : true <-
    .print("Hello world");
    !setupDweet;
    .wait(2000);
    publish("Hello Dweet!").


@wake_owner_up_plan
+!wakeOwner : wake_owner_up <-
    .broadcast(askAll, wake_method, Answers);
    !use_answer(Answers)
    .print("Wake owner up with one of the following wake up methods ", Answers).

@select_wake_method_plan
+!use_answer(Answers) : true <-
    .print("Here you go...").

@owner_awake_plan
+!ownerAwake : all_good <-
    .print("Enjoy your event").


@create_dweet_plan
+!setupDweet : true <- 
    makeArtifact("dweet","room.DweetArtifact",[], DweetId);
    focus(DweetId);
    .print("Made artifact").


/* Import behavior of agents that work in CArtAgO environments */
{ include("$jacamoJar/templates/common-cartago.asl") }