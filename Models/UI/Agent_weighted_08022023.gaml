
model Experiment1display

global torus: true
{
	// please manually change to "global torus: true" with sphere_map = true, same with false
	bool sphere_map <- true;
	
	bool random_birth_location <- false;
	
	float fish_speed <- 5.0;
	int fish_move_rate <- 1;
	
	string description <- "experiment january 17 with torus environment, vary fish movement speed and random birth location = true or false, repeat 10 times with increasing local density from 6 to 60";
	string today <- "17012023";
	string simulation_index <- today + "02" ;
	
	// number of repeat with same parameter - still bug with value # 10
	int repeat_number <- 10;
	//	local capacity - workaround because still bug
	int index_1 <- 0;
	int index_2 <- 0;
	int index_repeat <- 0;
//	float fish_local_cap <- index_1 * 5.5 + index_2 * 0.5 + 1;


	reflex
	{
		ask fish { if self.dead = true {do die;}}
		ask fish { do reproduce;}
		ask fish { do change_weight;}
		ask fish { do split;}
		ask fish { do fish_move;}
	}

	
// system
	float pi <- 3.141592;
	int rep <- 0;
	int cycle_max <- 20000;
//	int cycle_min <- cycle_max/2;
	float map_size <- 100.0;

//	int fish_cap <- 1000;

	//growth rate - work fine if < 1
	float fish_reproduce_rate <- 0.01;
	
	float total_weight <- fish_number;
	float total_weight_prev;
	float total_weight_change;
	reflex update_total_weight
	{ 
		total_weight_prev <- total_weight;
		total_weight <- sum(fish collect each.weight);
		total_weight_change <- total_weight - total_weight_prev;
	}
	
	float fish_local_cap <- 15.0;
	float fish_local_density_radius <- 15.0; 
	
	
	// diff equation
	float K <-  fish_local_cap * 100 ^2/ pi/fish_local_density_radius^2;
	float k <- fish_local_cap;
	float binomialK <- K + 1 - K/k;
	float p <- k/K;
	float var <- 0.0;
	float delta <- 0.0;
	float root1 <- 0.0;
	float root1_average <- 0.0;
	list<float> dens_list;
	float dN_expected <- 0.0;
	float var_average;
	
	int fish_number <- 5;
	float r <- fish_reproduce_rate;
	list<float> dens_range <- [0, 1/4, 2/4, 3/4, 1, 5/4, 6/4, 7/4];
	float average_density <- 0.0;
	init
	{
	dens_range <- dens_range collect ((each+1/8) *k);
	
		create fish number: fish_number 
		with: (location: {rnd(100.0), rnd(100.0)});

	}
	string fileName <- "../includes/results/Capacity/" + "fish_average_" +simulation_index+ ".csv";
	reflex save_result when: cycle = cycle_max
	{
		save [fish_local_cap, fish_average, sphere_map, random_birth_location, fish_speed, fish_move_rate] 
		to: fileName type: "csv" rewrite: false;
	}
	
	
	float fish_average <- 0.0;
	int cycle_passed <- 0;
	int cycle_min <- 2000;
	//update current average (from cycle_min to now)
	reflex update when: cycle > cycle_min
	{
		cycle_passed <- cycle_passed + 1 ;
		fish_average <- (fish_average*(cycle_passed-1) + total_weight)/ cycle_passed;
		root1_average <- (root1_average*(cycle_passed-1) + root1)/ cycle_passed;	
		average_density <- (average_density*(cycle_passed-1) + mean)/ cycle_passed;	
	}
//	reflex stop_exp when: cycle > cycle_max
//	{
//		do pause;
//	}

	
	float mean <- 0.0;
	float dN_cut <- 0.0;
	float var_binomial <- 0.0;
	float var_moving_average;
	list<float> var_list;

	reflex calculate_var
	{
		ask fish { dens_list <+ 1 + length(fish at_distance fish_local_density_radius); }
		var <- variance(dens_list);
		mean <- mean(dens_list);
		var_list<+ var;
		// moving avg of var
		float sum <- 0.0;
		if cycle > 20
		{
			loop id from: length(var_list)-20 to: length(var_list)-1
			{
				sum <- sum + var_list[id];
			}
			var_moving_average <- sum / 20;
		}
		// end moving avg of var
		var_binomial <- total_weight*p*(1-p);

		dN_cut <- total_weight* (mean - (var + mean^2) / k);
		if cycle > cycle_min
		{var_average <- (var_average*(cycle_passed-1) + var)/ cycle_passed;	}
		delta <- 1 - 4 * var/k^2;
		if delta < 0 {root1 <- 0.0;}
		else {root1 <- 1/2 * K * (1 + sqrt(delta));}
		
		dens_list <- [];
	}
	
	float EN <- 0.0;
	reflex calculate_dN
	{
		EN <- total_weight*p;
		dN_expected <- -r/p/k * (EN^2 - k * EN + var);
	}
	
// chart name
//	string s <- "population with local capacity = "+ fish_local_cap + ", radius = "+ fish_local_density_radius ;
}

