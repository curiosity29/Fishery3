
model A1703

global torus: true
{
// ----------------------------------------------------------------------   FOR EXPERIMENT
	int index_repeat <- 0;
	int init_type <- 1;
	// 1 for first sites, 2 for first row
	
	string description <- "experiment february 9 with torus environment, growth by sites and fish with weight to analyze growth rate";
	string today <- "18032023";
	string simulation_index <- today + "01" ;
	
	
// ---------------------------------------------------------------------- PARAMETER FOR SIMULATION

//	float fish_local_cap <- 30.0;	// local K
	float fish_local_cap <- 5.0;
	int height <- 10;
	int width <- 10;
	
	int fish_move_rate <- 1;
// system

	int rep <- 0;
	float pi <- 3.141592;
	int cycle_max <- 10000;
//	int cycle_min <- cycle_max/2;
	float map_size <- 100.0;

//	int fish_cap <- 1000;

	float fish_reproduce_rate <- 0.01;				// r
//	float fish_local_density_radius <- 10.0; 
	
	float effort <- fish_reproduce_rate * 8;
						
	float fish_speed <- 1.0;
	
	int color_period <- 50;
	
//	int nb_fish -> sum(dens_list);
	
	list<int> starting_site <- [2, 2];
	float K <-  fish_local_cap * width*height;
	float k <- fish_local_cap;
	float binomialK <- K + 1 - K/k;
	float p <- k/K;
	float var <- 0.0;
	float delta <- 0.0;
	float root1 <- 0.0;
	float root1_average <- 0.0;
	float dN_expected <- 0.0;
	
//	int fish_number <- 2*binomialK - K;
	int fish_number <- 200;
	float total_starting_weight <- 5.0;
	
	float r <- fish_reproduce_rate;
	
// ---------------------------------------------------------------------- PARAMETER FOR STATISTICS AND HELPER
	float mean <- 0.0;
	float dN_cut <- 0.0;
	float var_binomial <- 0.0;
	float var_moving_average;
	float var_average;
	list<float> var_list;
	list<float> mean_list;
	float fish_average <- 0.0;
	
	int cycle_passed <- 0;
	int cycle_min <- 2000;
	
	float dn_by_var ;
	
	list<float> dens_list;

// ---------------------------------------------------------------------- INIT

	init {
		if init_type = 1
		{
			create fish number: fish_number with: (weight: 1.0/fish_number* total_starting_weight, location: any_point_in(sites(0))) ;			
		}
		if init_type = 2
		{
			geometry firstRow <- union(sites where (each.grid_x = 0) collect each.shape);
			create fish number: fish_number with: (weight: 1.0/fish_number* total_starting_weight, location: any_point_in(firstRow)) ;			
		}
	}
	
// ---------------------------------------------------------------------- ACTION
	action calculate_var
	{
		dens_list <- sites collect (each.N);
		var <- variance(dens_list);
		mean <- mean(dens_list);
		var_list<+ var;
		mean_list <+ mean;
		var_binomial <- total_weight*p*(1-p);
	}
	
	reflex stop_exp when: cycle > cycle_max
	{
		do pause;
	}
	action simulate
	{
		ask fish { do fish_move;}
		
		do calculate_var;
		dn_by_var <- r/k/p * (-mean*mean + k * mean - var);
		
		ask sites parallel: true { do grow;}
		ask fish { do split;}
//		ask sites {do shrink;}
		ask fish { if self.dead = true {do die;}}
	}
	
	float total_weight <- total_starting_weight;
	float total_weight_prev;
	float total_weight_change;
	list<float> total_weight_list;
	action update_total_weight
	{
		total_weight_list <+ total_weight;
		total_weight_prev <- total_weight;
		total_weight <- sum(sites collect each.N);
		total_weight_change <- total_weight - total_weight_prev;
	}
	
	reflex control
	{
		do simulate;
		do update_total_weight;
	}
	
// ---------------------------------------------------------------------- SAVING RESULTS
	
	string fileName <- "../includes/results/" + today + "/" + "fish_variance_" +simulation_index+ "_speed" + fish_speed+ "_type"+ init_type + ".csv";
	reflex save_result when: cycle = cycle_max
	{
		save [index_repeat, fish_speed] + var_list + mean_list + total_weight_list
		to: fileName type: "csv" rewrite: false header: false;
	}
	string fileName_sites <- "../includes/results/" + today + "/" + "fish_sites_" +simulation_index+ "_speed" + fish_speed+ "_type"+ init_type + ".csv";
	reflex save_result_sites
	{
		save [cycle] +sites collect (each.N) 
		to: fileName_sites type: "csv" rewrite: false header: false;
	}
}

