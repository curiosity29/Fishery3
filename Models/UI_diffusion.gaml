
model Agentbased

global
{
	my_cell selected_cells;
	matrix<float> fish_mat_diff <- matrix([
        [1/9,1/9,1/9],
        [1/9,1/9,1/9],
        [1/9,1/9,1/9]]);
	
	int fish_number <- 50;
	float fish_reproduce_rate <- 0.1;				// r
	float fish_local_density_radius <- 10.0; 
	float fish_local_cap <- 100.0;						// local K
	float fish_speed <- 1.0;
	
	int boat_number <- 5;
	float boat_speed <- 5.0;
	float boat_catch_prob <- 0.2;
	float boat_fishing_radius <- 10.0;
	float yeild_all <- 0.0;

	int height <- 16;
	int width <- 16;
	
	init
	{
		
		selected_cells <- location as my_cell;
				
		create boat number: boat_number;

	

	}
	
	reflex reset_yeild
	{
		yeild_all <- 0.0;
		ask boat
		{
			yeild <- 0.0;
		}
	}
}



grid my_cell width: width height: height
{
	float fish_population <- 0.0;
	rgb color <- hsb(fish_population, 1.0, 1.0) update: hsb(fish_population,1.0,1.0);
    reflex diff 
    {
		int local_density <- length(my_cell at_distance fish_local_density_radius);
		float reproduce_prob <- fish_reproduce_rate * (1 - local_density/ fish_local_cap);
		
		 // NOT WORKING
    	diffuse var: fish_population on: my_cell matrix: fish_mat_diff;       
    }
	
}

species boat skills: [moving]
{
  	init {
    	speed <- boat_speed;
   	}

	float yeild <- 0;
	image_file my_icon <- image_file("../includes/data/boat.png");
	reflex catch_fish
	{
		float yeild <- 0;
		list<my_cell> cell_in_area <- my_cell at_distance boat_fishing_radius;
		int cell_num <- length(cell_in_area);
		yeild <- cell_num * boat_catch_prob;
		yeild_all <- yeild_all + yeild;
		loop cell over: cell_in_area
		{
			ask cell
			{
				cell.fish_population <- cell.fish_population * (1 - boat_catch_prob);
			}
		}

	}
	aspect base {
		draw circle(boat_fishing_radius) color: color;
	}

	aspect icon {
		draw my_icon size: 4.0;
	}
	
	reflex move {
    do wander;
    }
}

experiment main_experiment type: gui
{
	parameter "Initial number of fishs: " var: fish_number min: 0 max: 1000 category: "Fish";
	parameter "Fish local density radius" var: fish_local_density_radius min: 0.0 max: 30.0 category: "Fish";
	parameter "Fish reproduce rate" var: fish_reproduce_rate min: 0.0 max: 20.0 category: "Fish";
	parameter "Fish local population capacity" var: fish_local_cap min: 0.0 max: 500.0 category: "Fish";
	parameter "Fish's movement speed " var: fish_speed min: 0.0 max: 30.0 category: "Fish";
	
	parameter "Initial number of boats: " var: boat_number min: 0 max: 30 category: "Boat";
	parameter "Effort / catch probability" var: boat_catch_prob min: 0.0 max: 1.0 category: "Boat";
	parameter "Catching radius" var: boat_fishing_radius min: 0.0 max: 30.0 category: "Boat";
	parameter "Boat's movement speed " var: boat_speed min: 0.0 max: 30.0 category: "Boat";
	
	parameter "Horizontal grid number" var: width min: 0 max: 30 category: "Model";
	parameter "Vertical grid number" var: height min: 0 max: 30 category: "Model";
	
	output
	{
		display map
		{
			grid my_cell lines: #black;
    		species boat aspect:base;
    		species boat aspect:icon;
		}
		display Population_information {
			chart "Yeild" type: series size: {1,0.5} position: {0, 0} {
				data "Yeild" value: yeild_all color: #red;
			}	
//		chart "Yeild" type: series size: {1,0.5} position: {0, 0.5} {
//				data "Yeild" value: nb_fish color: #blue;
//			}	
		}
		
	}
	
}

