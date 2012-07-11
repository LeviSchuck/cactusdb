import stdlib.widgets.datepicker
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
	function render_plant_events_wrapper(Plant.t plant) {
		rendered_plant_events =  render_plant_events(plant.id);
		<h2>History 
			<a id=#{"plant_{plant.id}_history_add"} class="btn" onclick={function(_){
				add_plant_event(plant.id)
			}}><i class="icon-plus"></i></a>
		</>
		<div id=#{"plant_{plant.id}_history"}>
			{rendered_plant_events}
		</>
	}
	function render_plant_latest_events(Plant.t plant) {
		<>
		<h3>Latest Events</h3>
		{
			Iter.map(function(kind) {
				lastevent = Model.get_history_last_event(plant.id,kind.kind)
				if(Date.in_milliseconds(lastevent.eventDate) > 0) {
					<div class="row-fluid">
						<span class="span6">{kind.name}</span>
						<span class="span6">{Date.to_string_date_only(lastevent.eventDate)}</span>
					</div>
				} else {
					<></>
				}
				
			},Model.get_event_kinds())
		}
		</>
	}
	function render_plant(Plant.t plant, additional) {
		display = Model.get_plant_display(plant)


		<div id=#{"plant_{plant.id}"}>
			<h2>{display.family} {Model.get_plant_displayid(plant)}</>
			<h3>{display.genus} {display.species}</>
			<h4>Variety: {
				if(String.length(display.variety) > 0) {
					display.variety
				}else{
					"{display.varietyid}"
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
			{additional}
		</>
	}
	function render_plant_tile(Plant.t plant) {
		render_plant(plant,
			<>
			{
				render_plant_latest_events(plant)
			}
			<a class="btn btn-primary pull-right" onclick={function(_){
				Client.goto("/plant/{Model.get_plant_displayid(plant)}")
			}}><i class="icon-pencil icon-white"></i> Edit</a>
			<hr />
			
			</>
			)
	}
	function render_plant_events(plantid) {
		<div id=#{"plant_{plantid}_events"}>
			{
				Iter.map(function(a) {
					{
					render_plant_event(a)
					}
				}, Model.get_plant_events(plantid))
			}
		</>
	}
	function render_plant_event(Plant.History.Event e) {
		kind = Model.get_history_event_kind(e.kind)
		<div class="row-fluid" id=#{"plant_{e.eventid}_row"}>
			<span class="span1">{e.eventid}</>
			<span class="span2">{Date.to_string_date_only(e.eventDate)}</>
			<span class="span2"><strong>{kind.name}</strong></>
			<span class="span3">{e.notes}</>
			<span class="span1">
				<a class="btn" onclick={function(_){
					edit_plant_event(e)
				}}><i class="icon-pencil"></i></a>
			</>
		</>
	}
	client function validate_date(dom,err) {
		val = Dom.get_value(dom);
		res = parse_date(val)
		if(res == {none}){
			Dom.add_class(err,"error")
		}else{
			Dom.remove_class(err,"error")
		}
	}
	exposed function add_plant_event(plantid) {
		plant = Model.get_plant(plantid)
		Dom.add_class(#{"plant_{plantid}_history_add"},"hide")
		#{"plant_{plantid}_events"} += 
			<div id=#{"plant_{plantid}_{plant.eventcount}_add"} class="row-fluid">
			<span class="span1">{plant.eventcount}</>
			<span class="control-group span2" id=#{"plant_{plantid}_{plant.eventcount}_add_date_cg"}>{
				/*WDatepicker.edit_default(
					{function(_){}},
					"plant_{plantid}_{plant.eventcount}_add_date",
					Date.now())*/
				<input type="date" id=#{"plant_{plantid}_{plant.eventcount}_add_date"} placeholder="YYYY-MM-DD" onblur={function(_){
					validate_date(#{"plant_{plantid}_{plant.eventcount}_add_date"},#{"plant_{plantid}_{plant.eventcount}_add_date_cg"})
				}}  class="fill_span" value={Date.to_string_date_only(Date.now())}/>
			}</>
			<span class="span2"><select id=#{"plant_{plantid}_{plant.eventcount}_add_kind"} class="fill_span">
			{
				Iter.map(function(a) {
					<option value={a.kind}>{a.name}</option>
				}, Model.get_event_kinds())
			}
			</select></>
			<span class="span3">
			<input type="text" id=#{"plant_{plantid}_{plant.eventcount}_add_notes"} class="fill_span" />
			</>
			<span class="span1">
				<a class="btn" onclick={function(_){
					save_plant_event(plantid,plant.eventcount);
				}}><i class="icon-ok"></i></a>
			</>
		</>
	}
	exposed function edit_plant_event(e) {
		edit = 
			<span class="span1">{e.eventid}</>
			<span class="control-group span2" id=#{"plant_{e.eventid}_edit_date_cg"}>{
				<input type="date" id=#{"plant_{e.eventid}_edit_date"} placeholder="YYYY-MM-DD" onblur={function(_){
					validate_date(#{"plant_{e.eventid}_edit_date"},#{"plant_{e.eventid}_edit_date_cg"})
				}}  class="fill_span" value={Date.to_string_date_only(e.eventDate)}/>
			}</>
			<span class="span2"><select id=#{"plant_{e.eventid}_edit_kind"} class="fill_span">
			{
				Iter.map(function(a) {
					if(e.kind == a.kind){
						<option value={a.kind} selected>{a.name}</option>
					}else{
						<option value={a.kind}>{a.name}</option>
					}
					
				}, Model.get_event_kinds())
			}
			</select></>
			<span class="span3">
			<input type="text" id=#{"plant_{e.eventid}_edit_notes"} class="fill_span" value={e.notes} />
			</>
			<span class="span1">
				<a class="btn" onclick={function(_){
					save_edited_plant_event(e)
				}}><i class="icon-ok"></i></a>
			</>
			<span class="span1">
				<a title="Delete Event" class="btn  btn-danger" onclick={function(_){
					delete_plant_event(e)
				}}><i class="icon-trash icon-white"></i></a>
			</>
			
		#{"plant_{e.eventid}_row"} = edit;
	}
	function parse_date(date) {
		//The only reason why this function exists is because Opa can't friggen validate months properly.
		//It doesn't care about year or day, just months, and I can't try catch it.
		scanner = Date.generate_scanner("%Y-%m-%d");
		Parser.parse(parser {
			case [0-9]+ "-" [0]* ([1] [0-2] | [1-9]) "-" [0-9]+ : {
				Date.of_formatted_string(scanner,date);
			}
			case .* : {none}
		},date)
	}
	function save_plant_event(plantid,eventcount) {
		kind = parse_int(Dom.get_value(#{"plant_{plantid}_{eventcount}_add_kind"}),-1)
		notes = Dom.get_value(#{"plant_{plantid}_{eventcount}_add_notes"})
		date = Dom.get_value(#{"plant_{plantid}_{eventcount}_add_date"})
		res = parse_date(date)
		Log.info("date", "Parsed date as {res}")
		match(res){
			case {none} : {
				Dom.add_class(#{"plant_{plantid}_{eventcount}_add_date_cg"},"error")
			}
			case {some : value} : {
				Dom.remove_class(#{"plant_{plantid}_{eventcount}_add_date_cg"},"error")
				if(kind >= 0) {
					Dom.remove(#{"plant_{plantid}_{eventcount}_add"})
					eid = Model.make_history_event(plantid,kind,notes,value);
					#{"plant_{plantid}_events"} += render_plant_event(Model.get_history_event(eid))
					Dom.remove_class(#{"plant_{plantid}_history_add"},"hide")
				}
				void
			}

		}
		void
	}
	function delete_plant_event(e) {
		Model.delete_history_event(e)
		Dom.remove(#{"plant_{e.eventid}_row"})
	}
	function save_edited_plant_event(event) {
		eventid = event.eventid
		kind = parse_int(Dom.get_value(#{"plant_{eventid}_edit_kind"}),-1)
		notes = Dom.get_value(#{"plant_{eventid}_edit_notes"})
		date = Dom.get_value(#{"plant_{eventid}_edit_date"})
		scanner = Date.generate_scanner("%Y-%m-%d")
		res = Date.of_formatted_string(scanner,date)
		match(res){
			case {none} : {
				Dom.add_class(#{"plant_{eventid}_edit_date_cg"},"error")
			}
			case {some : value} : {
				Dom.remove_class(#{"plant_{eventid}_edit_date_cg"},"error")
				if(kind >= 0) {
					Model.save_history_event({
						~eventid,
						plantid: event.plantid,
						eventDate: value,
						kind: kind,
						~notes
					})
					#{"plant_{eventid}_row"}= render_plant_event(Model.get_history_event(eventid))
				}
				void
			}

		}
		void
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
				render_plant(value,render_plant_events_wrapper(value))

				
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
		if(genus >= 0 && String.length(species_name) > 0){
			_ = Model.make_species(genus,species_name,species)
			#plant_root_content = render_potential_plant(species,variety,memberid)
		}else{
			//Log.info("failed validation","Failed validation due to g:{genus} sn: {species_name}")
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

	//Perfect example of how to do like 
	/*
	count = 0;
	foreach(plant in plants){
		if(count == 0){
			echo '<div>'
		}
		echo '<span>'.plant.'</span>'
		if(count == 3){
			echo '</div><div>'
			count = 0;
		}
	}
	echo '</div>'
	*/
	//Except recursively, but that's just how this language works.
	function render_plant_tile_rows(rendered_plants) {
		(b, e) = List.split_at(rendered_plants, 3)
		<>
			<div class="plant_tiles row-fluid">
				{
					List.map(function(plant){
						plant
					},b)
				}
			</div>
			{
				if(e == {nil}) {
					<></>
				} else {
					render_plant_tile_rows(e)
				}
			}
		</>
	}
	function render_plant_grid(plants) {
		rendered_plants = 
			List.map(function(plant){
				<span class="plant_tile span4">
				{
					Plant.render_plant_tile(plant)
				}
				</span>
			},plants)
		render_plant_tile_rows(rendered_plants)
	}
	


}