// ---------------------------------------------------------------------- AGENTS
species fish skills: [moving] //parallel: true
{
	float weight <- 1.0;
	float weight_gain_ratio <- 0.0;
	rgb color <- #green;
	bool dead <- false;
	init
	{
		speed <- fish_speed;
	}

	aspect base {
		draw circle(0.5) color: color;
	}
	
	action fish_move {
//		 random location
//		location <- any_location_in(world.shape);
//		 normal movement
//		loop times: fish_move_rate
//		{do wander speed: fish_speed;}
		do wander;
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

// ---------------------------------------------------------------------- AGENT - ENVIRONMENT
grid sites width: width height: height neighbors: 8
{ 	
	int yield <- 0;
	float growth_rate;
	bool fishing <- false;
	float N -> sum(fish_inside collect each.weight);
	// update: sum(fish_inside collect each.weight)  ;
	
	float Y;
	float x1 <- location.x - map_size/ width/2;
	float x2 <- x1 + map_size/ width;
	float y1 <- location.y - map_size/ height/2;
	float y2 <- y1 + map_size/ height;
	list fish_inside -> fish inside self;
	action grow
	{
//		N <- sum(fish_inside collect each.weight); 
		
		growth_rate <- fish_reproduce_rate *( 1 - N/ fish_local_cap);
		
		ask fish inside self
		{
			weight <- weight * (1 + myself.growth_rate);
		}
		
	}
	
	action shrink
	{
		create fish number: fish_local_cap with: (location: any_point_in(self), weight: N*growth_rate/ fish_local_cap);
		if length(fish_inside) > 2 * fish_local_cap
		{
			
			ask fish_inside {dead <- true;}
			
		}
	}
	

}
// ---------------------------------------------------------------------- DISPLAY
experiment "display"
{

	output
	{
		display map
		{
			grid sites border: #black;
			species fish aspect: base;
		}
//		monitor "average population" value: fish_average;
//		monitor "binomial capacity" value: binomialK;
//		monitor "average variance" value: var_average;
//		monitor "ideal capacity" value: K;
//		monitor "average root capacity" value: root1_average;
//		monitor "average local density" value: average_density;
//		monitor "average binomial density" value: fish_average*p;
//		monitor "dN expected" value: dN_expected;
//
//		display population
//		{
//			chart "population" type: series
//			{
//				
//				data "population" value: total_weight color: #blue;
////				data "binomial capacity" value: binomialK color: #red;
////				data "ideal capacity" value: K color: #green;
////				data "average population" value: fish_average color: #black;
////				data "weight change" value: total_weight_change/r color: #brown; 
////				data "root capacity" value: root1 color: #purple;
////				data "dN relative value" value: dN_cut color: #black;
//			}
//		}

		display "dPopulation"
		{
			chart "dPopulation" type: series  
			{
				data "weight change by var" value: total_weight_change - dn_by_var color: #red;
//				data "weight change exp" value: total_weight_change color: #red;
//				data "weight change actual" value: total_weight_change_prev color: #blue;
//				data "weight change actual" value: r/k/p * (-mean*mean + k * mean - var) color: #orange;
//				data "weight change true" value: dn_by_var color: #brown;
				
//				data "weight change" value: total_weight_change color: #blue; 
			}
		}
				
//		display "variance"
//		{
////				data "mean" value: mean color: #red;
////				data "Np" value: nb_fish*p color: #blue;
////				data "delta" value: mean - nb_fish*p color: #black;
////				data "1" value: 1 color: #black;
//
//			chart "variance" type: series  
//			{
//				data "var binomial" value: var_binomial color: #red;
//				data "var" value: var color: #blue;
////				data "moving average" value: var_moving_average color: #green;
////				data "average variance" value: var_average color: #black;
//
//			}
//		    chart "my_chart" type: scatter {
//		        data "moment" value: [var, total_weight_change] accumulate_values: true line_visible:false ;
//		    }
		}
//		display 3d type: opengl {
//	        // Display the grid with elevation
//	        grid sites elevation: color_accumulated * 10 triangulation: true border: #black;
//	    }
//	}
	

}

// ---------------------------------------------------------------------- EXPERIMENT

experiment "intial distribution" type: batch keep_seed: false until: cycle > cycle_max parallel: true
{

	parameter "init_type" var: init_type among: [1, 2];

	parameter "fish speed" var: fish_speed among: [0.01, 0.02, 0.05, 0.1, 0.2, 0.4, 0.6, 1.0, 2.0, 4.0, 6.0, 10.0, 20.0, 40.0, 80.0, 100.0];

	abort
	{
//		save to: "../includes/results/Capacity/" + "parameter" +simulation_index+ ".txt" rewrite: true;
		save description to: "../includes/results/" + today + "/" + "description_" +simulation_index+ ".txt" rewrite: true;
	}
}