species fish skills: [moving] // parallel: true
{
	float weight <- 1.0;
	float local_density <- 1.0;
	float adjust_factor <- 1.0;
	bool dead <- false;
	float weight_gain;
	init
	{
		speed <- fish_speed;
	}

	aspect base {
		draw circle(0.5) color: color;
	}
	
	
	
	action fish_move {
		// random location
//		location <- any_location_in(world.shape);
		// normal movement
		loop times: fish_move_rate
		{do wander;}
	}
	
	action reproduce
	{
		
		local_density <- weight + sum( (fish at_distance fish_local_density_radius) collect (each.weight)) ;
		weight_gain <- fish_reproduce_rate * (1 - local_density/ fish_local_cap) * weight;
//		if reproduce_prob > 0
//		{
//			create fish with: (location: self.location, weight: reproduce_prob);
//		}
//		else if flip(-reproduce_prob)
//		{
//			dead <- true;
//		}
	}
	action change_weight
	{
		weight <- weight * (1+weight_gain);
	}
	action split
	{
		if weight > 1.5
		{
			create fish number: 2 with: (location: location, weight: weight/2);
			dead <- true;
		}
	}
	
}


experiment "display"
{

	output
	{
//		display map
//		{
//			species fish aspect: base;
//		}
//		monitor "average population" value: fish_average;
//		monitor "binomial capacity" value: binomialK;
//		monitor "average variance" value: var_average;
//		monitor "ideal capacity" value: K;
//		monitor "average root capacity" value: root1_average;
//		monitor "average local density" value: average_density;
//		monitor "average binomial density" value: fish_average*p;
//		monitor "dN expected" value: dN_expected;

		display population
		{
			chart "population" type: series
			{
				
				data "population" value: total_weight color: #blue;
				data "binomial capacity" value: binomialK color: #red;
				data "ideal capacity" value: K color: #green;
				data "average population" value: fish_average color: #black;
				data "root capacity" value: root1 color: #purple;
				data "dN expected" value: dN_expected/r color:#purple; 
//				data "dN relative value" value: dN_cut color: #black;
			}
		}
		display "variance"
		{
//				data "mean" value: mean color: #red;
//				data "Np" value: nb_fish*p color: #blue;
//				data "delta" value: mean - nb_fish*p color: #black;
//				data "1" value: 1 color: #black;

			chart "variance" type: series  
			{
				data "var binomial" value: var_binomial color: #red;
				data "var" value: var color: #blue;
//				data "moving average" value: var_moving_average color: #green;
				data "average variance" value: var_average color: #black;

			}
		}
//		display "local density"
//		{

//			chart "local density" type: series  
//			{
//				data "mean density" value: mean color: #red;
//				data "mean binomial" value: nb_fish*p color: #blue;
//			}
//		}
//		display "local density histogram"
//		{
//
//			chart "local density histogram" type: histogram 
//			{
//				data "<" + dens_range[0] value: dens_list count (each <= dens_range[0]) color: #blue;
//				loop index from: 0 to: length(dens_range)-2
//				{
//					data "" + dens_range[index] + "-" + dens_range[index+1] value: dens_list count ((each > dens_range[index]) and (each <= dens_range[index+1])) color: #blue;
//				}
//				data ">" + dens_range[0] value: dens_list count (each > last(dens_range)) color: #blue;
//			}
//		}
	}
}


experiment "movement to variance" type: batch keep_seed: false until: cycle > cycle_max parallel: true
{
	init
	{
		save []
		to: fileName type: "csv" rewrite: false;
	}

//	parameter "repeat" var: index_repeat among: [1, 2, 3];
//	parameter "sphere map" var: sphere_map among: [true, false];
//	parameter "random birth location" var: random_birth_location among: [true, false];
	parameter "fish speed" var: fish_speed among: [0.2, 0.5, 1.0, 2.0, 5.0, 10.0, 20.0, 40.0];
//	parameter "fish move rate" var: fish_move_rate among: [1, 2, 5, 10, 20];
	
	abort
	{
//		save to: "../includes/results/Capacity/" + "parameter" +simulation_index+ ".txt" rewrite: true;
		save description to: "../includes/results/Capacity/" + "description" +simulation_index+ ".txt" rewrite: true;
	}
}
