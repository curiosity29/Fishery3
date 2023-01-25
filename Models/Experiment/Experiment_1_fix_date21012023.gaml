/**
 * fixed amount of fish with random place for each fish in each step
 * save the variance of fish around each fish
 */



model Experiment1date21012023

global torus: true
{
	int simulation_index <- 2101202305;
	int fish_local_density_radius <- 10;
	int nb_fish <- 100;
	list<int> dens_list;
	list<float> var_list;
	string fileName <- "../includes/results/Capacity/Variance_" +simulation_index+ ".csv";
	init
	{ create fish number: nb_fish; }
	reflex save_variance
	{
		ask fish { dens_list <+ 1 + length(fish at_distance fish_local_density_radius); }
		var_list <+ variance(dens_list);
		dens_list <- [];
	}
	reflex save_result when: cycle = 502
	{
		save [nb_fish, fish_local_density_radius, var_list]
		to: fileName type: "csv" rewrite: false header: false;
	}
}

species fish
{
	reflex move {location <- any_point_in(world);}
}

experiment "21012023" type: batch until: cycle > 502
{
	parameter "number of fish" var: nb_fish min: 100 max: 1100 step: 100;
	parameter "fish_local_density_radius" var: fish_local_density_radius min: 5 max: 55 step: 5; 
}
/* Insert your model definition here */

