module Plant {
	function page(path) {
		p = List.head(path);
		Parser.parse(parser {
	      case species=([0-9]+) "-" variety=([0-9]+) "-" memberid=([0-9]+) : {
	      	content = 
		      <div id=#plant_root>
			      <h1>Plant: {path}</h1>
			      <div id=#plant_root_content>
			      	{render_potential_plant(
			      		parse_int(Text.to_string(species),-1),
			      		parse_int(Text.to_string(variety),-1),
			      		parse_int(Text.to_string(memberid),-1))}
			      </>
		      </>
		    View.template(content)
	      }
	      case (.*) : {
	      	Client.goto("/find/plants/{path}")
	    	<span>No content</span>
	      }
	    }, p)
	}
	function render_plant_origin(plantid,origin) {
		<span onclick={function(_){edit_origin(plantid)}}>{origin}</span>
	}
	function render_plant_misc(plantid,misc) {
		<span onclick={function(_){edit_misc(plantid)}}>{misc}</span>
	}
	function render_plant(Plant.t plant) {
		display = Model.get_plant_display(plant)
		<div id=#{"plant_{plant.id}"}>
			<h2>{display.family}</>
			<h3>{display.genus} {display.species}</>
			<h4>Variety: {
				if(String.length(display.variety) > 0) {
					display.variety
				}else{
					"Not specified"
				}
			}</>
			<p>
				<h4 onclick={function(_){edit_origin(plant.id)}}>Origin</>
				<span id=#{"plant_{plant.id}_origin"}>
					{render_plant_origin(plant.id,display.origin)}
				</span>
				<h4 onclick={function(_){edit_misc(plant.id)}}>Misc.</>
				<span id=#{"plant_{plant.id}_misc"}>
					{render_plant_misc(plant.id,display.misc)}
				</span>
			</>
		</>
	}
	function edit_origin(plantid) {
		plant = Model.get_plant(plantid);
		#{"plant_{plantid}_origin"} = 
			<span class="input-append">
				<input type="text" value={plant.origin} id=#{"plant_{plant.id}_origin_input"} onnewline={function(_){
					save_origin(plantid);
				}} />
				<a class="btn" onclick={function(_){save_origin(plantid)}}><i class="icon-ok"></i></a>
			</>
	}
	function save_origin(plantid) {
		plant = Model.get_plant(plantid);
		origin = Dom.get_value(#{"plant_{plant.id}_origin_input"})
		newplant = {
			id: plantid,
			family : plant.family,
			genus: plant.genus,
			species: plant.species,
			variety: plant.variety,
			memberid: plant.memberid,
			~origin,
			misc: plant.misc,
			eventcount : plant.eventcount
		}
		Model.save_plant(newplant)
		#{"plant_{plant.id}_origin"} = render_plant_origin(plantid,origin)
		void
	}
	function edit_misc(plantid) {
		plant = Model.get_plant(plantid);
		#{"plant_{plantid}_misc"} = 
			<span class="input-append">
				<input type="text" value={plant.misc} id=#{"plant_{plant.id}_misc_input"} onnewline={function(_){
					save_misc(plantid);
				}} />
				<a class="btn" onclick={function(_){save_misc(plantid)}}><i class="icon-ok"></i></a>
			</>
	}
	function save_misc(plantid) {
		plant = Model.get_plant(plantid);
		misc = Dom.get_value(#{"plant_{plant.id}_misc_input"})
		newplant = {
			id: plantid,
			family : plant.family,
			genus: plant.genus,
			species: plant.species,
			variety: plant.variety,
			memberid: plant.memberid,
			origin: plant.origin,
			~misc,
			eventcount : plant.eventcount
		}
		Model.save_plant(newplant)
		#{"plant_{plant.id}_misc"} = render_plant_misc(plantid,misc)
		void
	}
	function parse_int(string t, int default_val) {
		Parser.parse(parser {
	      case n = ([0-9]+) : Int.of_string(Text.to_string(n))
	      case .* : default_val
	    }, t)
	}
	function render_potential_plant(int species, int variety, int memberid) {
		species_id = Model.find_species_by_display(species);
		variety_id = Model.find_variety_by_display(species_id,variety);
		plant = Model.find_plant(species, variety,memberid)

		match(Iter.max(plant)) {
			case {none}: {
				if(species_id == -1){
					create_species(species,variety,memberid)
				}else if(variety_id == -1){
					create_variety(species,variety,memberid)
				}else{
					create_plant(species,variety,memberid)
				}
			}
			case {some: value } : {
				render_plant(value)

				
			}
		}
	}

	function create_species(int species, int variety, int memberid) {
		<span class="control-group" id=#{"species_create_{species}"}>
			<h1>No such species exists!</h1>
			<h3>Create it?</h3>
			<div class="controls">
				<span class="input-prepend">
					<span class="add-on">Genus:</span>
					<select class="span3" id=#{"genus_select_{species}"}>
						{
							Iter.map(function(a) {
					            <option value={a.id}>{a.genusName}</option>
					        }, Model.get_plant_genuses())
						}
					</select>
				</span>

				<span class="input-append">
					<input type="text" class="span2" id=#{"species_input_{species}"} onnewline={function(_){
						save_species(species,variety,memberid)
					}} />
					<a class="btn" onclick={function(_){
						save_species(species,variety,memberid)
					}}><i class="icon-ok"></i></a>
				</span>
			</>
		</>
	}
	function save_species(int species, int variety, int memberid) {
		genus = parse_int(Dom.get_value(#{"genus_select_{species}"}),-1)
		species_name = Dom.get_value(#{"species_input_{species}"})
		if(genus > 1 && String.length(species_name) > 0){
			_ = Model.make_species(genus,species_name,species)
			#plant_root_content = render_potential_plant(species,variety,memberid)
		}else{
			Dom.add_class(#{"species_create_{species}"},"error")
		}
		void
	}
	function save_variety(int species, int variety, int memberid) {
		variety_name = Dom.get_value(#{"variety_input_{species}_{variety}"})
		species_id = Model.find_species_by_display(species)
		_ = Model.make_variety(species_id,variety_name,variety)
		#plant_root_content = render_potential_plant(species,variety,memberid)
		void
	}
	function create_variety(int species, int variety, int memberid) {
		<span class="control-group" id=#{"variety_create_{species}_{variety}"}>
			<h1>No such variety exists!</h1>
			<h3>Create it?</h3>
			<div class="controls">
				<span class="input-prepend">
					<input type="text" class="span2" id=#{"variety_input_{species}_{variety}"} onnewline={function(_){
						save_variety(species,variety,memberid)
					}} />
					<a class="btn" onclick={function(_){
						save_variety(species,variety,memberid)
					}}><i class="icon-ok"></i></a>
				</>
			</>
		</>
	}
	function create_plant(int species, int variety, int memberid) {
		species_id = Model.find_species_by_display(species);
		variety_id = Model.find_variety_by_display(species_id,variety);
		species_ = Model.get_plant_species(species_id)
		variety_ = Model.get_plant_variety(variety_id)
		genus = Model.get_plant_genus(species_.genus)
		family = Model.get_plant_family(genus.family)
		<div id=#{"newplant_{memberid}"}>
			<h2>{family.familyName}</>
			<h3>{genus.genusName} {species_.speciesName}</>
			<h4>Variety: {
				if(String.length(variety_.varietyName) > 0) {
					variety_.varietyName
				}else{
					"{variety}"
				}
			}</>
			<p>
				<h4>Origin</>
				<input type="text" id=#{"newplant_{memberid}_origin"} />
				<h4>Misc.</>
				<input type="text" id=#{"newplant_{memberid}_misc"} /><br />
				<a class="btn btn-primary" onclick={function(_){
					save_plant(species,variety,variety_id,memberid)
				}}>Save</a>
			</>
		</>
	}
	function save_plant(spec,var,int variety, int memberid) {
		Model.make_plant(variety,memberid,
			Dom.get_value(#{"newplant_{memberid}_origin"}),
			Dom.get_value(#{"newplant_{memberid}_misc"}));
		#plant_root_content = render_potential_plant(spec,var,memberid)
		void
	}
	


}