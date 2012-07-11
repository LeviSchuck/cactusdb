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
    <div class="navbar navbar-fixed-top">
      <div class="navbar-inner">
        <div class="container">
          <a class="brand" href="/main">Cactus DB</a>
          
            <span class="navbar-search pull-right input-append cactus-nav" style="text-align: right">
              <input id=#searchtext type="text" class="input-medium search-query" onnewline={function(_) {findPlant()}} />
              <a class="btn btn-info" onclick={function(_) {findPlant()}} >Locate</a>
            </>
            <ul class="nav">
              <li><a href="/main">Main</a></li>
              <li><a href="/aging">Aging Report</a></li>
              <li><a href="/meta">Meta</a></li>
            </ul>
          
        </>
      </>
    </>
    <div id=#main class="container-fluid">
      <div class="row-fluid">     
        {content} 
      </div>
      <hr />
      <footer>
        <p>Cactus DB</p>
      </footer>
    </div>
  }

  function page(path) {
    allplants = Iter.to_list(Model.get_plants())
    plants = Plant.render_plant_grid(allplants)
    content = 
      <>
      <h1>All Plants</h1>
      {plants}
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

