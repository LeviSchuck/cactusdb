import stdlib.web.client
module View {
  function pageWrapper(title, content) {
    Resource.full_page(
      title,
      content,
      <meta name="viewport" content="width=device-width, initial-scale=1.0 , maximum-scale=1.0"/>
      ,
      web_response {success},
      {nil}
      );
  }
  function template(content) {
    <div class="navbar">
      <div class="navbar-inner">
        <div class="container">
          <a class="brand span2" href="/main">Cactus DB</a>
          <span class="nav-collapse collapse">
            <span class="form-search pull-right" style="text-align: right">
              <input id=#searchtext type="text" class="input-medium search-query" />
              <input type="button" class="btn btn-info" value="locate" onclick={function(_) {findPlant()}} />
            </>
            <ul class="nav">
              <li><a href="/main">Main</a></li>
              <li><a href="/aging">Aging Report</a></li>
              <li><a href="/meta">Meta</a></li>
            </ul>
          </>
          
        </>
      </>
    </>
    <div id=#main class="container-fluid">
      <div class="row-fluid">     
        {content} 
      </div>
      <hr>
      <footer>
        <p>Cactus DB</p>
      </footer>
    </div>
  }

  function page(path) {
    
    content = 
      <div class="">
        Eggs brah <br />
        {path}
      </>
    template(content)
  }
  function meta_family_add_btn(id) {
    <a onclick={function(_){
      #{"meta_family_add_area_{id}"} = meta_form_genus(id);
      Dom.give_focus(#{"newgenusname_{id}"});
    }} id=#{"family_add_genus_{id}"}><i class="icon-plus"></i></a>
  }
  function meta_genus_add_btn(id) {
    <a onclick={function(_){
      #{"meta_genus_add_area_{id}"} = meta_form_species(id);
      Dom.give_focus(#{"newspeciesnum_{id}"});
    }} id=#{"genus_add_genus_{id}"}><i class="icon-plus"></i></a>
  }
  function meta_species_add_btn(id) {
    <a onclick={function(_){
      #{"meta_species_add_area_{id}"} = meta_form_variety(id);
      Dom.give_focus(#{"newvarietynum_{id}"});
    }} id=#{"species_add_genus_{id}"}><i class="icon-plus"></i></a>
  }

  function meta_family(Plant.Family.t family) {
    <div class="plant_family">
      <h3>{family.familyName}<span id=#{"meta_family_add_area_{family.id}"}>{meta_family_add_btn(family.id)}</span></h3>
      <ul id={"family_{family.id}_list"}>
        {
          Iter.map(function(genus) {
            <li> {
            meta_genus(genus)
            }</li>
          }, Model.get_plant_genus_by_family(family.id))
        }
      </ul>
    </div>
  }
  function meta_genus(genus) {
    <div class="plant_genus">
      <h4>{genus.genusName}<span id=#{"meta_genus_add_area_{genus.id}"}>{meta_genus_add_btn(genus.id)}</span></h4>
      <ul id={"genus_{genus.id}_list"}>
        {
          Iter.map(function(spec) {
            <li> {
            meta_species(spec)
            }</li>
          }, Model.get_plant_species_by_genus(genus.id))
        }
      </ul>
    </div>
  }
  function meta_species(species) {
    <div class="plant_genus">
      <h4>{species.displayId} : {species.speciesName} <span id=#{"meta_species_add_area_{species.id}"}>{meta_species_add_btn(species.id)}</span></h4>
      <ul id={"species_{species.id}_list"}>
        {
          Iter.map(function(a) {
            <li> {
            meta_variety(a)
            }</li>
          }, Model.get_plant_variety_by_species(species.id))
        }
      </ul>
    </div>
  }
  function meta_variety(variety) {
    <span class="plant_genus">
      {variety.displayId} : {variety.varietyName}
    </>
  }
  function meta_form_family() { 
    <span class="plant_add_family input-append">
      <input id=#newfamilyname size="20" type="text" onnewline={function(_){meta_form_family_submit()}} />
      <a class="btn" onclick={function(_){meta_form_family_submit()}}>Add Family!</a>
    </>
  }
  function meta_form_genus(id) {
    <span class="plant_add_genus input-append" id=#{"newgenus_{id}"}>
      <input id=#{"newgenusname_{id}"} size="10" type="text" onnewline={function(_){meta_form_genus_submit(id)}}/>
      <a class="btn" onclick={function(_){meta_form_genus_submit(id)}}><i class="icon-plus"></i></a>
    </>
  }
  function meta_form_species(id) {
    <span class="plant_add_species control-group" id=#{"newspecies_{id}"}>
      <span class="controls">
        <span class="input-prepend">
          <span class="add-on">#</>
          <input id=#{"newspeciesnum_{id}"} size="3" type="text" class="span1" />
        </>
        <span class="input-append">
          <input id=#{"newspeciesname_{id}"} size="10" type="text" onnewline={function(_){meta_form_species_submit(id)}}/>
          <a class="btn" onclick={function(_){meta_form_species_submit(id)}}><i class="icon-plus"></i></a>
        </>
      </>
    </>
  }
  function meta_form_variety(id) {
    <span class="plant_add_variety control-group" id=#{"newvariety_{id}"}>
      <span class="controls">
        <span class="input-prepend">
          <span class="add-on">#</>
          <input id=#{"newvarietynum_{id}"} size="3" type="text" class="span1" />
        </>
        <span class="input-append">
          <input id=#{"newvarietyname_{id}"} size="10" type="text" onnewline={function(_){meta_form_variety_submit(id)}}/>
          <a class="btn" onclick={function(_){meta_form_variety_submit(id)}}><i class="icon-plus"></i></a>
        </>
      </>
    </>
  }
  function meta_form_family_submit() {
    famname = Dom.get_value(#newfamilyname)
    Dom.clear_value(#newfamilyname)
    id = Model.make_family(famname)
    result = 
    <li>
    {
      meta_family(Model.get_plant_family(id))
    }
    </li>

    #meta_family_list =+ result
    #{"meta_family_add_area_{id}"} = meta_family_add_btn(id);
    void
  }
  function meta_form_genus_submit(parentid) {
    genusname = Dom.get_value(#{"newgenusname_{parentid}"});
    if(String.length(genusname) > 0) {
      id = Model.make_genus(parentid,genusname);
      result = 
      <li>
      {
        meta_genus(Model.get_plant_genus(id))
      }
      </li>
      #{"family_{parentid}_list"} += result
    }
    #{"meta_family_add_area_{parentid}"} = meta_family_add_btn(parentid);
    void
  }
  function meta_form_species_submit(parentid) {
    speciesname = Dom.get_value(#{"newspeciesname_{parentid}"});
    speciesnum = Parser.parse(parser {
      case n = ([0-9]+) : Int.of_string(Text.to_string(n))
      case .* : -1
    }, Dom.get_value(#{"newspeciesnum_{parentid}"}))
    if(speciesnum == -1) {
      Dom.add_class(#{"newspecies_{parentid}"},"error")
    }
    if(String.length(speciesname) > 0 && speciesnum >= 0) {
      id = Model.make_species(parentid,speciesname,speciesnum);
      result = 
      <li>
      {
        meta_species(Model.get_plant_species(id))
      }
      </li>
      #{"genus_{parentid}_list"} += result
      #{"meta_genus_add_area_{parentid}"} = meta_genus_add_btn(parentid);
    }else{
      if(String.length(speciesname) == 0) {
        #{"meta_genus_add_area_{parentid}"} = meta_genus_add_btn(parentid);
      }
    }

    
    void
  }
  function meta_form_variety_submit(parentid) {
    varietyname = Dom.get_value(#{"newvarietyname_{parentid}"});
    varietynum = Parser.parse(parser {
      case n = ([0-9]+) : Int.of_string(Text.to_string(n))
      case .* : -1
    }, Dom.get_value(#{"newvarietynum_{parentid}"}))
    if(varietynum == -1) {
      Dom.add_class(#{"newvariety_{parentid}"},"error")
    }
    if(String.length(varietyname) > 0 && varietynum >= 0) {
      id = Model.make_variety(parentid,varietyname,varietynum);
      result = 
      <li>
      {
        meta_variety(Model.get_plant_variety(id))
      }
      </li>
      #{"species_{parentid}_list"} += result
      #{"meta_species_add_area_{parentid}"} = meta_species_add_btn(parentid);
    }else{
      if(String.length(varietyname) == 0) {
        #{"meta_species_add_area_{parentid}"} = meta_species_add_btn(parentid);
      }
    }
    
    void
  }
  
  function meta(path) {

    content = 
      <div id=#meta_root>
      <h1>Meta Data: {path}</h1>
      <h2>Families</>
      <ul id=#meta_family_list>
      {
        Iter.map(function(a) {
            <li id={"meta_family_{a.id}"}> {
            meta_family(a)
            }</li>
          }, Model.get_plant_families())
      }
      </ul>
      {meta_form_family()}<br />
      </>

    template(content)
  }
  function aging(path) {

    content = 
      <div>
      Aging: {path}
      </>
    template(content)
  }
  function find(path) {

    content = 
      <div>
      Find: {path}
      </>
    template(content)
  }
  function plant(path) {
    content = 
      <div>
      Plant: {path}
      </>
    template(content)
  }


  function findPlant() {
    searchtext = Dom.get_value(#searchtext)
    Dom.clear_value(#searchtext)
    search_type = parser {
      case [0-9]+ "-" [0-9]+ "-" [0-9]+ : {fullDisplayId}
      case [0-9]+ "-" [0-9]+ : {speciesVariantAll}
      case [0-9]+ : {speciesAll}
      case (.*) : {other}
    }
    st = Parser.parse(search_type,searchtext)
    match(st) {
      case {fullDisplayId} : Client.goto("/plant/" ^ searchtext)
      case {speciesVariantAll} : Client.goto("/find/plants/" ^ searchtext)
      case {speciesAll} : Client.goto("/find/plants/" ^ searchtext)
      case {other} : Client.goto("/find/all/" ^ searchtext)
    }

    void
  }
}

