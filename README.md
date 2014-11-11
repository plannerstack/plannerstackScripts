plannerstackScripts
===================

Some simple scripts for building and deploying


h2. Example usage of build_new_otp_graph_from_sources.sh

- runningDirectory
	|
	 - plannerstackScripts
	|
	 - OpenTripPlannerMaster
	|
	 - graphBuildFiles

$ bash plannerstackScripts/build_new_otp_graph_from_sources.sh \
	OpenTripPlannerMaster/target/otp.jar \
	graphBuildFiles/ 

$ bash plannerstackScripts/run_otp.sh \
	openTripPlannerMaster/target/otp.jar \
	graphBuildFiles/ \
	plannerstackScripts/defaultConfigs/Graph.properties
